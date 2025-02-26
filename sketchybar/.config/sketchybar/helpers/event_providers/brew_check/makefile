# Se CC non è definito, usa clang
CC ?= clang
# Se CFLAGS non è definito, usa C23 con ottimizzazioni
CFLAGS ?= -std=c2x -O3 -Wall -Wextra -pedantic

bin/brew_check: brew_check.c brew.h ../sketchybar.h | bin
	$(CC) $(CFLAGS) $< -o $@

bin:
	mkdir -p bin

clean:
	rm -rf bin

.PHONY: clean