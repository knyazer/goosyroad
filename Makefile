all:
	g++ -g -w -no-pie -O0 vars.s gameplay.s helpers.s main.s score.s transition.s funcs.s menu.s -o goosyRoad -lSDL2_ttf -lSDL2_image -lSDL2
