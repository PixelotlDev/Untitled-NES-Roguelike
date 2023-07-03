# Untitled_NES_Game

Big thanks to BattleLineGames for their [NES Starter Kit](https://github.com/battlelinegames/nes-starter-kit), which I used as a template for this project!

## Description

## Controls

## Building
#### Linux
On Linux systems, simply run the build.sh script in terminal in the file that it's located.  
`(.../Untitled_NES_Roguelike/build/scripts)`

---

#### Other
On other systems (or if you don't want to run a script from an unknown third party), either mimicking the commands in the build.sh shell script in your system's terminal or following the simplified version below should work:
- In terminal, navigate to the `Untitled_NES_Roguelike` folder
- Run the assembler on the code by entering `ca65 src/main.asm -o build/main.o`
- Run the linker on the assembled file by typing `ld65 -o build/NES-Roguelike.nes -C src/linker.cfg build/main.o`



## Notes
