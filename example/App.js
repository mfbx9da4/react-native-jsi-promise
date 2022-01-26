import * as React from 'react';

import {StyleSheet, Text, TouchableOpacity} from 'react-native';
import jsiPromise from 'react-native-jsi-promise';

export default function App() {
  const [result, setResult] = React.useState('initial');

  return (
    <TouchableOpacity
      style={styles.container}
      onPress={async () => {
        const start = Date.now();
        const res = await jsiPromise.foo();
        setResult(`${res} (${Date.now() - start}ms)`);
      }}>
      <Text>Result: {result}</Text>
    </TouchableOpacity>
  );
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    alignItems: 'center',
    justifyContent: 'center',
    padding: 20,
    backgroundColor: 'gold',
  },
  box: {
    width: 60,
    height: 60,
    marginVertical: 20,
  },
});
