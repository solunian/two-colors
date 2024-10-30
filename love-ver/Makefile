default: dev

dev: main.lua
	love .

build: main.lua
	 zip -9 -r game.love . -x Makefile game.love

clean:
	rm game.love