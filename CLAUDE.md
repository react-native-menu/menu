# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What this is

`@react-native-menu/menu` — a React Native native-UI library exposing a single component, `MenuView`. It maps to `UIMenu`/`UIContextMenuInteraction` on iOS 14+, `UIAlertController` (action sheet) on iOS 13, and `PopupMenu` on Android. There is no JS-only implementation; nearly all behavior lives in Swift/Obj-C++ and Kotlin.

## Commands

Yarn 4 (Berry, `nodeLinker: node-modules`), Node 22.11.0 (see `.tool-versions`).

```sh
yarn bootstrap     # install deps + generate the react-native-test-app Android manifest (required before Android builds)
yarn typescript    # tsc --noEmit
yarn lint          # biome lint --write .   (auto-fixes; CI runs the same command)
yarn format        # biome format --write .
yarn test          # jest
yarn test src/__tests__/index.test.tsx   # single file
yarn test -t "pattern"                   # single test by name
yarn start         # Metro for the example app
yarn android       # run example app on Android
yarn ios           # run example app on iOS
yarn pods          # pod-install in example/
yarn prepare       # bob build -> lib/ (commonjs, module, typescript)
```

Note: despite the CI step name "ESLint Checks", linting/formatting is **Biome** (`biome.json`): tabs for indentation, double quotes. There is no ESLint config.

Only the JS side has meaningful CI unit tests (`src/__tests__/index.test.tsx` is a placeholder). CI validation of native code is compilation: `example/android && ./gradlew clean assembleDebug`, and `xcodebuild -scheme ReactTestApp -workspace MenuExample.xcworkspace` for both `RCT_NEW_ARCH_ENABLED=1` and `=0`.

The example app is built with [`react-native-test-app`](https://github.com/microsoft/react-native-test-app) — there is no checked-in Xcode project or Android app module; `yarn bootstrap` + `yarn pods` generate them. `react-native.config.js` and `metro.config.js` point the CLI/Metro at the repo root so the library autolinks into `example/`.

## Architecture

### JS layer (`src/`)

`src/index.tsx` is the only public entry. It is a thin wrapper that:
1. Runs `processColor` over `titleColor`/`imageColor` recursively (so native receives ints, not RN color strings).
2. Computes `actionsHash` via `src/utils.ts` (`objectHash` = JSON.stringify + string hash) and passes it as a prop.

`actionsHash` exists because on the new architecture `actions` is a C++ struct array that is painful to deep-compare; native code compares the hash string to decide whether the menu needs rebuilding. **Any new field added to `MenuAction` is automatically covered** since the hash is over the whole processed array — but it must be added in both type locations (below).

Platform resolution is by file extension, resolved by Metro:
- `src/UIMenuView.ios.tsx` → re-exports the codegen'd native component directly.
- `src/UIMenuView.android.tsx` → `requireNativeComponent("MenuView")` plus an imperative `show()` ref. It dispatches via `codegenNativeCommands` when `global.nativeFabricUIManager` is set, and falls back to `UIManager.dispatchViewManagerCommand` on the old architecture. `show()` is Android-only.
- `src/UIMenuView.tsx` → inert `View` fallback (web/other platforms); menu behavior is a TODO there.

**Two parallel type definitions, deliberately:**
- `src/types.ts` — the public, documented API (`MenuAction`, `MenuComponentProps`, `MenuComponentRef`). Uses RN types like `ColorValue`.
- `src/NativeModuleSpecs/UIMenuNativeComponent.ts` — the **codegen spec**. These are not just TS types; codegen turns them into C++/Java/ObjC structs. Codegen does not handle type reuse or interface extension well, so `SubAction`/`MenuAction` are duplicated inline there on purpose. Do not "DRY up" this file. Adding a prop means editing both files, then re-running `pod install` / a Gradle build to regenerate `RNMenuViewSpec` (`codegenConfig` in `package.json`).

### iOS (`ios/`)

Three directories split by architecture, with the actual menu logic shared:
- `ios/Shared/` — architecture-agnostic implementations. `MenuViewImplementation.swift` (a `UIButton` with `UIContextMenuInteraction`, iOS 14+), `ActionSheetView.swift` (iOS 13 fallback), `RCTMenuItem.swift` (converts an action `NSDictionary` into a `UIMenuElement`), `RCTAlertAction.swift`.
- `ios/NewArch/` — `MenuView.mm` is the Fabric component view (`RCTMenuViewViewProtocol`); it holds a child `UIView <FabricViewImplementationProtocol>` and forwards props. `FabricMenuViewImplementation.swift` / `FabricActionSheetView.swift` subclass the shared implementations.
- `ios/OldArch/` — `Legacy*` subclasses of the same shared implementations.
- `ios/MenuViewManager.mm` — old-arch `RCTViewManager` with the `RCT_EXPORT_VIEW_PROPERTY` list; also `#ifdef RCT_NEW_ARCH_ENABLED`-guarded for the new arch. Prop exports here must stay in sync with the codegen spec.
- `FabricViewImplementationProtocol.swift` is the seam both arch-specific view wrappers program against — add a prop there when it must reach both the menu and action-sheet implementations.
- Swift is exposed to Obj-C++ via `react_native_menu-Swift.h`; new Swift API needs `@objc public`. Bridging header: `ios/Menu-Bridging-Header.h`.

### Android (`android/`)

`MenuView.kt` (a `ReactViewGroup`) owns the `PopupMenu`, gesture detection (tap vs. long press), the touch delegate for `hitSlop`, and drawable/color resolution. It is architecture-independent.

The view *manager* is split three ways, wired up by `sourceSets` in `android/build.gradle`:
- `MenuViewManagerBase.kt` (`src/main/`) — all `@ReactProp` setters and event constants.
- `src/newarch/MenuViewManagerSpec.kt` vs `src/oldarch/MenuViewManagerSpec.kt` — new arch implements the codegen'd `MenuViewManagerInterface` + delegate.
- `src/reactNativeVersionPatch/MenuViewManager/{75,latest}/…/MenuViewManager.kt` — the concrete manager, selected by React Native minor version (`<= 75` vs. newer). This exists because RN changed `setBorderColor`'s signature.

New architecture is force-enabled when RN minor >= 82; otherwise it follows the app's `newArchEnabled`.

**When making a RN-version-dependent Android change**, put it in *both* `reactNativeVersionPatch` folders and register any new source directory in `android/build.gradle`'s `sourceSets` (see CONTRIBUTING.md).

### Expo config plugin (`plugin/withAndroidDrawables.js`)

Copies custom drawable XML from an app's `assets/` into `android/app/src/main/res/drawable` so `MenuAction.image` can reference project icons. It is documented for users to copy into their own app, not published as a plugin entry point.

## Conventions

- Conventional commits (`fix:`, `feat:`, `refactor:`, `docs:`, `test:`, `chore:`) — release notes are generated from them by `release-it` + `@release-it/conventional-changelog`.
- Public prop changes should be reflected in the README's Reference section; it is the only API documentation.
- `lib/` is build output (gitignored, ignored by Biome and Jest) — never edit it.
