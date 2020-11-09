import * as React from 'react';
import { StyleSheet, Text, View } from 'react-native';
import { MenuView } from '@react-native-menu/menu';

export const App = () => {
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
            id: 'mixed',
            title: 'Mixed State',
            subtitle: 'State is mixed',
            image: 'heart.fill',
            state: 'mixed',
          },
          {
            id: 'disabled',
            title: 'Disabled Action',
            subtitle: 'Action is disabled',
            attributes: {
              disabled: true,
            },
            image: 'tray',
          },
          {
            id: 'hidden',
            title: 'Hidden Action',
            subtitle: 'Action is hidden',
            attributes: {
              hidden: true,
            },
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

const styles = StyleSheet.create({
  container: {
    flex: 1,
    alignItems: 'center',
    justifyContent: 'center',
  },
  button: {
    height: 100,
    width: 100,
    backgroundColor: 'red',
    borderRadius: 50,
    justifyContent: 'center',
    alignItems: 'center',
  },
  buttonText: { color: 'white' },
});
