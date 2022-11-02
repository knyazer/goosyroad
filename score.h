//
// Created by knyaz on 14/10/22.
//

#include "funcs.h"

#ifndef CROOSYROAD_SCORE_H
#define CROOSYROAD_SCORE_H

extern "C" {
    int getGPost() {
        return g_post;
    }

    int getGPrev() {
        return g_prev;
    }
    
    void setGPost(int state) {
        g_post = state;
    }

    void setGPrev(int state) {
        g_prev = state;
    }

    void setGPrevScore(int score) {
        g_prev_score = score;
    }

    int getGPrevScore() {
        return g_prev_score;
    }

    int getGCurrentScore() {
        return g_current_score;
    }

    void setGCurrentScore(int score) {
        g_current_score = score;
    }

    int getGBestScore() {
        return g_best_score;
    }

    void setGBestScore(int score) {
        g_best_score = score;
    }

    int getState() {
        return state;
    }

    void setState(int _state) {
        state = _state;
    }

    int getGClick() {
        return g_click;
    }

    int getGAlpha() {
        return g_alpha;
    }

    SDL_Rect* getGScreen() {
        return &g_screen;
    }
}

extern "C" int drawScore();

#endif //CROOSYROAD_SCORE_H
