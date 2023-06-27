#include "raylib.h"

#include "tetris.h"

namespace tetris {

  struct Grid {
    int width = 250, height = 500;

    void draw(void) {
      DrawRectangleLines(GetScreenWidth() / 2 - this->width / 2, GetScreenHeight() / 2 - this->height / 2, width, height, BLACK);
    }
  } grid;

  void load_res(void) {
  }

  void unload_res(void) {

  }

  void update(void) {
    
  }

  void draw(void) {
    grid.draw();
  }
}