# AppTemplate · BLE 业务层

Pump / TempPatch / Phototherapy 等产品协议与 Demo UI，基于 [AppStart BLE](../../../../../../../AppStart/AppStart/Ble/BLE_README.md) 框架。

> 框架负责：扫描、连接、GATT、串行写队列、`BleAckMatcher` 协议。  
> 本文档负责：0xAA 协议、GATT UUID、配网握手、产品注册、设备管理与页面。

---

## 目录

按功能模块拆分（`Modules/Main/Func/BLE/`）：

| 目录 | 职责 |
|------|------|
| `DeviceManager/` | 业务层已绑定设备：`BleDeviceManager` / `BleBoundDevice` / 握手入库 |
| `Support/` | 配置、广播解析、UI token、Pump 握手辅助 |
| `Support/Pump/` | Pump 帧解析、组包、Trace |
| `Discovery/` | 附近设备扫描列表（名 / MAC / UUID / RSSI） |
| `BoundList/` | 已绑定设备列表（更多细节） |
| `Panel/` | 设备面板；Pump 先复用控制台样式 |
| `Console/` | 测试入口、蓝牙状态、连接控制台 |

| 文件 | 职责 |
|------|------|
| `Support/BleAppConfiguration.swift` | 产品 `BleConfiguration` 注册（含 GATT）、状态格式化 |
| `Support/BleProtocolParsers.swift` | 广播解析、`BleGattUUID`、动态 `bleGattProfile`、副通道 payload |
| `Support/Pump/BlePumpProtocol.swift` | 0xAA 帧解析、`BlePumpAckMatcher`、F0/FD/F7/C0/B0 模型 |
| `Support/Pump/BlePumpTrace.swift` | 指令字段解析打印（LogM + 连接调试页） |
| `Support/Pump/BlePumpCommand.swift` | 组包（F0 / FD / F7 / C0 等） |
| `Support/BlePumpHandshake.swift` | Pump 配网握手编排（原 `BleProvisionHandshake`） |
| `Console/BleConnectionController.swift` | 连接控制台 |

绑定路径：发现列表点选 → 连接 + 握手（Pump：`BlePumpHandshake`）→ `BleDeviceManager.upsert`。

---

## 产品注册

入口 `BleAppConfiguration.setup()` → `BleSession.shared.register(BleProducts.all)`。

| 产品 | 匹配 | GATT |
|------|------|------|
| Pump | `BleParserValidatedMatchingStrategy` + 0xAA 厂商数据 | connect 时由 parser `bleGattProfile` merge |
| TempPatch | LocalName ∈ `BleDeviceCatalog.tempPatchNames` + parser | 默认空 profile |
| Phototherapy | LocalName ∈ `BleDeviceCatalog.phototherapyNames` + parser | 默认空 profile |

Pump 配置要点：

```swift
BleConfiguration(
    matching: BleParserValidatedMatchingStrategy(parser: pumpParser),
    writeQueue: .serialized(
        ackMatcher: BlePumpAckMatcher(),
        defaultTimeout: 3,
        order: .descending
    ),
        parser: pumpParser,
    logTag: "[Ble/Pump]"
)
```

---

## GATT UUID（`BleGattUUID`）

与固件约定；按通道职责命名，不含机型代号。

| 常量 | 说明 |
|------|------|
| `primary` | 短 UUID 主链路透传（AF00 / AF01 / AF02） |
| `extended` | 128-bit 主链路透传（与 `primary` 同职责） |
| `secondary` | 128-bit 次通道（埋点 / 上报） |
| `ota` | OTA / RCSP（AE00 / AE01 / AE02，尚未接入） |

广播 `deviceType`（byte[1]）→ 连接 GATT：

| deviceType | GATT |
|------------|------|
| `0x08`, `0x09` | `extended` |
| 其他 | `primary` |

实现：`BleProtocolParseResult` 遵循 `BleProvidesGattProfile`。

---

## Pump ACK 匹配（`BlePumpAckMatcher`）

写队列**只**调用 `ackMatcher.matches`：

- 帧头 `0xAA 0x55`
- `CT` 为 ACK(`0x01`) 或 NACK(`0x02`)（真机 FD 可能回 NACK；只认 ACK 会超时，但 Notify 仍进调试页）
- `CID` 与当前写指令一致

见 `BlePumpProtocol.swift`。

---

## 指令解析打印（`BlePumpTrace`）

解析与打印都在 App 层（`BlePumpTrace`），不改 AppStart。

| 方向 | CID | 输出 |
|------|-----|------|
| 发送 | C0 | 状态 / 模式 / 档位 / 自定义 |
| 发送 | F0 / FD / F7 / B0 | 鉴权码 / 查询加密 / 三元组 / 状态 |
| 接收 | F0 | 产品型号（`0xNN`）/ 版本 / SN / 满奶 / 加密 |
| 接收 | B0、D0 | 电量 / 状态 / 左右 / 模式 / 时间等 |
| 接收 | FD、F7 | 加密 key / 三元组（握手对照） |

连接调试页 Notify / 写指令在 hex 行后追加同一格式；`appendLog` 同时写入 `LogM.tag("Ble/Pump")`（Xcode 终端）。

```
<<< 接收数据解析: (设备名) | F0 | [产品型号=0x01 软件版本=20 SN码=… encrypted=false key=0x36]
```

---

## 配网握手（F0 · FD · F7）

连接就绪后，Demo 调用：

```swift
try await BlePumpHandshake.run(on: connection) { log($0) }
```

### 两层决策

| 层 | 职责 | 来源 |
|----|------|------|
| **Profile** | 产品典型链路（是否含 FD / F7） | F0 `productType` → `BlePumpProvisionProfile.resolve` |
| **F0 加密字段** | FD 是否**实发** | `BlePumpF0Info.needsFD` |

### productType → Profile

`productType` 与广播 `deviceType` 同码：

| productType | Profile |
|-------------|------|
| `0x10`, `0x11` | `f0` |
| `0x01`, `0x03`, `0x04` | `f0_fd` |
| `0x05`, `0x06`, `0x08`, `0x09`, `0x16` | `f0_f7` |
| `0x07` | `f0_fd_f7` + 副通道埋点 |
| 其他 | 默认 `f0_fd` |

### 执行顺序

```
F0 → resolve(productType) → (allowsFD && needsFD ? FD : 跳过) → (includesF7 ? F7)
```

- **needsFD**：F0 已加密或 key==0 → 跳过 FD；否则带 key 发 FD，回包只看 CT 是否 ACK
- **FD 请求**：真机 `fdOpenEncrypt(key)`（CAL=1，CAB=F0 key）；空查询 `fdQuery()` 会被部分固件 NACK（`CT=0x02`）
- **F7**：三元组（productKey / deviceKey / secretKey）
- **B0**：连接后状态同步，不在配网链内

### Demo 与部分固件实现的差异（以协议文档为准）

- FD 门闩：协议驱动（`needsFD` + CAL=0 查询），不是「始终发 FD / key 写入 CAB」
- 真实设备若与协议文档不一致，需在真机验证后再调整

---

## 副通道埋点（R2）

`deviceType == 0x07` 的设备：**主链路透传**（`primary`）+ **128-bit 次通道**（`secondary`）并行；逻辑均在 App 层。

| 项 | 说明 |
|----|------|
| 识别 | 广播 `deviceType == 0x07` |
| 主 GATT 注册 | `BleProducts.pump`：`gattProfile: primary` |
| 附加 GATT merge | `BleProtocolParseResult.supplementaryGattProfiles`（0x07 → secondary） |
| Connect | `BleSession.connect(discovery:)` → `effectiveConfiguration` |
| 收上报 | `characteristicUpdates(matching: BleGattUUID.secondary.notifyUUID)` |
| 写附加通道 | `connection.write(..., to: BleGattUUID.secondary.writeUUID)` 或 `peripheral.writeValue` |
| 解析 | `BlePumpAnalyticsParser` |

框架只做：`supplementaryGattProfiles` 的 discover / subscribe，附加 Notify **不进**主 ACK；附加写用 `write(_:to:)`（非主 UUID 等同 direct）。

---

## 相关文档

- 框架 API：[AppStart/Ble/BLE_README.md](../../../../../../../AppStart/AppStart/Ble/BLE_README.md)
- 迭代规划：[AppStart/Ble/BLE_ROADMAP.md](../../../../../../../AppStart/AppStart/Ble/BLE_ROADMAP.md)
