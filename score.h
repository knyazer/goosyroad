//
// Created by knyaz on 14/10/22.
//

#include "funcs.h"

#ifndef CROOSYROAD_SCORE_H
#define CROOSYROAD_SCORE_H

int drawScore() {
    drawGame();

    if (state != TRANSITION || g_post != GAMEPLAY)
        g_prev_score = g_current_score;

    g_best_score = std::max(g_best_score, g_prev_score);

    SDL_SetRenderDrawBlendMode(renderer, SDL_BLENDMODE_BLEND);
    SDL_SetRenderDrawColor(renderer, 160, 160, 180, 190 * g_alpha / 256);
    SDL_RenderFillRect(renderer, &g_screen);

    drawText("Your score:", 3, 100, 100, 220);
    char buffer[30];
    sprintf(buffer, "%d", g_prev_score);
    drawText(buffer, 2, 100, 100, 220);

    int nextState = 0;
    if (drawButton("Restart", 4, 30, 200, 120) == 1 && g_click)
        nextState = 1;

    else if (drawButton("Menu", 6, 125, 0, 70) == 1 && g_click)
        nextState = 2;

    return nextState;
}

#endif //CROOSYROAD_SCORE_H
