# two colors :red_circle: :large_blue_circle:

A game collection that uses two main colors. 
Designed to help people correct "lazy eye" (amblyopia) by using those red-blue tinted glasses (like for 3D movies).

## Parts

- start screen
- menu/options
- color matching/auto switch
- tetra
- tanks from wii play

## Dev Notes

### Project Structure

- main loop in main.lua, game config in conf.lua
- each part of game is separated into folders (src/tetra, src/tanks, etc.)
- libs (that i didn't write) in (src/lib)
- utils (that i did write) in (src/util)

### Running

Makefile has all the "necessary" commands compiled together. Use `make` to run the game locally without building it to be distributed.

### Build

In the Makefile, but you can also refer to the love2d docs for game distribution [here](https://love2d.org/wiki/Game_Distribution)!

### Color

Look through only one tinted lens of glasses, and adjust the color until it turns near black.
Looking through a pure blue filter would only show blue light, and same with everything else.

Match the opposite color into the black background.

Switch colors around randomly in the middle of playing a game.

### Libs Used

- [push](https://github.com/Ulydev/push): for aspect ratio windowing stuff
- [classic](https://github.com/rxi/classic): for simple oop stuff, renamed to lib/object
- [lume](https://github.com/rxi/lume): serialization for save data
- [minheap](https://gist.github.com/H2NCH2COOH/1f929775db0a355ca6b6088a4662fe95): priority queue

> These are all sitting in src/lib

### Start Screen

- drawing the intersection of two cirlces efficiently.
- title screen image gets blocked out by the bouncing red and blue circles.

### Tetra

Recreating the famous stacking game is more complex than one might think.
The weird things is coding rotation, srs kicks, and movement things like
ARR, DAS, and DCD.

Heavily referenced tetrio and other tables for specific details.

All functionality essentials implemented.

More notes [here](https://github.com/solunian/two-colors/tree/main/src/tetra/README.md).

### Tanks

- controls: wasd to move, mouse to aim, spacebar to fire
- kinda some weird geometry math for tank auto movement
