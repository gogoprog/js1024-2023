default: build

compile:
	haxe build.hxml

run: compile
	python temp/main.py

build: run
	mkdir -p build
	cp temp/out.frag temp/final.frag
	for i in {1..29}; do sed '1d' -i temp/final.frag; done
	for i in {1..4}; do sed '$$d' -i temp/final.frag; done
	cat src/before.html > build/index.html
	cat temp/final.frag >> build/index.html
	cat src/after.html >> build/index.html

retail: compile
	mkdir -p retail
	terser --compress unsafe_arrows=true,unsafe=true,toplevel=true,passes=8 --mangle --mangle-props --toplevel --ecma 6 -O ascii_only=true -- temp/main.js > temp/main.min.js
	regpack temp/main.min.js > temp/main.min.regpack.js
	cat src/before.html > retail/index.html
	cat temp/main.min.regpack.js >> retail/index.html
	cat src/after.html >> retail/index.html
	stat temp/main.min.regpack.js | grep Size

.PHONY: build retail
