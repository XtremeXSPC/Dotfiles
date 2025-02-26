# Se CC non è definito, usa clang
CC ?= clang
# Se CFLAGS non è definito, usa C23 con ottimizzazioni
CFLAGS ?= -std=c2x -O3 -Wall -Wextra -pedantic

bin/network_load: network_load.c network.h ../sketchybar.h | bin
	$(CC) $(CFLAGS) $< -o $@ -lm

bin:
	mkdir -p bin

clean:
	rm -rf bin

.PHONY: clean