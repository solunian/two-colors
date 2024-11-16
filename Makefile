gamefile = game.love

default: dev

dev: src/*
	love src

build: src/*
	mkdir -p build
	cd src && zip -9 -r ${gamefile} . -x *.md && mv ${gamefile} ../build/${gamefile} && cd ..

run:
	love build/${gamefile}

clean:
	rm -rf build