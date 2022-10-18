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

bool updateEvents() {
    SDL_Event event;
    g_click = false;
    g_forward = false;
    g_backward = false;
    g_left = false;
    g_right = false;

    static bool forward_lock = false, backward_lock = false, left_lock = false, right_lock = false;
    while (SDL_PollEvent(&event))
    {
        switch (event.type)
        {
            case SDL_QUIT:
                return true;

            case SDL_MOUSEMOTION:
                g_mouse_x = event.motion.x;
                g_mouse_y = event.motion.y;
                break;

            case SDL_MOUSEBUTTONDOWN:
                g_click = true;
                break;

            case SDL_KEYDOWN:
                if (!forward_lock && event.key.keysym.scancode == SDL_SCANCODE_W) {
                    g_forward = true;
                    forward_lock = true;
                }
                if (!backward_lock && event.key.keysym.scancode == SDL_SCANCODE_S) {
                    g_backward = true;
                    backward_lock = true;
                }
                if (!right_lock && event.key.keysym.scancode == SDL_SCANCODE_A) {
                    g_right = true;
                    right_lock = true;
                }
                if (!left_lock && event.key.keysym.scancode == SDL_SCANCODE_D) {
                    g_left = true;
                    left_lock = true;
                }
                break;

            case SDL_KEYUP:
                if (event.key.keysym.scancode == SDL_SCANCODE_W)
                    forward_lock = false;
                if (event.key.keysym.scancode == SDL_SCANCODE_S)
                    backward_lock = false;
                if (event.key.keysym.scancode == SDL_SCANCODE_A)
                    right_lock = false;
                if (event.key.keysym.scancode == SDL_SCANCODE_D)
                    left_lock = false;
                break;
        }
    }

    return false;
}


int main(int argc, char *argv[])
{
    g_screen.x = 0;
    g_screen.y = 0;
    g_screen.w = g_width;
    g_screen.h = g_height;

	// returns zero on success else non-zero
	if (SDL_Init(SDL_INIT_EVERYTHING) != 0) {
		printf("error initializing SDL: %s\n", SDL_GetError());
	}
    if (TTF_Init() != 0) {
        std::cout << "TTF init failure:" << TTF_GetError() << std::endl;
    }

    int imgFlags = IMG_INIT_PNG;
    if( !( IMG_Init( imgFlags ) & imgFlags ) ) {
        printf("SDL_image could not initialize! SDL_image Error: %s\n", IMG_GetError());
    }

    Sans = TTF_OpenFont("pixelfont.ttf", 32);
    std::cout << Sans << " " << TTF_GetError() << std::endl;

	SDL_Window* win = SDL_CreateWindow("GAME",
									SDL_WINDOWPOS_CENTERED,
									SDL_WINDOWPOS_CENTERED,
									1000, 1000, 0);
    renderer = SDL_CreateRenderer(win, -1, SDL_RENDERER_ACCELERATED);


    firstInitOfGame();

    // Render loop
    bool quit = false;
	while (!quit) {
        SDL_SetRenderDrawColor(renderer, 0,0,0,255);
        SDL_RenderClear(renderer);

        if (updateEvents())
            quit = true;

        if (state == MENU) {
            int menuReturn = drawMenu();
            if (menuReturn == 1)
                quit = true;
            if (menuReturn == 2) {
                state = TRANSITION;
                g_prev = MENU;
                g_post = GAMEPLAY;
                setupTransition();
            }
        }
        else if (state == TRANSITION) {
            bool transReturn = drawTransition(g_prev, g_post);
            if (transReturn) {
                state = g_post;
                g_alpha = 255;
            }

        }
        else if (state == GAMEPLAY) {
            int gameReturn = drawGame();
            if (gameReturn == 1) {
                state = TRANSITION;
                g_prev = GAMEPLAY;
                g_post = SCORE;
                setupTransition();
            }
            if (gameReturn == 2) {
                state = TRANSITION;
                g_prev = GAMEPLAY;
                g_post = MENU;
                setupTransition();
            }
        }
        else if (state == SCORE) {
            int scoreRet = drawScore();
            if (scoreRet == 1) {
                state = TRANSITION;
                g_prev = SCORE;
                g_post = GAMEPLAY;
                setupTransition();
            }
            if (scoreRet == 2) {
                initGame();
                state = TRANSITION;
                g_prev = SCORE;
                g_post = MENU;
                setupTransition();
            }
        }
        else {
            throw std::runtime_error("Undefined state in main finite automata");
        }

        SDL_RenderPresent(renderer);
        SDL_Delay(8);
    }

	return 0;
}
