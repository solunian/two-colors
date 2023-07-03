# two colors :red_circle: :large_blue_circle:

A game collection that uses only two main colors. Designed to help people correct "lazy eye" (amblyopia) by using those red-blue 3D glasses.

Disclaimer: This is a not a legitimate medical treatment; use at your own risk. Don't sue me, please. But seriously, are you actually using this?

## Games

- [ ] tetris clone: [reference](https://codeincomplete.com/articles/javascript-tetris/)
- [ ] getting chased
- [ ] tanks from wii play: wasd to move, mouse/click to fire bullets, space bar for dropping a mine
- [ ] shooty skies clone?

## Dev Notes

- this probably doesn't work
- using raylib, but idk how to distribute executables properly
- i bet i'll have a bunch of lovely memory leaks...
- trying to gain the respect of webdev haters and "low-level" lovers
- Makefile use "\t" indentation, but all code should use two spaces instead

## getting raylib working

### linux (i use ubuntu)

- to add headers and lib archive for the compiler, headers must be located at `/usr/local/include` and lib should be at `/usr/local/lib`
- use the raylib wiki because it is a little messy
- reference the Makefile for running

### windows

- using minGW-w64 from here -> https://www.mingw-w64.org/downloads/#mingw-builds, https://winlibs.com/
  - unzip and then place mingw64 folder somewhere safe like -> `C:\`
  - then add mingw64\bin to PATH with environment variables
  - i copied `mingw32-make` in bin, then renamed the copy to `make` as a "fake alias"
- download the most recent stable release of raylib -> https://github.com/raysan5/raylib/releases
  - should be either win32/win64 and mingw-w64 version
  - then take the `lib` and `include` folders and move it into this project
- make a folder called build (`make wininit`)
- then by running `make win` everything should run

