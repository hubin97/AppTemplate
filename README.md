# AppTemplate

基础组件库，用于高效构建和定制 iOS 应用。  
A foundational component library for efficient development and customization of related applications.
Based on [AppStart](https://github.com/hubin97/AppStart).

## 更新日志


| 日期         | 更新内容                                           |
| ---------- | ---------------------------------------------- |
| 2026-08-05 | 分域路由 **AppRouterDemo**；升级 AppStart **0.2.1**   |
| 2026-08-03 | Agent 协作约定与 Prompt 模板                          |
| 2026-07-30 | 权限 Demo 改用 `snapshot(for:mode:)`，合并定位示例        |
| 2026-07-29 | 主题系统重构、AuthStatus 新 API；权限 Demo 本地网络示例         |
| 2026-07-28 | BLE 连接超时适配；Connectivity Demo 与 AppStart 依赖同步   |
| 2026-07-27 | 权限校验 / 网络连通性 Demo；Ble subspec 更名同步             |
| 2026-07-24 | 对接 AppStart 多产品 BLE Session API                |
| 2026-07-13 | 电池 / BLE / Lottie HUD 等 Functions 演示页；HUD 背景修复 |
| 2026-07-02 | ProgressHUD Lottie 集成与示例页                      |




## 迭代计划

> AppStart = 基础能力；AppTemplate = Demo 验证与接入样例。完成库能力后，在 Func 补对应演示页。



### AppStart · 基础库

**AuthStatus / 权限**

- [x] 扩展权限类型（通知、跟踪、Face ID 等）统一进 `snapshot(for:mode:)`
- [ ] 权限引导 UI 组件（跳转设置 + 说明文案模板）
- [ ] 批量查询性能优化（多权限页一次 snapshot）

**Connectivity / 网络**

- [ ] 蜂窝策略 `CellularDataPolicy` 场景补全与文档示例
- [ ] 自定义 L3 探测 URL / 超时 / 降级策略配置化
- [ ] Network 插件：用户态接口统一缓存策略（修复 NetworkPlugins FIXME）

**Ble**

- [ ] 连接状态 UI 绑定辅助（Observable / AsyncStream 封装供 VC 直接用）
- [ ] 多设备并发连接 Demo 级 API 边界梳理
- [ ] 写队列超时 / 重连策略可配置项补文档与默认值校准
- [ ] OTA / 固件分包写入扩展点（若产品需要）

**Navigator / 基座 UI**

- [ ] 深链 / Universal Link → `SceneProvider` 解析入口
- [ ] `NavigationController` 侧滑返回与 `interactivePopGesture` 边界（iOS 18+ FIXME）
- [ ] `NaviBar` 标题居中对称修正（左右按钮并存场景）
- [ ] `WKWebController`：`_blank` 新窗口、`debug` Safari 调试开关

**ProgressHUD / 工具**

- [ ] HUD 移除动画时序修复（避免业务异步移除导致闪烁）
- [ ] Logger 日志内容格式异常兼容（LoggerManager FIXME）
- [ ] 本地化 fallback：key 未命中时回退默认语言；阿拉伯语 RTL 完善
- [ ] `TextField` 编辑时多字符默认选中问题修复

---



### AppTemplate · Demo / 业务壳

**AppRouterDemo（分域路由实验）**

- [ ] 跨 Feature 读数据：Home 聚合卡片走 Protocol + DTO（非写死在 HomeViewModel）
- [ ] Route 参数校验 / 默认值（非法 `circleId` / `userId` 兜底页）
- [ ] `register(_:)` vs `registerAll()` 对比结论写入 Demo README
- [ ] 深链打开指定 Route 的 Demo 入口（验证可扩展性）
- [ ] 实验成熟后再评估：是否独立 Pod / 是否下沉 AppStart（当前 **不下沉**）

**BLE Demo**

- [ ] 多产品 Configuration 切换 UI（不只 Pump 一条链路）
- [ ] 连接失败 / 超时 / 重连状态机可视化
- [ ] 广播包解析结果展示页（对接 `BleAdvDataParser`）

**权限 / 连通性 Demo**

- [ ] Auth Demo：权限申请时机与 `Info.plist` 说明联动示例
- [ ] Connectivity Demo：弱网 / 无网 / 仅蜂窝策略切换实测面板

**存储 / 账号 / 基建**

- [ ] MMKV 迁移：`UserDefaults` / 旧 Cache 数据一次性迁移（MMKVManager TODO）
- [ ] AuthManager 钥匙串方案恢复或明确替代方案
- [ ] IAP Demo：购买恢复、订阅状态查询补全

**UI / 主题 / 工具**

- [ ] 夜间模式与主题 Token 全页扫一遍（Tab / Func / 各 Demo）
- [ ] Battery 组件更多形态（充电态、低电量阈值样式）
- [ ] ImageDecoder：WebP / 动图解码性能与内存对比 Demo 完善

---



### 联动特性（库 + Demo 成对交付）

- [ ] AppStart 新 subspec 能力 → Func 列表可点通 + README 更新日志一行
- [ ] AppRouter 实验项与 AppStart `Navigator` 文档互链（说明分工边界）
- [ ] Ble Session 新 API → AppTemplate `BleAppConfiguration` 同步示例
- [ ] AuthStatus 新权限位 → AuthPermissionDemo 新分组展示