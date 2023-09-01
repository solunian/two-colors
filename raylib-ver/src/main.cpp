#include "raylib.h"

#include "main_menu.h"
#include "tetris.h"


int main(void) {

  InitWindow(800, 600, "two colors");
  SetTargetFPS(60);

  // LOADING - adding resources to memory
  main_menu::load_res();
  tetris::load_res();

  while (!WindowShouldClose()) {

    // UPDATERS - positioning, game state checks, etc.
    switch (get_game_mode()) {
      case MainMenu:
        main_menu::update();
        break;
      case Tetris:
        tetris::update();
        break;
      case Chase:
        break;
      case Tanks:
        break;

    }

    BeginDrawing();
      
      ClearBackground(RAYWHITE);

      // DRAWINGS - adding textures, creating sprites, playing sounds
      switch (get_game_mode()) {
        case MainMenu:
          main_menu::draw();
          break;
        case Tetris:
          tetris::draw();
          break;
        case Chase:
          break;
        case Tanks:
          break;
      }

    EndDrawing();
  }

  // UNLOADING - freeing resources from memory
  main_menu::unload_res();
  tetris::unload_res();

  CloseWindow();

  return 0;
  
}