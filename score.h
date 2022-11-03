//
// Created by knyaz on 14/10/22.
//

#include "funcs.h"

#ifndef CROOSYROAD_SCORE_H
#define CROOSYROAD_SCORE_H

extern "C" {
    int getGPost() ;

    int getGPrev() ;
    
    void setGPost(int state) ;

    void setGPrev(int state) ;

    void setGPrevScore(int score) ;

    int getGPrevScore() ;

    int getGCurrentScore() ;

    void setGCurrentScore(int score) ;

    int getGBestScore() ;

    void setGBestScore(int score) ;

    int getState() ;

    void setState(int _state) ;

    int getGClick() ;

    int getGAlpha() ;

    SDL_Rect* getGScreen() ;
}

extern "C" int drawScore();

#endif //CROOSYROAD_SCORE_H
