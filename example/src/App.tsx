import * as React from 'react';
import { StyleSheet, Text, View } from 'react-native';
import MenuView from 'react-native-menu';

export default function App() {
  return (
    <View style={styles.container}>
      <MenuView
        menuTitle="Menu Title Test"
        style={{ flex: 1, justifyContent: 'center' }}
        onPressAction={({ nativeEvent }) => {
          console.warn(JSON.stringify(nativeEvent));
        }}
        actions={[
          {
            id: 'testId',
            title: 'testTitle',
            image: 'image',
          },
        ]}
      >
        <View
          style={{
            height: 100,
            width: 100,
            backgroundColor: 'red',
            borderRadius: 50,
            justifyContent: 'center',
            alignItems: 'center',
          }}
        >
          <Text style={{ color: 'white' }}>Test</Text>
        </View>
      </MenuView>
    </View>
  );
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    alignItems: 'center',
    justifyContent: 'center',
  },
});
