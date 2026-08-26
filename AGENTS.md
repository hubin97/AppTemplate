# AppTemplate Agent 指南

## 项目定位

消费 `AppStart` 的 Demo / 示例 App，用于验证与展示基础库能力。

## 与 AppStart 的关系

- 本地常与 `AppStart`（私有库）并列放在同一工作区父目录，但二者是**独立 git 仓库**
- 改可复用能力 / 内核 → `AppStart` 仓库
- 改演示页 / 接入示例 / 产品 UI → 本仓库
- 不要把应下沉的库逻辑长期留在 Demo；不要直接改 `Pods/` 里的库拷贝作为正式方案

## 目录

- 应用入口：`AppTemplate/Application/`
- 功能 Demo：`AppTemplate/Modules/Main/Func/`
- 通用组件示例：`AppTemplate/Components/`
- BLE App 侧配置与演示：`AppTemplate/Modules/Main/Func/BLE/`（`DeviceManager` / `Support` / `Discovery` / `BoundList` / `Panel` / `Console`）

## 编码与接入约定

- 优先复用 AppStart 已有 API，不要在 App 内再实现一套平行内核
- Demo 代码以「可读、可点通」为先，避免过度抽象
- 产品名、文案、路由留在 App 侧
- UI 跟现有 Theme / 页面风格一致，不引入无关依赖
- BLE：库侧协议与连接能力用 AppStart；App 侧维护 Configuration 注册、展示与 Demo 页

## 何时补 Demo

当 AppStart 新增公开能力且用户确认需要示例时：

1. 在 `Modules/Main/Func/`（或对应模块目录）增加/更新 Demo 页
2. 如有入口列表（Func 列表），补上可进入的入口
3. Demo 只演示用法；可复用逻辑仍应回到 AppStart

## 修改边界

- 默认只改 `AppTemplate/`
- 需要改库能力时，应明确说「同时改 AppStart」，或拆成两个任务
- 不要直接改 `Pods/` 里的 AppStart 拷贝作为长期方案（应改 AppStart 源码仓）

## Definition of Done

- [ ] Demo 可编译、路径可到达
- [ ] 展示了关键 API / 配置用法
- [ ] 未把应下沉的库逻辑留在 Demo 里（除非临时验证并已说明）
