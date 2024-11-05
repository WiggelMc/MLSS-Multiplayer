# Mario & Luigi: Superstar Saga - Multiplayer Script for BizHawk

In Development (Currently only works properly in the Overworld and in Menus)

This Script allows you to control Superstar Saga with two people,
each taking control of one Brother. The Brother at the front is responsible for Movement (eg. the Dpad) and can pause the game.

### To be implemented:

- Battle Detection
    - Active Battle
    - Current Turn
    - Level Up Sequence
- Minigame Detection


## Features

- Configurable Multi Controller Support
- Both Players only control their Brother, other Buttons are disabled
- A single Button is used for Actions, regardless of whether you are at the front or the rear
- Configurable Permissions for the Swap Action (Take / Give Control)


## How to Install

- Download the Script ([Releases](https://github.com/WiggelMc/MLSS-Multiplayer/releases/)) or [Build from Source](#how-to-build-from-source)
- Open [BizHawk](https://tasvideos.org/BizHawk) (Tested on 2.9.1) and start the game
- In BizHawk, open the Lua Console (Tools > Lua Console)
- From the Console, open the Script (Script > Open Script...)
- The Script will generate a Config File in the same Directory (mlss_multiplayer.ini)
- Edit the Config File in a Text Editor and configure any Settings you want
- To apply your changes, save the File and refresh the Script (Script > Refresh) if it's running or start it if it's stopped (Double-Click the Script in the List)
- You can now play the game, the Script can be started and stopped at any time, even while the game is running

## How to Build from Source

- Install [npm](https://nodejs.org/en/download/)
- Open the Project in a Terminal
- Run `npm install`
- Run `npm run build`
- You can find the output in the `/out` directory