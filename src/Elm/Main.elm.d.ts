export namespace Elm {
    namespace Main {
        interface App {
            ports: Ports;
        }

        interface Args {
            flags: string[];
        }

        interface Ports {
            output: Subscribe<string>;
            exitWithMsg: Subscribe<[number, string]>;
            keyDown: Send<KeyEvent>;
        }

        interface Subscribe<T> {
            subscribe(cb: (value: T) => void): void;
        }

        interface Send<T> {
            send(value: T): void;
        }

        interface KeyEvent {
            sequence: string,
            ctrl: boolean,
            meta: boolean,
            shift: boolean
        }

        function init(args: Args): App;
    }
}