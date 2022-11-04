#include <SDL2/SDL.h>
#include <SDL2/SDL_image.h>
#include <SDL2/SDL_ttf.h>
#include <SDL2/SDL_timer.h>
#include <iostream>
#include <atomic>
#include <stdio.h>
#include <stdbool.h>

extern "C" {
    SDL_Color makeSDLColor(int r, int g, int b) {
        return {static_cast<Uint8>(r), static_cast<Uint8>(g), static_cast<Uint8>(b)};
    }

    int getMotionX(SDL_Event* event) {
        return event->motion.x;
    }

    int getMotionY(SDL_Event* event) {
        return event->motion.y;
    }

    int getScancode(SDL_Event* event) {
        return event->key.keysym.scancode;
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
