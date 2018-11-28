# golsim - A Game Of Life simulator in powershell

This module is a powershell implementation of [Conways Game Of Life](https://en.wikipedia.org/wiki/Conway%27s_Game_of_Life).

I use this module mostly to hone my powershell skills. If you are looking for a stable and fast Game of Life simulator, then [Golly](https://en.wikipedia.org/wiki/Conway%27s_Game_of_Life) is probably what you are looking for.

## Quick Start

```powershell
ipmo golsim
$game = [Game]::new(30,30,$true,100,0)
$game.StartGame()
```