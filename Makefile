all:
	g++ -g -w -no-pie -O0 main.cpp gameplay.s main.s score.s transition.s -o goosyRoad -lSDL2_ttf -lSDL2_image -lSDL2
