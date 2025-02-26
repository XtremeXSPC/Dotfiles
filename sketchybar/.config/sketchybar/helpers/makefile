# Se CC non è definito, usa clang
CC ?= clang
# Se CFLAGS non è definito, usa C23 con ottimizzazioni
CFLAGS ?= -std=c2x -O3 -Wall -Wextra -pedantic

all:
	@if [ ! -d event_providers ]; then \
		echo "Error: directory 'event_providers' not found"; \
		exit 1; \
	fi
	@if [ ! -d menus ]; then \
		echo "Error: directory 'menus' not found"; \
		exit 1; \
	fi
	(cd event_providers && $(MAKE) CC="$(CC)" CFLAGS="$(CFLAGS)")
	(cd menus && $(MAKE) CC="$(CC)" CFLAGS="$(CFLAGS)")

clean:
	@if [ -d event_providers ]; then \
		(cd event_providers && $(MAKE) clean); \
	fi
	@if [ -d menus ]; then \
		(cd menus && $(MAKE) clean); \
	fi

.PHONY: all clean