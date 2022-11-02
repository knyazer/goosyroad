//
// Created by knyaz on 14/10/22.
//

#include "score.h"

#ifndef CROOSYROAD_TRANSITION_H
#define CROOSYROAD_TRANSITION_H

//int drawTransitionState = 255;
extern "C" {
    int setGAlpha(int alpha) {
        g_alpha = alpha;
    }

    void setGStaticRender(bool render) {
        g_static_render = render;
    }

    void setGPlayable(bool playable) {
        g_playable = playable;
    }
}

extern "C" void setupTransition();
extern "C" bool drawTransition(int pre, int post);

#endif //CROOSYROAD_TRANSITION_H
