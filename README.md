# BadAPI-Lua

The lua side of BadAPI

## Features

### Command console
Can be opened with `~`
Variables are automatically saved to `BadAPI/scripts_config/convars.cfg`
You can create `BadAPI/scripts_config/autoexec.cfg`, this file will run all commands inside it every time you inject.
This is useful for binds

### Keybinds
You can bind any command to a key with the `bind` command.
For example `bind f3 noclip`.
You can also do key combinations like this `bind ctrl+i freecam`

If a command you bound is prefixed with the `+` symbol, it will also call the same command with the `-` prefix.
For example: `bind o "+test"` will call `+test` when you press `O`, and `-test` when you release it.

If a bind is set to a key that is already used by GTAV, the key will be disabled for the game.
For example if you `bind shift+ins toggle_gui`, you will not be able to sprint with shift, or change the camera using insert.


## Credits
BadAPI-Lua has stolen code from the following projects:
- [YimMenu](https://github.com/YimMenu/YimMenu)
- [rage-parser-dumps](https://alexguirre.github.io/rage-parser-dumps)
- [json.lua](https://github.com/rxi/json.lua)
