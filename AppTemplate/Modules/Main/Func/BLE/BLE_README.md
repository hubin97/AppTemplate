# AppTemplate · BLE 业务层

Pump / TempPatch / Phototherapy 等产品协议与 Demo UI，基于 [AppStart BLE](../../../../../../AppStart/AppStart/Ble/BLE_README.md) 框架。

> 框架负责：扫描、连接、GATT、串行写队列、`BleAckMatcher` 协议。  
> 本文档负责：0xAA 协议、GATT UUID、配网握手、产品注册。

---

## 文件

| 文件 | 职责 |
|------|------|
| `BleAppConfiguration.swift` | 产品 `BleConfiguration` 注册（含 GATT）、状态格式化 |
| `BleProtocolParsers.swift` | 广播解析、`BleGattUUID`、动态 `bleGattProfile`、M5 副通道 payload |
| `BlePumpProtocol.swift` | 0xAA 帧解析、`BlePumpAckMatcher`、F0/FD/F7 模型 |
| `BlePumpCommand.swift` | 组包（F0 / FD / F7 / C0 等） |
| `BleProvisionHandshake.swift` | 配网握手编排 |
| `BleScanController.swift` / `BleConnectionController.swift` | Demo UI |

---

## 产品注册

入口 `BleAppConfiguration.setup()` → `BleSession.shared.register(BleProducts.all)`。

| 产品 | 匹配 | GATT |
|------|------|------|
| Pump | `BleParserValidatedMatchingStrategy` + 0xAA 厂商数据 | connect 时由 parser `bleGattProfile` merge |
| TempPatch | LocalName `T31` + parser | 默认空 profile |
| Phototherapy | LocalName `Lumi 1` + parser | 默认空 profile |

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
| `secondary` | 128-bit 次通道（埋点 / 上报，M5 等） |
| `ota` | OTA / RCSP（AE00 / AE01 / AE02，尚未接入） |

广播 `deviceType`（byte[1]）→ 连接 GATT：

| deviceType | GATT |
|------------|------|
| `0x08`, `0x09` | `extended` |
| 其他 | `primary` |

实现：`BleProtocolParseResult` 遵循 `BleProvidesGattProfile`。

---

## Pump ACK 匹配（`BlePumpAckMatcher`）

写队列**只**调用 `ackMatcher.matches`；REQ 形设备上报与写 ACK 的区分在业务层完成：

- 帧头 `0xAA 0x55`
- `CT == 0x01`（ACK）
- `CID` 与当前写指令一致

见 `BlePumpProtocol.swift`。

---

## 配网握手（F0 · FD · F7）

连接就绪后，Demo 调用：

```swift
try await BleProvisionHandshake.run(on: connection) { log($0) }
```

### 两层决策

| 层 | 职责 | 来源 |
|----|------|------|
| **Profile** | 产品典型链路（是否含 FD / F7） | F0 `productType` → `BleProvisionProfile.resolve` |
| **F0 加密字段** | FD 是否**实发** | `BlePumpF0Info.needsFD` |

### productType → Profile

`productType` 与广播 `deviceType`、Momcozy `PType` 同码：

| productType | 机型 | Profile |
|-------------|------|---------|
| `0x10`, `0x11` | W1 / M10, W1Lite | `f0` |
| `0x01`, `0x03`, `0x04` | M9, Air1, Air2 | `f0_fd` |
| `0x05`, `0x06`, `0x08`, `0x09`, `0x16` | M9Pro, M8, V3, V3Pro, M8Pro | `f0_f7` |
| `0x07` | M5Pro | `f0_fd_f7` + 副通道埋点 |
| 其他 | 未知 | 默认 `f0_fd` |

### 执行顺序

```
F0 → resolve(productType) → (allowsFD && needsFD ? FD : 跳过) → (includesF7 ? F7)
```

- **needsFD**：F0 无加密且 key ∈ 1…127；已加密则跳过 FD
- **FD 请求**：协议 3.1.6，`fdQuery()`（CAL=0）；应答 CAB[0] 状态 + CAB[1] key
- **F7**：三元组（productKey / deviceKey / secretKey）
- **B0**：连接后状态同步，不在配网链内

### 与 Momcozy 的差异（Demo 按协议文档）

- FD 门闩：协议驱动（`needsFD` + CAL=0 查询），非 Momcozy 侧「始终发 FD / key 写入 CAB」
- 真实设备若与协议文档不一致，需在真机验证后再调整

---

## M5 副通道埋点（R2）

M5 类设备：**主链路透传**（`primary`）+ **128-bit 次通道**（`secondary`）并行；逻辑均在 App 层。

| 项 | 说明 |
|----|------|
| 识别 | 广播 `deviceType == 0x07`（M5 等） |
| 主 GATT 注册 | `BleProducts.pump`：`gattProfile: primary` |
| 附加 GATT merge | `BleProtocolParseResult.supplementaryGattProfiles`（0x07 → secondary） |
| Connect | `BleSession.connect(discovery:)` → `effectiveConfiguration` |
| 收上报 | `characteristicUpdates(matching: BleGattUUID.secondary.notifyUUID)` |
| 写附加通道 | `connection.write(..., to: BleGattUUID.secondary.writeUUID)` 或 `peripheral.writeValue` |
| 解析 | `BlePumpAnalyticsParser` |

框架只做：`supplementaryGattProfiles` 的 discover / subscribe，且附加 Notify **不进**主 ACK 队列。

---

## 相关文档

- 框架 API：[AppStart/Ble/BLE_README.md](../../../../../../AppStart/AppStart/Ble/BLE_README.md)
- 迭代规划：[AppStart/Ble/BLE_ROADMAP.md](../../../../../../AppStart/AppStart/Ble/BLE_ROADMAP.md)
