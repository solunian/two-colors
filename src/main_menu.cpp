#include "raylib.h"

#include "main_menu.h"

GameMode game_mode = MainMenu;

GameMode get_game_mode(void) {
  return game_mode;
}

void set_game_mode(GameMode new_game_mode) {
  game_mode = new_game_mode;
}

void return_to_main_menu(void) {
  set_game_mode(MainMenu);
}

namespace main_menu {
  Font menu_font;

  void load_res(void) {
    menu_font = LoadFont("res/BagelFatOne.ttf");
  }

  void unload_res(void) {
    UnloadFont(menu_font);
  }

  void update(void) {
    
  }

  void draw(void) {
    DrawRectangle(0, 0, GetScreenWidth(), GetScreenHeight(), BLACK);

    DrawRectangle(0, 0, GetScreenWidth() / 2, GetScreenHeight(), RED);
    DrawRectangle(GetScreenWidth() / 2, 0, GetScreenWidth() / 2, GetScreenHeight(), DARKBLUE);

    DrawTextEx(menu_font, "two colors", (Vector2){ (float)GetScreenWidth() / 3, (float)GetScreenHeight() / 3}, (float)menu_font.baseSize * 2.5, 3.0f, WHITE);
  }
}