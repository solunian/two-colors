#include <iostream> // for testing :D
#include <cmath> // used un poco for sine kinda
#include <cstdlib>
#include <array>

#include "raylib.h"

#include "main_menu.h"
#include "tetris.h"

namespace tetris {

  struct Tetromino {

    enum ShapeType {
      I, J, L, O, S, Z, T,
    };

    static ShapeType gen_random_shapetype(void) {
      srand((uint)time(nullptr));
      return (ShapeType)(rand() % 7);
    }
  };

  struct Grid {

    enum GridValue {
      Empty, Fixed, Active,
    };

    const Color bg_color = BLACK, grid_color = WHITE, grid_line_color = DARKGRAY;
    const Color fixed_color = BLUE, active_color = RED;
    const float width = 265.0f;
    const float side_buff = 3.0f;
    // block side length: buff * 2 on the left/right sides, 1px * 9 gap for grid lines
    const float block_len = (width - side_buff * 2 - 1 * 9) / 10;
    // grid height: blocks * 20, buff * 2 on top/bottom sides, 1px * 19 gap for grid lines
    const float height = block_len * 20 + side_buff * 2 + 1 * 19;

    float x = 0.0f, y = 0.0f;
    bool isGameRunning = true;
    std::array<std::array<GridValue, 10>, 20> grid_matrix;
    
    double last_sec;
    const double game_tick_interval = 0.2;
    
    Grid() {
      // init grid_matrix with empty values
      for (size_t i = 0; i < grid_matrix.size(); i++) {
        for (size_t j = 0; j < grid_matrix[i].size(); j++) {
          grid_matrix[i][j] = Empty;
        }
      }

      last_sec = GetTime();

      grid_matrix[4][3] = Fixed;
      grid_matrix[6][2] = Fixed;
      grid_matrix[9][2] = Fixed;
      grid_matrix[1][0] = Fixed;
      grid_matrix[12][7] = Active;
      grid_matrix[3][9] = Active;
      grid_matrix[0][1] = Active;
      grid_matrix[8][1] = Active;
      grid_matrix[14][6] = Active;
    }

    void add_tetromino(Tetromino block) {
      
    }

    void update_blocks(void) {
      // -1 to keep within bounds, lol size_t breaks when for loop tries to decrement
      for (int row = grid_matrix.size() - 2; row >= 0; row--) {
        for (size_t col = 0; col < grid_matrix[row].size(); col++) {
          GridValue &curr = grid_matrix[row][col];
          GridValue &next = grid_matrix[row + 1][col];
          if (curr == Active && next == Empty) {
            curr = Empty;
            next = Active;
            
            // hit bottom or Fixed
            if ((size_t)row + 1 == grid_matrix.size() - 1 || grid_matrix[row + 2][col] == Fixed) {
              next = Fixed;
            }
          }
        }
      }
    }

    void draw_grid_lines(void) {
      // vertical lines
      for (int i = 0; i < 9; i++) {
        // first one has no line needed to add to x
        float start_x = x + side_buff + block_len + (block_len + 1) * i;
        DrawLineEx((Vector2){ start_x, y }, (Vector2){ start_x, y + height }, 1, grid_line_color);
      }

      // horizontal lines
      for (int i = 0; i < 19; i++) {
        // there's a +1 after block_len that I have no idea why it's there... raylib graphics are clunky or smth?
        float start_y = y + side_buff + block_len + 1 + (block_len + 1) * i;
        DrawLineEx((Vector2){ x, start_y }, (Vector2){ x + width, start_y }, 1, grid_line_color);
      }

      // Grid Border
      // DrawRectangleLinesEx((Rectangle){ x, y, width, height }, 1, grid_color);
      DrawRectangleRoundedLines((Rectangle){ x, y, width, height }, 0.025f, 10, 1, grid_color);
    }

    void draw_blocks(void) {
      for (size_t row = 0; row < grid_matrix.size(); row++) {
        for (size_t col = 0; col < grid_matrix[row].size(); col++) {
          
          GridValue current_cell = grid_matrix[row][col];
          float offset = block_len + 1;
          
          switch (current_cell) {
            case Empty:
              break;
            case Fixed:
              DrawRectangleRec((Rectangle){ x + side_buff + offset * col, y + side_buff + offset * row, block_len, block_len }, fixed_color);
              break;
            case Active:
              DrawRectangleRec((Rectangle){ x + side_buff + offset * col, y + side_buff + offset * row, block_len, block_len }, active_color);
              break;
          }
        }
      }
    }

    void update(void) {
      x = GetScreenWidth() / 2 - width / 2;
      y = GetScreenHeight() / 2 - height / 2;

      if (isGameRunning && (GetTime() - last_sec) >= game_tick_interval) {
        update_blocks();

        last_sec = GetTime(); // update time
      }
    }

    void draw(void) {
      ClearBackground(bg_color); // sets the background color
      
      draw_grid_lines();
      draw_blocks();
    }
  } grid;

  
  void load_res(void) {}

  void unload_res(void) {}

  void update(void) {
    grid.update();
  }

  void draw(void) {
    grid.draw();
  }
}