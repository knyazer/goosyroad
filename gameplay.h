//
// Created by knyaz on 14/10/22.
//

#include "funcs.h"
#include "stdio.h"

#ifndef CROOSYROAD_GAMEPLAY_H
#define CROOSYROAD_GAMEPLAY_H

int rowType[1000];
float currentRow = 1;
float targetRow = 1;

float eps = 0.05;

int numberOfRowsToDraw = 12;
int horizontalResolution = 12;

int playerRow = 3;
int playerColumn = horizontalResolution / 2;

float playerRowF = playerRow;
float playerColumnF = playerColumn;

int playerDirection = 0;

SDL_Texture* heroR, *heroL, *heroSR, *heroSL;
SDL_Texture* carTexturesR[1], *carTexturesL[1], *rockTextures[6];
SDL_Texture* roadTexture;

struct Car {
    int row; // 4 bytes
    float position; // 0-horizontalResolution
    int type; // 12 bytes
    float speed; // 16 bytes
    float width; // 20 bytes
    bool exist; // 24 bytes
};

struct Rock {
    int row;
    int position;
    int type;
};

const int carsSize = 100;
int rocksSize = 1000;
int carsFirstEmpty; // pointer to the first empty space in an array of cars
Car cars[carsSize];
Rock rocks[1000];
#define SAVE 0
#define ROADL 1
#define ROADR 2

extern "C" int* getRowType() { return rowType; } 

extern "C" void updateComplemenetaryFilters() {
    if (std::abs(playerRow - playerRowF) > eps)
        playerRowF += sign(playerRow - playerRowF) * eps;

    if (std::abs(playerColumn - playerColumnF) > eps)
        playerColumnF += sign(playerColumn - playerColumnF) * eps;

    if (!g_no_render && playerRowF > (currentRow + 3))
        targetRow += 0.05 * ((playerRowF - currentRow - 3) / numberOfRowsToDraw);

    if (!g_no_render)
        targetRow += 0.005;

    currentRow = 0.98 * currentRow + 0.02 * targetRow;
}

extern "C" bool getComplexAndCondition(int i) {
    return cars[i].exist && abs(float(cars[i].row) - playerRowF) < 0.25 &&
            cars[i].position < playerColumnF &&
            playerColumnF < cars[i].position + cars[i].width;
}


#endif //CROOSYROAD_GAMEPLAY_H
