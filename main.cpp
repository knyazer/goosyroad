#include <SDL2/SDL.h>
#include <SDL2/SDL_image.h>
#include <SDL2/SDL_ttf.h>
#include <SDL2/SDL_timer.h>
#include <iostream>
#include <atomic>
#include <stdio.h>
#include <stdbool.h>

const int TRANSITION = 0;
const int MENU = 1;
const int GAMEPLAY = 2;
const int SCORE = 3;

bool g_no_render = false;
bool g_static_render = false;
bool g_playable = false;

int g_post = 0, g_prev = 0;
int g_current_score = 0, g_best_score = 0;
int g_prev_score = 0, state = MENU;

int g_alpha = 255;

int g_width = 1000, g_height = 1000;
int g_mouse_x = 0, g_mouse_y = 0;
bool g_click = false, g_left = false, g_right = false, g_forward = false, g_backward = false;
SDL_Rect g_screen;

SDL_Renderer* renderer;

#include "gameplay.h"
#include "funcs.h"
#include "menu.h"
#include "transition.h"
#include "score.h"

extern "C" {
    int getMotionX(SDL_Event* event) {
        return event->motion.x;
    }

    int getMotionY(SDL_Event* event) {
        return event->motion.y;
    }

    int getScancode(SDL_Event* event) {
        return event->key.keysym.scancode;
    }

    void setRenderer(SDL_Renderer* r) {
        renderer = r;
    }

    void createRenderer(SDL_Window* window) {
        renderer = SDL_CreateRenderer(window, -1, SDL_RENDERER_ACCELERATED);
    }

    int getSDL_Quit() {
        return SDL_QUIT;
    }

    int getSDL_MouseMotion() {
        return SDL_MOUSEMOTION;
    }

    int getSDL_MouseButtonUp() {
        return SDL_MOUSEBUTTONUP;
    }

    int getSDL_MouseButtonDown() {
        return SDL_MOUSEBUTTONDOWN;
    }

    int getSDL_KeyUp() {
        return SDL_KEYUP;
    }

    int getSDL_KeyDown() {
        return SDL_KEYDOWN;
    }
}

extern "C" bool updateEvents();

extern "C" int main(int argc, char *argv[]);
