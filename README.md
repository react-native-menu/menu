# @react-native-menu/menu

![Supports Android, iOS][support-badge]![Github Action Badge][gha-badge] ![npm][npm-badge]

Android PopupMenu and iOS14+ UIMenu components for react-native.
Falls back to ActionSheet for versions below iOS14.

| iOS 14+                                                                                                                       | iOS 13                                                                                                                        |
| ----------------------------------------------------------------------------------------------------------------------------- | ----------------------------------------------------------------------------------------------------------------------------- |
| <img src="https://user-images.githubusercontent.com/6936373/98471164-cf328780-222d-11eb-9cbc-7dcda474fc8a.png" width="320" /> | <img src="https://user-images.githubusercontent.com/6936373/98471162-cb9f0080-222d-11eb-89ef-9342a1f10893.png" width="320" /> |

## Installation

via npm:

```sh
npm install @react-native-menu/menu
```

via yarn:

```sh
yarn add @react-native-menu/menu
```

### Installing on iOS with React Native 0.63

There is an issue(https://github.com/facebook/react-native/issues/29246) causing projects with this module to fail on build on React Native 0.63.
This issue may be fixed in future versions of react native.
As a work around, look for lines in `[YourPrject].xcodeproj` under `LIBRARY_SEARCH_PATHS` with `"\"$(TOOLCHAIN_DIR)/usr/lib/swift-5.0/$(PLATFORM_NAME)\"",` and change `swift-5.0` to `swift-5.3`.

## Linking

The package is [automatically linked](https://github.com/react-native-community/cli/blob/master/docs/autolinking.md) when building the app. All you need to do is:

```sh
npx pod-install
```

## Usage

```jsx
import { MenuView } from '@react-native-menu/menu';

// ...

const App = () => {
  return (
    <View style={styles.container}>
      <MenuView
        title="Menu Title"
        onPressAction={({ nativeEvent }) => {
          console.warn(JSON.stringify(nativeEvent));
        }}
        actions={[
          {
            id: 'add',
            title: 'Add to List',
            image: 'plus',
          },
          {
            id: 'share',
            title: 'Share Action',
            subtitle: 'Share action on SNS',
            image: 'square.and.arrow.up',
            state: 'on',
          },
          {
            id: 'destructive',
            title: 'Destructive Action',
            attributes: {
              destructive: true,
            },
            image: 'trash',
          },
        ]}
      >
        <View style={styles.button}>
          <Text style={styles.buttonText}>Test</Text>
        </View>
      </MenuView>
    </View>
  );
};
```

## Reference

### Props

### `title` (iOS only)

The title of the menu.

| Type   | Required |
| ------ | -------- |
| string | No       |

### `actions`

Actions to be displayed in the menu.

| Type         | Required |
| ------------ | -------- |
| MenuAction[] | Yes      |

#### `MenuAction`

Object representing Menu Action.

```ts
export type MenuAction = {
  /**
   * Identifier of the menu action.
   * The value set in this id will be returned when menu is selected.
   */
  id?: string;
  /**
   * The action's title.
   */
  title: string;
  /**
   * (iOS14+ only)
   * An elaborated title that explains the purpose of the action.
   */
  subtitle?: string;
  /**
   * (iOS only)
   * The attributes indicating the style of the action.
   */
  attributes?: MenuAttributes;
  /**
   * (iOS14+ only)
   * The state of the action.
   */
  state?: MenuState;
  /**
   * (iOS13+ only)
   * - The action's image.
   * - Allows icon name included in SF Symbol
   * - TODO: Allow images other than those included in SF Symbol
   */
  image?: string;
};
```

#### `MenuAttributes`

The attributes indicating the style of the action.

```ts
type MenuAttributes = {
  /**
   * An attribute indicating the destructive style.
   */
  destructive?: boolean;
  /**
   * An attribute indicating the disabled style.
   */
  disabled?: boolean;
  /**
   * An attribute indicating the hidden style.
   */
  hidden?: boolean;
};
```

#### `MenuState`

The state of the action.

```ts
/**
 * The state of the action.
 * - off: A constant indicating the menu element is in the “off” state.
 * - on: A constant indicating the menu element is in the “on” state.
 * - mixed: A constant indicating the menu element is in the “mixed” state.
 */
type MenuState = 'off' | 'on' | 'mixed';
```

### `onPressAction`

Callback function that will be called when selecting a menu item.
It will contain id of the given action.

| Type                    | Required |
| ----------------------- | -------- |
| ({nativeEvent}) => void | No       |

## Contributing

See the [contributing guide](CONTRIBUTING.md) to learn how to contribute to the repository and the development workflow.

## License

MIT

[gha-badge]: https://github.com/react-native-menu/menu/workflows/Build/badge.svg
[npm-badge]: https://img.shields.io/npm/v/@react-native-menu/menu.svg?style=flat-square
[support-badge]: https://img.shields.io/badge/platforms-android%20|%20ios-lightgrey.svg?style=flat-square
