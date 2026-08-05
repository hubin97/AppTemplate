# AppRouterDemo — 分域路由

Feature 解耦实验（AppStart `Navigator` + `SceneProvider` + `ViewModel`）。

## 目录

| 目录 | 职责 |
|------|------|
| `Core/` | `AppRouter` / `RouteRegister` / `AppRouterBootstrap` |
| `Features/Home` | Home 页 + `HomeViewModel` |
| `Features/Community` | 社区 Route + Register + 内部页 |
| `Features/Profile` | 个人主页 Route + Register + 内部页 |

## 新增 Feature

1. 定义 `enum XxxRoute: RouteKey` + `SceneProvider`
2. 写 `final class XxxRouteRegister: RouteRegister`，override `register(into:)`
3. 在 `Application.launch` 的 `AppRouterBootstrap.register([...])` 里追加 `XxxRouteRegister.self`

## 登记

```swift
AppRouterBootstrap.register([CommunityRouteRegister.self, ...])
AppRouterBootstrap.registerAll()  // 扫类，与 register(_:) 二选一
```

## 边界

- Home 跳转只依赖 `CommunityRoute` / `ProfileRoute`，不引用对方 VC / ViewModel

## 入口

Functions → **分域路由**
