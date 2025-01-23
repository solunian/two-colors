# two colors :red_circle: :large_blue_circle:

A game collection that uses only two main colors. 
Designed to help people correct "lazy eye" (amblyopia) by using those red-blue tinted glasses (like for 3D movies).

## Games Completed

- [x] tetra
- [ ] tanks from wii play: wasd to move, mouse/click to fire bullets, space bar for dropping a mine
- [ ] getting chased

## Dev Notes

### Build

Refer to the love2d docs for game distribution [here](https://love2d.org/wiki/Game_Distribution)!

### Color

Look through only one tinted lens of glasses, and adjust the color until it turns near black.
Looking through a pure blue filter would only show blue light, and same with everything else.

Match the opposite color into the black background.

Switch colors around randomly in the middle of playing a game.

### Libs Used

- [push](https://github.com/Ulydev/push): for aspect ratio windowing stuff
- [classic](https://github.com/rxi/classic): for simple oop stuff, renamed to lib/object
- [lume](https://github.com/rxi/lume): serialization for save data

### Tetra

Recreating the famous stacking game is more complex than one might think.
The weird things is coding rotation, srs kicks, and movement things like
ARR, DAS, and DCD.

Heavily referenced tetrio and other tables for specific details.

All functionality essentials implemented.

More notes [here](https://github.com/solunian/two-colors/tree/main/src/tetra/README.md).

### Tanks

Coding rn!
