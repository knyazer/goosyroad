//
// Created by knyaz on 14/10/22.
//

#include "score.h"

#ifndef CROOSYROAD_TRANSITION_H
#define CROOSYROAD_TRANSITION_H

int drawTransitionState = 255;

void setupTransition() {
    drawTransitionState = 0;

    if (g_post == GAMEPLAY) {
        g_static_render = false;
        g_playable = true;
        initGame();
    }
    else if (g_post == SCORE) {
        g_playable = false;
        g_static_render = true;
    }
    else if (g_post == MENU) {
        g_static_render = false;
        g_playable = false;
        initGame();
    }
}

bool drawTransition(int pre, int post) {
    drawTransitionState += 7;

    if (drawTransitionState > 255)
        drawTransitionState = 255;

    g_alpha = 255;
    int st = pre;
    switch (st) {
        case GAMEPLAY:
            drawGame();
            break;
        case MENU:
            drawMenu();
            break;
        case SCORE:
            drawScore();
            break;
    }

    g_alpha = drawTransitionState;


    st = post;
    switch (st) {
        case GAMEPLAY:
            drawGame();
            break;
        case MENU:
            drawMenu();
            break;
        case SCORE:
            drawScore();
            break;
    }

    if (drawTransitionState >= 255)
        return true;

    return false;
}

#endif //CROOSYROAD_TRANSITION_H
