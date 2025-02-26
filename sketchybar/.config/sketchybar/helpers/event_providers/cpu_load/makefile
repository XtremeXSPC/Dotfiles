# Se CC non è definito, usa clang
CC ?= clang
# Se CFLAGS non è definito, usa C23 con ottimizzazioni
CFLAGS ?= -std=c2x -O3 -Wall -Wextra -pedantic

bin/cpu_load: cpu_load.c cpu.h ../sketchybar.h | bin
	$(CC) $(CFLAGS) $< -o $@

bin:
	mkdir -p bin

clean:
	rm -rf bin

.PHONY: clean