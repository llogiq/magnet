# magnet Makefile (C) 2010 Andre Bogus
# You may want to edit the following variables for configuration
CC = gcc
INSTALL = install
PREFIX = /usr/local
PREFIX_BIN = $(PREFIX)/sbin
PKGCONFIG = $(shell which pkg-config)
LUA_PKG = lua5.1

ifeq ($(PKGCONFIG), )
LUA_CFLAGS = -I/usr/include/$(LUA_PKG)
LUA_LDFLAGS = -l$(LUA_PKG)
else
LUA_CFLAGS = $(shell $(PKGCONFIG) $(LUA_PKG) --cflags)
LUA_LDFLAGS = $(shell $(PKGCONFIG) $(LUA_PKG) --libs)
endif

CFLAGS = -Wall $(LUA_CFLAGS)
LDFLAGS = $(LUA_LDFLAGS) -lfcgi -ldl -lm -Wl,--export-dynamic
UID = $(shell id -u)

.PHONY: clean all install

all:    magnet

install: all
ifeq ($(UID), 0)
	@echo Installing magnet to $(PREFIX_BIN)...
	@$(INSTALL) -m 755 -o root -g root magnet $(PREFIX_BIN)/fcgi
else
	@echo You need to be root to install magnet
endif

clean:
	@echo Removing magnet...
	@rm -f magnet
    
test:    all
	@echo $(shell SCRIPT_FILENAME=$(PWD)/test.lua ./magnet)

magnet: magnet.c
	@echo Compiling magnet...
	@$(CC) -o $@ $? $(CFLAGS) $(LDFLAGS)
