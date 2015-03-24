CC = clang
COFFEE = coffee
CFLAGS = -std=c11 -Wall -Werror
LIB_COMPILE_FLAGS = -fpic
LIB_LINK_FLAGS = -shared
LFLAGS =
DEPS = libmylib.h
OBJ = libmylib.so
JS = run.js

%.o: %.c $(DEPS)
	$(CC) -c $(CFLAGS) $(LIB_COMPILE_FLAGS) $^
#	find . -name "*.gch" -exec rm '{}' ';'

%.so: %.o
	$(CC) $(LIB_LINK_FLAGS) $^ -o $@

%.js: %.coffee
	$(COFFEE) -c $^

out: $(OBJ) $(JS)

.PHONY: clean
clean:
	rm -f $(OBJ)
	rm -f $(JS)
	rm -f $(wildcard *.gch)
