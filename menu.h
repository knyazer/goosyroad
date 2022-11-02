//
// Created by knyaz on 14/10/22.
//

#ifndef CROOSYROAD_MENU_H
#define CROOSYROAD_MENU_H

extern "C" int drawMenu() {
    drawGame();
    SDL_SetRenderDrawBlendMode(renderer, SDL_BLENDMODE_BLEND);
    SDL_SetRenderDrawColor(renderer, 160, 160, 180, 190 * g_alpha / 256);
    SDL_RenderFillRect(renderer, &g_screen);

    if (g_best_score != 0) {
        char buffer[30];
        sprintf(buffer, "Best score: %d", g_best_score);
        drawText(buffer, 0, 100, 100, 220);
    }

    int nextState = 0;
    if (drawButton("Play", 4, 30, 200, 120) == 1 && g_click)
        nextState = GAMEPLAY;

    if (drawButton("Exit", 6, 125, 0, 70) == 1 && g_click)
        nextState = 1; // exit

    return nextState;
}

#endif //CROOSYROAD_MENU_H
