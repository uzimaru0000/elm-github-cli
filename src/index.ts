// @ts-ignore
global.XMLHttpRequest = require('xhr2');

import { Elm } from './Elm/Main.elm';
import prompts from 'prompts';

const args = process.argv.slice(2);

const app = Elm.Main.init({ flags: args });

app.ports.output.subscribe(async ([str, opts]) => {
  process.stdout.write(str);
  const { value } = await prompts(opts);
  app.ports.input.send(value);
});

app.ports.exitWithMsg.subscribe(([code, msg]) => {
  process.stdout.write(msg);
  process.exit(code);
});
