//
// Created by knyaz on 16/10/22.
//


#ifndef CROOSYROAD_FUNCS_H
#define CROOSYROAD_FUNCS_H

using ll = long long;

int sign(float x) {
    return x > 0 ? 1 : -1;
}

TTF_Font* Sans;

extern "C" {
    SDL_Color makeSDLColor(int r, int g, int b) {
        return {static_cast<Uint8>(r), static_cast<Uint8>(g), static_cast<Uint8>(b)};
    }

    void SDL_RenderFillRectw(SDL_Renderer* renderer, SDL_Rect* rect) {
        printf("x: %d, y: %d, w: %d, h: %d", rect->x, rect->y, rect->w, rect->h);
        SDL_RenderFillRect(renderer, rect);
    }
}



extern "C" void drawText(const char* text, int mode, int r, int g, int b);/* {
    if ( !Sans ) {
        std::cout << "Failed to load font: " << TTF_GetError() << std::endl;
    }
    SDL_Rect rectangle;


    drawTextd();


    if (mode == 0 || mode == 2 || mode == 3) {
        int charSize = g_width / 10;
        if (mode == 2)
            charSize *= 2;

        int len = strlen(text);

        do {
            charSize *= 0.8;
            rectangle.x = g_width / 2 - (len * charSize / 2);
        } while (rectangle.x < 0);

        if (mode == 0)
            rectangle.y = g_height / 4;
        else if (mode == 2)
            rectangle.y = g_height / 4.5;
        else if (mode == 3)
            rectangle.y = g_height / 11;

        rectangle.w = len * charSize;
        rectangle.h = charSize;
    }
    else if (mode == 1) {
        int charSize = g_width / 10;
        int len = strlen(text);
        rectangle.x = g_width / 16;
        rectangle.y = g_height / 16;
        rectangle.w = charSize * len;
        rectangle.h = charSize;
    }

    SDL_Color color = {static_cast<Uint8>(r), static_cast<Uint8>(g), static_cast<Uint8>(b)};

    SDL_Surface* surfaceMessage =
            TTF_RenderText_Solid(Sans, text, color);
    SDL_Texture* Message = SDL_CreateTextureFromSurface(renderer, surfaceMessage);
    SDL_SetTextureAlphaMod(Message, g_alpha);

    SDL_RenderCopy(renderer, Message, NULL, &rectangle);

    SDL_FreeSurface(surfaceMessage);
    SDL_DestroyTexture(Message);
}*/



extern "C" int drawButton(const char* text, int pos, int r, int g, int b); /*
    if ( !Sans ) {
        std::cout << "Failed to load font: " << TTF_GetError() << std::endl;
    }
    SDL_Rect rectangle;

    rectangle.x = g_width / 4;
    rectangle.y = (g_height / 8) * pos;
    rectangle.w = g_width / 2;
    rectangle.h = g_height / 7;

    SDL_SetRenderDrawColor(renderer, r, g, b, g_alpha);
    SDL_RenderFillRect(renderer, &rectangle);

    int borderSize = g_width / 98;
    rectangle.w -= 2 * borderSize;
    rectangle.h -= 2 * borderSize;
    rectangle.x += borderSize;
    rectangle.y += borderSize;

    r = (r + 128) / 2;
    g = (g + 128) / 2;
    b = (b + 128) / 2;

    int hovered = 0;
    if (g_mouse_x > rectangle.x && g_mouse_y > rectangle.y && g_mouse_x < rectangle.x + rectangle.w && g_mouse_y < rectangle.y + rectangle.h)
    {
        hovered = 1;
        r = r * 2 / 3;
        g = g * 2 / 3;
        b = b * 2 / 3;
    }

    SDL_SetRenderDrawColor(renderer, r, g, b, g_alpha);
    SDL_RenderFillRect(renderer, &rectangle);

    SDL_Color White = {static_cast<Uint8>((255 - r)), static_cast<Uint8>((255 - g)), static_cast<Uint8>((255 - b))};

    SDL_Surface* surfaceMessage =
            TTF_RenderText_Solid(Sans, text, White);

    SDL_Texture* Message = SDL_CreateTextureFromSurface(renderer, surfaceMessage);
    SDL_SetTextureAlphaMod(Message, g_alpha);

    int delta = g_width / 58;
    rectangle.w -= delta * 2;
    rectangle.h -= delta * 2;
    rectangle.x += delta;
    rectangle.y += delta;

    SDL_RenderCopy(renderer, Message, NULL, &rectangle);

    SDL_FreeSurface(surfaceMessage);
    SDL_DestroyTexture(Message);

    return hovered;
}*/

#endif //CROOSYROAD_FUNCS_H
