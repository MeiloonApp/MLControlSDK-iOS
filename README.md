# MLControlSDK (iOS)

Meiloon 藍牙控制與音訊處理 SDK，專為 iOS 平台設計，提供完整的 BLE 通訊協議與 PEQ 音訊演算法引擎。

## 🚀 安裝方式

### Swift Package Manager (SPM)

1. 在 Xcode 中選擇 **File > Add Package Dependencies...**
2. 輸入以下網址：
   `https://github.com/ML-SPD/MLControlSDK`
3. 選擇 **Exact Version** 並輸入 `1.0.0` (或最新版本)。

---

## ⚙️ 權限設定 (Permissions)

由於本 SDK 涉及藍牙設備搜尋與控制，請務必在您 App 專案的 **`Info.plist`** 中加入以下權限說明，否則 App 會在啟動或掃描時崩潰：

| Key | Value (建議敘述) |
| :--- | :--- |
| **Privacy - Bluetooth Always Usage Description** | 本 App 需要使用藍牙以搜尋並連接 Meiloon 設備。 |
| **Privacy - Bluetooth Peripheral Usage Description** | 本 App 需要使用藍牙與 Meiloon 設備進行通訊。 |
| **Privacy - Microphone Usage Description** | Use Microphone to Capture Audio |
 
若您習慣直接編輯 `Info.plist` 的 XML 源碼，請加入：
 
```xml
key>NSBluetoothAlwaysUsageDescription</key>
<string>本 App 需要使用藍牙以搜尋並連接 Meiloon 設備。</string>
key>NSBluetoothPeripheralUsageDescription</key>
<string>本 App 需要使用藍牙與 Meiloon 設備進行通訊。</string>
key>NSMicrophoneUsageDescription</key>
<string>Use Microphone to Capture Audio</string>
```

---

## 🔐 隱私庫認證 (若專案為私有)

若您的專案設為私有，請確保您的 Xcode 已登入具備讀取權限的 GitHub 帳號：

1. 開啟 **Xcode > Settings...** (快速鍵 `Cmd + ,`)。
2. 切換至 **Source Control** 標籤。
3. 點擊 **Accounts** 子分頁。
4. 點擊左下角 **「+」** 號，選擇 **GitHub**。
5. 輸入帳號並貼上 **Personal Access Token (PAT)** 進行登入。

---

## 🛠 初始化 SDK

在使用任何藍牙功能前，必須先完成授權驗證。

## 🔑 取得授權
本 SDK 採用 Runtime 驗證機制，所有藍牙控制功能均需配合有效的 **API Key** 方可運作。
*   **申請金鑰**：授權金鑰需向 **Meiloon** 官方申請。請聯繫您的專案窗口或透過官方管道取得。

### 方法 1：使用設定檔 (推薦)
在您的 App 專案中建立一個名為 `MLKey.txt` 的檔案，內容填入您的 API Key，並將其加入 **Copy Bundle Resources**。

接著在 App 啟動處呼叫：

```swift
import MLControlCore

@main
struct YourApp: App {
    init() {
        MLBluetoothCore.shared.configure()
    }
}
```

### 方法 2：手動傳入 Key
```swift
MLBluetoothCore.shared.configure(apiKey: "YOUR-TEST-KEY-2026")
```

> **注意**：SDK 會在上傳 Bundle ID 與 Key 進行雲端驗證成功後才開放功能。

---

## 📱 核心功能使用

### 1. 搜尋與連線設備

實作 `MLBluetoothCoreDelegate` 來接收事件：

```swift
class AppManager: MLBluetoothCoreDelegate {
    func start() {
        MLBluetoothCore.shared.delegate = self
        MLBluetoothCore.shared.startScanning()
    }

    // 發現設備
    func bluetoothCore(_ core: MLBluetoothCore, didDiscover device: Device) {
        print("發現設備: \(device.name)")
    }

    // 連線成功
    func bluetoothCore(_ core: MLBluetoothCore, didConnect peripheral: CBPeripheral) {
        print("已連線至設備")
    }
}
```

### 2. 取得與設定音量

```swift
// 取得音量
MLBluetoothCore.shared.sendCommand(.getVolume, for: selectedDevice)

// 設定音量 (範圍 0-100)
let volumeData = Data([0x32]) // 50
MLBluetoothCore.shared.sendCommand(.setVolume, for: selectedDevice, data: volumeData)
```

### 3. 取得設備詳細資訊

設備連線成功後，SDK 會自動執行初始化序列，您可以透過 Delegate 取得結果：

```swift
func bluetoothCore(_ core: MLBluetoothCore, didFinishInitialDataFetch device: Device) {
    print("韌體版本: \(device.firmwareVer)")
    print("當前音量: \(device.volume)")
}
```

### 4. 處理指令回傳 (Callback Mechanism)
 
當您發送要求數據的指令（例如 `.getVolume` 或 `.getStatus`）後，SDK 提供兩種方式來接收回傳結果：

#### 方式 A：實作委派方法 (Delegate)
在您的 `MLBluetoothCoreDelegate` 實作類別中建立 `didReceiveResponse` 方法。每當 SDK 收到設備回應時，都會觸發此回呼：

```swift
func bluetoothCore(_ core: MLBluetoothCore, didReceiveResponse response: DeviceResponse, for peripheralID: String) {
    switch response.type {
    case .volume:
        // 此時 selectedDevice.volume 已被 SDK 自動更新
        print("收到音量回傳：\(response.value.toHexString())")
    case .status:
        print("收到設備狀態更新")
    default:
        break
    }
}
```

#### 方式 B：觀察 Device 物件屬性 (Reactive)
`Device` 類別遵循 `ObservableObject`。當 SDK 收到回應並更新屬性時，若您在 SwiftUI 中使用該物件，UI 將會**自動刷新**，無需額外撰寫 Callback 邏輯：
```swift
// 當收到設備回應時，selectedDevice.volume 的值會自動變
Text("當前音量：\(selectedDevice.volume)")
```

### 5. PEQ 音訊引擎

將 PEQ 參數轉換為頻率響應曲線數據（可用於繪製圖表）：

```swift
let bands: [EQData] = [...] // 您的頻段數據陣列
let response = MLPEQEngine.shared.calculateCombinedResponse(
    bands: bands,
    fs: 48000.0,    // 取樣率
    numPoints: 1000 // 生成的座標點數量
)

// response 為 [(Double, Double)]，代表 (頻率 Hz, 增益 dB)
```

---

## 📚 詳細文件
SDK 內建 DocC 互動式手冊。您可以直接存取 [線上文件](https://meiloonapp.github.io/MLControlSDK-iOS/documentation/mlcontrolcore/)，或在 Xcode 的 **Product > Build Documentation** 中手動生成並查看更詳細的 API 說明。
