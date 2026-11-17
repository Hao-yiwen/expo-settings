# expo-settings

[![npm version](https://img.shields.io/badge/version-0.1.0-blue.svg)](package.json)
[![Expo SDK](https://img.shields.io/badge/Expo%20SDK-52-000020.svg)](https://docs.expo.dev/versions/v52.0.0/)
[![React Native](https://img.shields.io/badge/React%20Native-0.76-61DAFB.svg)](https://reactnative.dev/)
[![license](https://img.shields.io/badge/license-MIT-green.svg)](package.json)

本地 Expo 原生模块。iOS 端把 Markdown 字符串交给预编译的 [MarkdownUI](https://github.com/gonzalezreal/swift-markdown-ui) 渲染成 SwiftUI 视图；示例应用逐字追加一段 Markdown，用来观察原生视图的高度更新。

仓库从 `create-expo-module` 脚手架生成（包描述仍是 `My new module`）。iOS 已接上 Markdown 渲染，Android 仍是脚手架生成的 WebView。包名 `expo-settings` 与 Expo SDK 里的其他模块无关，旧 README 指向的 `docs.expo.dev` settings 文档不描述本仓库。

## 已有内容

### JavaScript 接口

`src/index.ts` 导出：

| 导出 | 说明 |
| --- | --- |
| 默认导出 | `requireNativeModule('ExpoSettings')` |
| `ExpoSettingsView` | 原生视图组件 |
| `ExpoSettingsViewProps`、`OnLoadEventPayload` | 视图 props 与 `onLoad` 事件载荷类型 |

`ExpoSettingsView` 的 props（`src/ExpoSettings.types.ts`）：

| Prop | 类型 | 说明 |
| --- | --- | --- |
| `content` | `string` | 要显示的 Markdown |
| `onLoad` | `(event: { nativeEvent: { status: string } }) => void` | 类型上声明了加载回调 |
| `style` | `StyleProp<ViewStyle>` | 传给原生视图的样式 |

`src/ExpoSettingsModule.ts` 还声明了同步常量 `PI`、同步方法 `hello(): string`、异步方法 `setValueAsync(value: string): Promise<void>`。这三个成员只在 Android 原生模块里实现。

### iOS

`ios/ExpoSettingsView.swift` 用 `UIHostingController` 承载 SwiftUI：

- 读取 `content`，以 MarkdownUI 的 GitHub 主题渲染（`.markdownTheme(.gitHub)`）。
- 按内容 `sizeThatFits` 调整视图高度，额外加 20pt，动画时长 0.2 秒。
- 高度刷新间隔 0.2 秒。
- 模块定义了 `onLoad` 事件，Swift 代码里没有调用 `onLoad`。
- 原生模块没有实现 `PI`、`hello`、`setValueAsync`。

`ios/ExpoSettings.podspec` 以 vendored xcframework 链入：

| 框架 | 仓库中的位置 | Info.plist |
| --- | --- | --- |
| `MarkdownUI.xcframework` | 有。真机 `ios-arm64`，模拟器 `ios-arm64_x86_64-simulator` | `CFBundleShortVersionString` 1.0，`MinimumOSVersion` 15.0 |
| `cmark_gfm.xcframework` | 有 | `CFBundleShortVersionString` 1.0，`MinimumOSVersion` 18.0 |
| `cmark_gfm_extensions.xcframework` | 有 | `CFBundleShortVersionString` 1.0，`MinimumOSVersion` 18.0 |
| `NetworkImage.xcframework` | podspec 引用了该路径，`ios/` 下没有这个目录 | — |

Pod 平台声明为 iOS / tvOS 15.1，Swift 5.4。cmark 两个框架的 `MinimumOSVersion` 写的是 18.0，和 podspec 的 15.1 不一致。

### Android

`android/src/main/java/expo/modules/settings/ExpoSettingsModule.kt` 仍是脚手架实现：

- 常量 `PI`。
- `hello()` 返回 `"Hello world! 👋"`。
- `setValueAsync(value)` 向 JS 发送 `onChange`，载荷为 `{ value }`。
- 视图属性名是 `url`（`java.net.URL`），内部 `WebView.loadUrl`。页面结束后 `onLoad` 回传的字段是 `url`，与 TypeScript 里的 `status` 不一致。
- 库的 `compileSdk` / `targetSdk` 为 34，`minSdk` 为 21。

### 示例应用

`example/App.tsx` 把一段包含标题、粗体、斜体、Swift 代码块和列表的 Markdown，每 50ms 追加一个字符，传给 `ExpoSettingsView`。容器背景为 `#eee`，内容区高度写死 700。

示例工程已包含 `ios/` 与 `android/`，开启 New Architecture 与 Hermes。应用标识：

- iOS bundle id：`expo.modules.settings.example`
- Android applicationId：`expo.modules.settings.example`

仓库里没有功能截图。`example/assets/` 只有 Expo 模板自带的 `icon.png`、`splash-icon.png`、`adaptive-icon.png`、`favicon.png`。

## 技术栈

版本取自 `package.json` 与 lockfile。

| 位置 | 依赖 | 版本 |
| --- | --- | --- |
| 模块 `devDependencies` | `expo` | `~52.0.0`，lock 解析为 52.0.25 |
| 模块 `devDependencies` | `react-native` | 0.76.0 |
| 模块 `devDependencies` | `expo-module-scripts` | 4.0.3 |
| 模块 `devDependencies` | `@types/react` | `~18.3.12`，lock 解析为 18.3.18 |
| 模块 `peerDependencies` | `expo`、`react`、`react-native` | `*` |
| 示例 | `expo` | 52.0.25 |
| 示例 | `react` | 18.3.1 |
| 示例 | `react-native` | 0.76.6 |
| 示例 | `typescript` | 5.7.3 |
| 示例 | `@babel/core` | lock 解析为 7.26.0 |
| 示例 Android | Gradle | 8.10.2 |
| 示例 Android | Kotlin | 1.9.24 |
| 示例 Android | `minSdk` / `compileSdk` / `targetSdk` | 24 / 35 / 34 |
| 示例 Android | NDK | 26.1.10909125 |

模块和示例的 React Native 版本不同（0.76.0 与 0.76.6）。`example/metro.config.js` 在打包时排除父目录的 `react` 与 `react-native`，改用示例自己的 `node_modules`。

## 目录结构

```text
.
├── src
│   ├── index.ts                 # 导出模块、视图和类型
│   ├── ExpoSettingsModule.ts    # requireNativeModule('ExpoSettings')
│   ├── ExpoSettingsView.tsx     # requireNativeView('ExpoSettings')
│   └── ExpoSettings.types.ts    # content / onLoad / style
├── ios
│   ├── ExpoSettingsModule.swift
│   ├── ExpoSettingsView.swift   # MarkdownUI 渲染与高度节流
│   ├── ExpoSettings.podspec
│   ├── ExpoSettings.modulemap
│   ├── MarkdownUI.xcframework
│   ├── cmark_gfm.xcframework
│   └── cmark_gfm_extensions.xcframework
├── android
│   ├── build.gradle
│   └── src/main/java/expo/modules/settings
│       ├── ExpoSettingsModule.kt
│       └── ExpoSettingsView.kt  # WebView
├── example                      # 独立 package，原生工程已生成
│   ├── App.tsx
│   ├── index.ts
│   ├── app.json
│   ├── metro.config.js          # 把 expo-settings 指到上级目录
│   ├── ios
│   └── android
├── expo-module.config.json      # Apple / Android 模块类名
├── package.json                 # main 指向 build/index.js
└── tsconfig.json                # 编译 src 到 build/
```

`package.json` 的 `main` 是 `build/index.js`，`types` 是 `build/index.d.ts`。`build/` 被 `.gitignore` 忽略，需要本地编译后才有产物。

示例通过这三处接到本模块，没有把 `expo-settings` 写进自己的 `dependencies`：

- `example/package.json` 的 `expo.autolinking.nativeModulesDir` 为 `..`
- `example/metro.config.js` 的 `extraNodeModules['expo-settings']` 为上级目录
- `example/tsconfig.json` 的 `paths` 把 `expo-settings` 指到 `../src/index`

## 环境要求

- Node.js 与 npm。`package.json` 没有 `engines` 字段。本次验证使用 Node.js 22.23.4、npm 10.9.9。
- 系统里的 `rsync`。`expo-module prepare` 的配置脚本会调用它。
- 跑 iOS：macOS、Xcode、CocoaPods。示例部署目标来自 `example/ios/Podfile`，默认 15.1；同时注意上文 cmark 框架的 `MinimumOSVersion` 18.0。
- 跑 Android：Android SDK、JDK。示例 Gradle 使用 JDK；本环境有 OpenJDK 21，没有设置 `ANDROID_HOME`。
- 自定义原生代码不能在 Expo Go 里加载。示例需要本机的开发构建（`expo run:ios` 或 `expo run:android`），Metro 只负责 JS。

## 安装与运行

### 编译模块

在仓库根目录：

```bash
npm ci
npm run build
```

`npm ci` 会执行 `prepare`，也就是 `expo-module prepare`，其中包含 TypeScript 编译。当前源码编译不过，两条命令都会停在同一种错误：

```text
src/ExpoSettingsModule.ts(3,10): error TS2305:
Module '"./ExpoSettings.types"' has no exported member 'ExpoSettingsModuleEvents'.
```

`ExpoSettingsModule.ts` 引入了 `ExpoSettingsModuleEvents`，`ExpoSettings.types.ts` 没有导出这个类型。`build/` 因此不会生成。根目录的 `npm run lint`、`npm test`、`npm run prepublishOnly` 都依赖 `expo-module-*`，本次没有在编译失败之后继续跑它们。仓库里也没有 `*.test.*` / `*.spec.*` 文件。

`npm run open:ios` 使用 `xed`，`npm run open:android` 使用 macOS 的 `open -a "Android Studio"`，只能在 macOS 上执行。

### 安装示例依赖

示例是独立包，需要单独安装：

```bash
cd example
npm ci
```

本次在 Linux 上执行 `example` 的 `npm ci` 成功（lockfileVersion 3，安装 874 个包）。

### 类型检查

```bash
cd example
npx tsc --noEmit
```

本次执行失败，共两处：

1. 上面的 `ExpoSettingsModuleEvents` 缺失（`tsconfig` 的 `paths` 直接检查 `../src`）。
2. `example/App.tsx` 的 `styles.view` 是普通对象，`justifyContent: "flex-start"` 被推断成 `string`，不能赋给 `ViewStyle`。

### 启动 Metro

```bash
cd example
npm start
```

对应 `expo start`。JS 入口解析到包的 `main`（`build/index.js`）。在根目录编译成功、生成 `build/` 之前，示例打包找不到模块入口。本次没有启动 Metro。

Web 脚本是 `npm run web`（`expo start --web`）。仓库没有 `src/ExpoSettingsModule.web.ts`（`src/index.ts` 的注释提到这个文件）。`example/webpack.config.js` 依赖 `@expo/webpack-config`，该包不在示例 lockfile 里。本次没有跑 Web。

### iOS 开发构建

在 macOS 上，依赖安装且 `build/` 生成之后：

```bash
cd example
npm run ios
```

对应 `expo run:ios`。`example/ios/Podfile` 已通过 Expo autolinking 引入 `ExpoSettings`（`Podfile.lock` 中为 `ExpoSettings (from ../../ios)`，版本 0.1.0）。本机是 Linux，没有 Xcode，未执行 `pod install` 或 iOS 编译。podspec 列出的 `NetworkImage.xcframework` 不在仓库中，iOS `pod install` / 编译是否通过需要在 macOS 上确认。

### Android 开发构建

安装 Android SDK 后：

```bash
cd example
npm run android
```

对应 `expo run:android`。本次没有 Android SDK，未执行 Gradle 构建。即使构建通过，Android 视图读取的是 `url` 并加载 WebView；示例传入的 `content` 在现有 Android 代码里没有对应 Prop。

## 在其他应用中使用

本仓库没有发布脚本产物，`package.json` 的 `repository`、`bugs`、`homepage` 仍指向 `https://github.com/binaryminds/react-native-sse`，与当前远程 `https://github.com/Hao-yiwen/expo-settings` 不一致。按当前文件，接入方式和示例相同：用 autolinking 指向本模块目录，并用 Metro 把包名 `expo-settings` 解析到该目录；原生名称是 `ExpoSettings`。

iOS 上与示例一致的调用：

```tsx
import { ExpoSettingsView } from "expo-settings";

<ExpoSettingsView
  content={markdown}
  onLoad={({ nativeEvent: { status } }) => console.log(status)}
  style={{ width: "100%", backgroundColor: "white" }}
/>
```

现有 iOS 实现不会发出 `onLoad`。Android 上这段 `content` 没有对应的原生属性。

## 参考

- [Expo Modules API](https://docs.expo.dev/modules/module-api/)
- [Expo SDK 52](https://docs.expo.dev/versions/v52.0.0/)
- [MarkdownUI](https://github.com/gonzalezreal/swift-markdown-ui)
- 作者字段：`yw.hao <yw.hao@trip.com>`（`package.json`）
- `package.json` 声明许可证为 MIT。仓库根目录没有 `LICENSE` 文件。
