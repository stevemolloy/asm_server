CC = clang
CFLAGS = -Wall -Wpedantic -Wextra -std=c99 -ggdb -Wshadow -fsanitize=address
CINCLUDES =
CLIBS =

SRC = src
OBJ = objs

SRCS = $(wildcard $(SRC)/*.c)
OBJS = $(patsubst $(SRC)/%.c, $(OBJ)/%.o, $(SRCS))

BINDIR = bin
BIN = $(BINDIR)/server

all: $(BIN) $(BINDIR)/asm_server

$(BINDIR)/asm_server: $(OBJ)/asm_server.o
	ld -g -o $(BINDIR)/asm_server $(OBJ)/asm_server.o

$(OBJ)/asm_server.o: $(SRC)/server.asm
	nasm -g -f elf64 -o $(OBJ)/asm_server.o $(SRC)/server.asm

$(BIN): $(OBJS)
	@mkdir -p $(@D)
	$(CC) $(CFLAGS) $^ -o $@ $(CLIBS)

$(OBJ)/%.o: $(SRC)/%.c
	@mkdir -p $(@D)
	$(CC) $(CFLAGS) $(CINCLUDES) -c $< -o $@

clean:
	rm -rf $(BINDIR) $(OBJ)

$(OBJ):
	@mkdir -p $@

run: $(BIN)
	$(BIN)

