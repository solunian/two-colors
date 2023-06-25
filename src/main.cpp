#include "raylib.h"

int main(void)
{
    InitWindow(800, 600, "raylib [core] example - basic window");

    Font fontTtf = LoadFontEx("assets/BagelFatOne.ttf", 32, nullptr, 0);

    while (!WindowShouldClose())
    {
        BeginDrawing();
            ClearBackground(RAYWHITE);
            DrawTextEx(fontTtf, "Congrats! You created your first window!", (Vector2){ 100.0f, 100.0f }, (float)fontTtf.baseSize, 2, MAROON);
            // DrawText("Congrats! You created your first window!", 189, 200, 20, LIGHTGRAY);
        EndDrawing();
    }

    UnloadFont(fontTtf);

    CloseWindow();

    return 0;
}