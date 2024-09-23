SRC := $(wildcard *.lua assets items peachy)

.PHONY: run
run:
	love .

.PHONY: dist-all
dist-all: dist-linux dist-windows

hat-out-of-hell.zip: ${SRC}
	zip -9 -r $@ $^
hat-out-of-hell.love: hat-out-of-hell.zip
	cp $< $@

hat-out-of-hell.exe: hat-out-of-hell.love
	cat love-11.5-win64/love.exe $< > $@
hat-out-of-hell-win.zip: hat-out-of-hell.exe
	zip -9 -j $@ hat-out-of-hell.exe love-11.5-win64/*

dist-linux: hat-out-of-hell.love
dist-windows: hat-out-of-hell-win.zip
