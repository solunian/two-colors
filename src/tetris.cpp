#include <iostream>
#include <cmath>

#include "raylib.h"

#include "main_menu.h"
#include "tetris.h"

namespace tetris {

  struct Grid {
    const int width = 250, height = 500;
    int x = 0, y = 0;

    double frame_count = 0.0;

    void update(void) {
      x = GetScreenWidth() / 2 - width / 2 + (int)(sin(frame_count) * (GetScreenWidth() / 2 - width * 2 / 3));
      y = GetScreenHeight() / 2 - height / 2;

      frame_count += 0.03;
    }

    void draw(void) {
      DrawRectangleLines(x, y, width, height, BLACK);
    }
  } grid;


  void load_res(void) {
  }

  void unload_res(void) {

  }

  void update(void) {
    grid.update();
  }

  void draw(void) {
    grid.draw();
  }
}