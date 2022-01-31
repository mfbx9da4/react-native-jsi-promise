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

async function main() {
  for (let i = 0; i < 10; i++) {
    const start = Date.now();
    const p = new Promise(r => {
      jsiPromise.foo((err, x) => {
        console.log(i, 'err, x', err, x, Date.now() - start);
        r(x);
      });
    });
    await p;
  }
}

main()
  .then(console.log.bind(null, '[main]'))
  .catch(console.error.bind(null, '[main]'));

function FastExample() {
  const [state, setState] = React.useState({took: 0, result: 'initial'});

  return (
    <TouchableOpacity
      style={styles.fast}
      onPress={() => {
        const start = global.performance.now();
        jsiPromise.foo((err, x) => {
          if (err) {
            throw err;
          }
          setState({took: global.performance.now() - start, result: x});
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
        const start = global.performance.now();
        const result = await new Promise((resolve, reject) => {
          jsiPromise.foo((err, x) => (err ? reject(err) : resolve(x)));
        });
        setState({took: global.performance.now() - start, result});
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
