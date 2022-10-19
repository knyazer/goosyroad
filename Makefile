all:
	g++ -g -w -no-pie -O3 main.cpp main.s -o goosyRoad -lSDL2_ttf -lSDL2_image -lSDL2
