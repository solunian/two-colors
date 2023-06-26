#ifndef MAIN_MENU_H
#define MAIN_MENU_H

enum GameMode {
  MainMenu,
  Tetris,
  Chase,
  Tanks,
};

GameMode get_game_mode(void);

void return_to_main_menu(void);

namespace main_menu {
  void load_res(void);
  
  void unload_res(void);

  void update(void);

  void draw(void);
}

#endif