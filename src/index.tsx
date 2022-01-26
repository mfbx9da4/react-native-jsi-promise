//@ts-ignore
const module: {
  foo(): Promise<string>;
} = global;

export default module;
