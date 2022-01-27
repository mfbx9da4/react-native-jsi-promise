import * as React from 'react';

import {StyleSheet, Text, TouchableOpacity} from 'react-native';
import jsiPromise from 'react-native-jsi-promise';

/** Intercepts writes to any property of an object */
export function observeProperty(obj, property, onChanged, customDescriptor) {
  let val = obj[property];
  Object.defineProperty(
    obj,
    property,
    Object.assign(
      {
        get() {
          return val;
        },
        set(newVal) {
          val = newVal;
          onChanged(newVal);
        },
        enumerable: true,
        configurable: true,
      },
      customDescriptor,
    ),
  );
}

function FastExample() {
  const [state, setState] = React.useState({took: 0, result: 'initial'});

  return (
    <TouchableOpacity
      style={styles.fast}
      onPress={() => {
        const start = performance.now();
        const res = jsiPromise.foo(newVal => {
          setState({took: performance.now() - start, result: {...res}});
        });
      }}>
      <Text>
        {'Tap me, will always be fast: \n'}
        {JSON.stringify(state.result)} {state.took}
      </Text>
    </TouchableOpacity>
  );
}

function SlowExample() {
  const [state, setState] = React.useState({took: 0, result: 'initial'});

  return (
    <TouchableOpacity
      style={styles.slow}
      onPress={async () => {
        const start = performance.now();

        const res = await new Promise(resolve => {
          const r = jsiPromise.foo(newVal => {
            resolve(r);
          });
        });

        setState({took: performance.now() - start, result: {...res}});
      }}>
      <Text>
        {'Tap me, will sometimes be slow: \n'}
        {JSON.stringify(state.result)} {state.took}
      </Text>
    </TouchableOpacity>
  );
}

export default function App() {
  return (
    <>
      <FastExample />
      <SlowExample />
      {/* <TouchableOpacity
        style={{backgroundColor: 'crimson', flex: 1}}
        onPress={async () => {
          forceRender();
        }}>
        <Text>Force render</Text>
      </TouchableOpacity> */}
    </>
  );
}

const styles = StyleSheet.create({
  fast: {
    flex: 1,
    alignItems: 'center',
    justifyContent: 'center',
    padding: 20,
    backgroundColor: 'gold',
  },
  slow: {
    flex: 1,
    alignItems: 'center',
    justifyContent: 'center',
    padding: 20,
    backgroundColor: 'crimson',
  },
  box: {
    width: 60,
    height: 60,
    marginVertical: 20,
  },
});
