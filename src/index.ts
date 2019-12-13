// @ts-ignore
global.XMLHttpRequest = require('xhr2');

import { Elm } from './Elm/Main.elm'
import readline from 'readline';

const args = process.argv.slice(2);

readline.emitKeypressEvents(process.stdin);
const reader = readline.createInterface({
    input: process.stdin,
    output: process.stdout,
    terminal: false
});

const app = Elm.Main.init({ flags: args });

app.ports.output.subscribe(async str => {
    process.stdout.write(str);
    try {
        app.ports.keyDown.send(await keyDown());
    } catch {
        reader.close();
        process.exit();
    }
});

app.ports.exitWithMsg.subscribe(([code, msg]) => {
    process.stdout.write(msg);
    process.exit(code);
});

const keyDown = () =>
    new Promise<Elm.Main.KeyEvent>((res, rej) => {
        process.stdin.setRawMode(true);
        reader.resume();
        process.stdin.once('keypress', (_, ev) => {
            if (ev.ctrl && ev.name === 'c') {
                rej();
                return;
            }

            res(ev);
            reader.pause();
        });
    });