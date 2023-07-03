default: compile run

compile:
	mkdir -p build
	g++ src/*.cpp -o build/main -Isrc/include -Wall -Wno-missing-braces -lraylib -lm -lpthread -ldl -lX11

run:
	./build/main

clean:
	rm -rf build/*


win: wincompile winrun

# run mkdir build if never run before because windows cmdline sucks
wininit:
	mkdir build

wincompile:
	g++ src/*.cpp -o build/main.exe -Wall -Wno-missing-braces -Iinclude/ -Isrc/include -Llib -lraylib -lopengl32 -lgdi32 -lwinmm

winrun:
	./build/main.exe

winclean:
	rmdir /s /q -p 
	del build/*
