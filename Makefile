name = two-colors
gamefile = game.love

default: dev

dev: src/*
	love src

build: src/* build/
	mkdir -p build
	cd src && zip -9 -r ${gamefile} . -x *.md && mv ${gamefile} ../build/${gamefile}

run:
	love build/${gamefile}

build-web: build/
	bun i
	bunx love.js build/game.love build/web -c --title ${name}
	cd build && zip -9 -r ${name}-build-web.zip ./web

run-build-web: build/
	cd build/web && python3 -m http.server 8000

clean:
	rm -rf build