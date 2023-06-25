default: compile run

compile:
	mkdir -p build
	g++ src/*.cpp -o build/main -Isrc/include -Wall -Wno-missing-braces -lraylib -lm -lpthread -ldl -lX11

run:
	./build/main

clean:
	rm -rf build/*
