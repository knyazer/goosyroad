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

extern "C" void setRocksSize(int size) {
    rocksSize = size;
}

extern "C" Car* getCars();//{ return cars; }
extern "C" Rock* getRocks();// { return rocks; }

extern "C" int getCarsFirstEmpty() { return carsFirstEmpty; }
extern "C" void setCarsFirstEmpty(int i) { carsFirstEmpty = i; }

extern "C" int getGNoRender() { return g_no_render; }
extern "C" int getGStaticRender() { return g_static_render; }

extern "C" int getGHeight() { return g_height; }

extern "C" SDL_Texture* getHeroR() { return heroR; }
extern "C" SDL_Texture* getHeroSR() { return heroSR; }
extern "C" SDL_Texture* getHeroL() { return heroL; }
extern "C" SDL_Texture* getHeroSL() { return heroSL; }

extern "C" int getNumberOfRowsToDraw() { return numberOfRowsToDraw; } 

extern "C" int getGWidth() { return g_width; }

extern "C" SDL_Renderer* getRenderer() { return renderer; }

extern "C" SDL_Texture* getRoadTexture() { return roadTexture; } 

extern "C" int addCar();
extern "C" void drawCars(int low, int high);
extern "C" void drawRocks(int low, int high);
extern "C" void removeCar(int i);
extern "C" void renderSave(int i);
extern "C" void renderRoad(int i);

extern "C" int getHorizontalResolution() { return horizontalResolution; }

extern "C" int getPlayerDirection() { return playerDirection; }

extern "C" int getCurrentRow() { return currentRow; }

extern "C" SDL_Texture** getRockTextures() { return rockTextures; }

#define SAVE 0
#define ROADL 1
#define ROADR 2

extern "C" SDL_Texture* getCorrectRockTextureWithI(int i);// { return rockTextures[i]; }

extern "C" int getCorrectRockDrawY(int i, int size) {
    return ((numberOfRowsToDraw - (rocks[i].row - currentRow)) * (g_height / numberOfRowsToDraw)) - size / 2;
}
extern "C" void drawRock(int i);
extern "C" int getCarX(int i) { return (cars[i].position * float(g_width) / horizontalResolution); }
extern "C" int getCarY(int i, int h) { return (numberOfRowsToDraw - (cars[i].row - currentRow)) * (g_height / numberOfRowsToDraw) - h / 2;}
extern "C" int getCarsRowType(int i) { return rowType[cars[i].row]; }
extern "C" SDL_Texture* getCarTextureR(int i) { return carTexturesR[cars[i].type]; }
extern "C" SDL_Texture* getCarTextureL(int i) { return carTexturesL[cars[i].type]; }
extern "C" int getGPlayable() { return g_playable; }
extern "C" float getPlayerRowF() { return playerRowF; }
extern "C" float getPlayerColumnF() { return playerColumnF; }
extern "C" int getPlayerRow() { return playerRow; }
extern "C" int getPlayerColumn() { return playerColumn; }
extern "C" float getFloatCurrentRow() { return currentRow; }
extern "C" void drawCar(int i);

extern "C" int getRectY(int i) {
    return (numberOfRowsToDraw - (i - currentRow) - 0.5) * (g_height / numberOfRowsToDraw);
}

extern "C" float makeCarPosition(int i) {
return horizontalResolution * (rowType[i] == ROADL ? -0.4 : 1.4);
}

extern "C" void generateCars(int i);

extern "C" int* getRowType() { return rowType; } 

extern "C" void updateCar(int i);

<<<<<<< HEAD
extern "C" void cleanupCars();
=======
extern "C" void cleanupCars() {
    for (int j = 0; j < carsSize; j++) {
        if (cars[j].exist)
            if (cars[j].position < -0.5 * horizontalResolution
                    || cars[j].position > 1.5 * horizontalResolution
                    || cars[j].row < (currentRow - numberOfRowsToDraw))
                removeCar(j);
    }
}
>>>>>>> refs/remotes/origin/master

extern "C" int getRenderPlayY(int h, float x) {
    return ((numberOfRowsToDraw - (x - currentRow)) * (g_height / numberOfRowsToDraw)) - h / 2;
}

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

extern "C" void renderPlayer(float x, float y, int state);

extern "C" bool getComplexAndCondition(int i) {
    return cars[i].exist && abs(float(cars[i].row) - playerRowF) < 0.25 &&
            cars[i].position < playerColumnF &&
            playerColumnF < cars[i].position + cars[i].width;
}

extern "C" bool cameraAndPlayerUpdate();

extern "C" int drawGame();

extern "C" void initGame();
extern "C" void firstInitOfGame();

#endif //CROOSYROAD_GAMEPLAY_H
