//
// Created by knyaz on 16/10/22.
//


#ifndef CROOSYROAD_FUNCS_H
#define CROOSYROAD_FUNCS_H

using ll = long long;

extern "C" float sign(float x) {
    return x > 0 ? 1 : -1;
}

TTF_Font* Sans;

extern "C" {
    SDL_Color makeSDLColor(int r, int g, int b) {
        return {static_cast<Uint8>(r), static_cast<Uint8>(g), static_cast<Uint8>(b)};
    }
}

#endif //CROOSYROAD_FUNCS_H
