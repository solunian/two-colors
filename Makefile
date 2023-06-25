default: compile run

compile:
	mkdir -p build
	g++ src/main.cpp -o build/game -Wall -Wno-missing-braces -lraylib -lm -lpthread -ldl -lX11

run:
	./build/game

clean:
	rm -rf build/*
