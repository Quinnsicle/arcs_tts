# Arcs TTS

A mod for Tabletop Simulator that automates some actions and setup for the Leder Games title, Arcs.

## Features

- Easy setup with options for Leaders and the Leaders & Lore expansion
- Scripted campaign setup
- Snap points for all game components
- Quality of life features:
  - Board setup
  - Camera and Player Timer menu
  - Action card helper board
  - Player score boards with ambition score counters
  - Surpass and seize detection (moves initiative during end round)
- Containers for player pieces that integrate well into existing art style

## Workshop Releases

This repository is associated with two Tabletop Simulator Workshop items:

- [Arcs - Imperial Edition](https://steamcommunity.com/sharedfiles/filedetails/?id=3037846252) - The primary public release
- [Arcs - Outlaw Edition](https://steamcommunity.com/sharedfiles/filedetails/?id=3346632934) - Used for development and testing

## Requirements

- [Tabletop Simulator](https://store.steampowered.com/app/286160/Tabletop_Simulator/)

## Tools

- VSCode
  - [Tabletop Simulator Lua Extension](https://marketplace.visualstudio.com/items?itemName=rolandostar.tabletopsimulator-lua)

## Getting Started

Once you have VSCode + Tabletop Simulator Lua Extension setup, you can:

1. Clone this repository.
2. Copy the `TS_Save.json` to your Tabletop Simulator Saves folder.
   - Windows: `%USERPROFILE%\Documents\My Games\Tabletop Simulator\Saves`
   - macOS: `~/Documents/Tabletop Simulator/Saves`
   - Linux: `~/.local/share/Tabletop Simulator/Saves`
3. Load the save in Tabletop Simulator.
4. Use `Ctrl+Alt+L` to load the current TTS save into the Lua Extension.
5. Make changes to the code in the `src` directory.
6. Use `Ctrl+Alt+S` after making any changes in project source to re-bundle the code and reload TTS with the new changes.
   - **NOTE**: This will reload TTS back to the original TS_Save game state, and you'll lose any in-game changes you made. Thus create saves judiciously and apply those changes to the project TS_Save.json when you're happy with them.

## Contributing

If you find a bug or want to contribute, you're welcome to:
1. Search for existing open issues or create a new issue describing the problem or suggested enhancement.
2. Submit a pull request with your proposed fix.