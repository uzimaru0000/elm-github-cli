// @ts-ignore
global.XMLHttpRequest = require('xhr2');

// @ts-ignore
import { Elm } from './Elm/Main.elm'
import readlineSync from 'readline-sync'

const args = process.argv.slice(2);

const app = Elm.Main.init({ flags: args });

app.ports.stdout.subscribe(console.log);
app.ports.requestInput.subscribe(([outerMsg, msg]: [string, string]) => {
    const ans = readlineSync.question(msg);
    app.ports.input.send({
        msg: outerMsg,
        input: ans
    });
});

app.ports.requestKeyDown.subscribe(() => {
    const key = readlineSync.keyIn('', {
        hideEchoBack: true,
        mask: ''
    });

    app.ports.keyDown.send(key);
});

app.ports.exit.subscribe((code: number) => {
    process.exit(code);
});
