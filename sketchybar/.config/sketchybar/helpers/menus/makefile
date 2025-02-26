# Se CC non è definito, usa clang
CC ?= clang
# Se CFLAGS non è definito, usa C23 con ottimizzazioni
CFLAGS ?= -std=c2x -O3 -Wall -Wextra -pedantic

bin/menus: menus.c | bin
	$(CC) $(CFLAGS) -F/System/Library/PrivateFrameworks/ -framework Carbon -framework SkyLight $< -o $@

bin:
	mkdir -p bin

clean:
	rm -rf bin

.PHONY: clean