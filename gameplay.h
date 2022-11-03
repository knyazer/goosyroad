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

const int carsSize = 100, rocksSize = 1000;
int carsFirstEmpty; // pointer to the first empty space in an array of cars
Car cars[carsSize];
Rock rocks[rocksSize];

extern "C" Car* getCars() { return cars; }
extern "C" Rock* getRocks() { return rocks; }

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

extern "C" SDL_Texture* getCorrectRockTextureWithI(int i) { return rockTextures[i]; }

extern "C" int getCorrectRockDrawY(int i, int size) {
    return ((numberOfRowsToDraw - (rocks[i].row - currentRow)) * (g_height / numberOfRowsToDraw)) - size / 2;
}
extern "C" void drawRock(int i);
extern "C" int getCarX(int i) { return (cars[i].position * float(g_width) / horizontalResolution); }
extern "C" int getCarY(int i, int h) { return (numberOfRowsToDraw - (cars[i].row - currentRow)) * (g_height / numberOfRowsToDraw) - h / 2;}
extern "C" int getCarsRowType(int i) { return rowType[cars[i].row]; }
extern "C" SDL_Texture* getCarTextureR(int i) { return carTexturesR[cars[i].type]; }
extern "C" SDL_Texture* getCarTextureL(int i) { return carTexturesL[cars[i].type]; }

extern "C" void drawCar(int i);

extern "C" int getRectY(int i) {
    return (numberOfRowsToDraw - (i - currentRow) - 0.5) * (g_height / numberOfRowsToDraw);
}

void generateCars(int i) {
    if (g_static_render)
        return;

    if (rand() % 150 == 0) {
        bool dontGenerate = false;
        float maxSpeed = 0.15;
        float minSpeed = 0.025;

        for (int j = 0; j < carsSize; j++) {
            if (cars[j].row == i && cars[j].exist) {
                if ((rowType[i] == ROADL && cars[j].position < 1) ||
                    (rowType[i] == ROADR && cars[j].position > horizontalResolution - 1 - cars[j].width)) {
                    dontGenerate = true;
                    break;
                }

                float d;
                if (rowType[i] == ROADL)
                    d = 1.4 * horizontalResolution - cars[j].position;
                else
                    d = cars[j].position + 0.4 * horizontalResolution;


                float t = d / cars[j].speed;
                float v = (1.4 * horizontalResolution) / t;
                maxSpeed = std::min(maxSpeed, v);
            }
        }

        if (!dontGenerate) {
            int carIndex = addCar();
            if (carIndex == -1) {
                std::cout << "some problems with car generator" << std::endl;
                return;
            }

            cars[carIndex].row = i;
            cars[carIndex].position = horizontalResolution * (rowType[i] == ROADL ? -0.4 : 1.4);
            cars[carIndex].speed = minSpeed + (float(rand()) / float(RAND_MAX)) * (maxSpeed - minSpeed);
            cars[carIndex].type = 0;
            cars[carIndex].width = 1;
            cars[carIndex].exist = true;
        }
    }
}

extern "C" int* getRowType() { return rowType; } 

extern "C" void updateCar(int i);

void cleanupCars() {
    for (int j = 0; j < carsSize; j++) {
        if (cars[j].exist)
            if (cars[j].position < -0.5 * horizontalResolution
                    || cars[j].position > 1.5 * horizontalResolution
                    || cars[j].row < (currentRow - numberOfRowsToDraw))
                removeCar(j);
    }
}

extern "C" int getRenderPlayY(int h, float x) {
    return ((numberOfRowsToDraw - (x - currentRow)) * (g_height / numberOfRowsToDraw)) - h / 2;
}

extern "C" void renderPlayer(float x, float y, int state);

bool cameraAndPlayerUpdate() {
    if (!g_playable) {
        currentRow += 0.005;
        return false;
    }
    if (g_static_render)
        return false;

    bool forwardEmpty = true, backwardEmpty = true, leftEmpty = true, rightEmpty = true;
    if (rowType[playerRow + 1] == SAVE)
        for (int i = 0; i < rocksSize; i++)
            if (rocks[i].row == playerRow + 1 && rocks[i].position == playerColumn)
                forwardEmpty = false;

    if (playerRow >= 1 && rowType[playerRow - 1] == SAVE)
        for (int i = 0; i < rocksSize; i++)
            if (rocks[i].row == playerRow - 1 && rocks[i].position == playerColumn)
                backwardEmpty = false;

    if (rowType[playerRow] == SAVE) {
        for (int i = 0; i < rocksSize; i++) {
            if (rocks[i].row == playerRow && rocks[i].position == playerColumn + 1)
                leftEmpty = false;
            if (rocks[i].row == playerRow && rocks[i].position == playerColumn - 1)
                rightEmpty = false;
        }
    }

    const int blockedLen = 30;
    static int blockedPath = 0;
    if (g_forward) {
        if (forwardEmpty) {
            targetRow += 0.4;
            playerRow++;
        }
        else
            blockedPath = blockedLen;
    }
    if (g_backward) {
        if (backwardEmpty) {
            targetRow -= 0.4;
            playerRow--;
        }
        else
            blockedPath = blockedLen;
    }
    if (g_left) {
        playerDirection = 0;
        if (leftEmpty && playerColumn < horizontalResolution - 1)
            playerColumn++;
        else
            blockedPath = blockedLen;
    }
    if (g_right) {
        playerDirection = 1;
        if (rightEmpty && playerColumn > 1)
            playerColumn--;
        else
            blockedPath = blockedLen;
    }
    if (blockedPath > 0)
        blockedPath--;

    if (std::abs(playerRow - playerRowF) > eps)
        playerRowF += sign(playerRow - playerRowF) * eps;

    if (std::abs(playerColumn - playerColumnF) > eps)
        playerColumnF += sign(playerColumn - playerColumnF) * eps;

    if (!g_no_render && playerRowF > (currentRow + 3))
        targetRow += 0.05 * ((playerRowF - currentRow - 3) / numberOfRowsToDraw);

    if (!g_no_render)
        targetRow += 0.005;

    currentRow = 0.98 * currentRow + 0.02 * targetRow;

    return blockedPath != 0;
}

extern "C" int drawGame() {
    if (!g_no_render) {
        SDL_SetRenderDrawColor(renderer, 87, 148, 105, g_alpha);
        SDL_RenderFillRect(renderer, &g_screen);
    }

    bool blocked = cameraAndPlayerUpdate();

    int l = currentRow - 1, h = currentRow + numberOfRowsToDraw + 2;
    for (int i = h; i > l; i--) {
        if (rowType[i] == SAVE)
            renderSave(i);

        if (rowType[i] == ROADL || rowType[i] == ROADR) {
            renderRoad(i);
        }
    }

    drawCars(l, h);
    drawRocks(l, h);

    for (int i = currentRow + numberOfRowsToDraw * 3 + 2; i > currentRow - 1; i--) {
        if (rowType[i] == ROADL || rowType[i] == ROADR) {
            generateCars(i);
            updateCar(i);
        }
    }

    cleanupCars();

    if (g_playable)
        renderPlayer(playerRowF, playerColumnF, blocked ? 1 : 0);

    if (g_playable && !g_no_render) {
        g_current_score = std::max(g_current_score, playerRow - 2);

        char buffer[30];
        sprintf(buffer, "%d", g_current_score);
        drawText(buffer, 1, 219, 167, 11);
    }


    for (int i = 0; i < carsSize; i++) {
        if (cars[i].exist && abs(float(cars[i].row) - playerRowF) < 0.25 &&
            cars[i].position < playerColumnF &&
            playerColumnF < cars[i].position + cars[i].width)
            return 1;
    }

    if (playerRowF < currentRow - 0.75)
        return 1;

    if (playerRow >= 999)
        return 1;

    return 0;
}

extern "C" void initGame() {
    for (int i = 0; i < 8; i++)
        rowType[i] = SAVE;
    rowType[8] = (rand() % 2) + 1;
    for (int i = 9; i < 1000; i++) {
        float dangerWeight = i / 50 + 1;

        int x = rand() % int(200 * dangerWeight + 200);
        if (x < 200)
            rowType[i] = SAVE;
        else
            rowType[i] = (rand() % 2) + 1;
    }

    for (int i = 0; i < carsSize; i++)
        cars[i].exist = false;
    carsFirstEmpty = 0;

    int k = 0;
    for (int i = 6; i < 1000; i++) {
        if (rowType[i] == SAVE) {
            int num = 0;
            do {
                num++;
                rocks[k].row = i;
                rocks[k].position = (rand() % (horizontalResolution - 1)) + 1;
                rocks[k].type = (rand() % 6);
                k++;
                if (k >= rocksSize)
                    break;
            } while (rand() % 10 < 5 && num + 4 < horizontalResolution);

            for (int j = k - num; j < k; j++)
                for (int m = j + 1; m < k; m++)
                    if (rocks[m].position == rocks[j].position)
                        rocks[j].row = -1000;

            if (k >= rocksSize)
                break;
        }
    }



    g_no_render = true;
    bool playable_stored = g_playable;
    g_playable = false;
    for (int i = 0; i < 600; i++)
        drawGame();
    g_playable = playable_stored;
    g_no_render = false;

    currentRow = 0;
    targetRow = 0;

    eps = 0.05;

    numberOfRowsToDraw = 12;
    horizontalResolution = 12;

    playerDirection = rand() % 2;

    playerRow = 3;
    playerColumn = horizontalResolution / 2;

    playerRowF = playerRow;
    playerColumnF = playerColumn;

    if (g_playable && !g_static_render)
        g_current_score = 1;
}

extern "C" void firstInitOfGame();

#endif //CROOSYROAD_GAMEPLAY_H
