AS = nasm
ASMFLAGS = -g -f elf64
LD = ld
LINKFLAGS = -g

SRC = src
OBJ = objs

SRCS = $(wildcard $(SRC)/*.asm)
OBJS = $(patsubst $(SRC)/%.asm, $(OBJ)/%.o, $(SRCS))

BINDIR = bin
BIN = $(BINDIR)/asm_server

all: $(BIN)

$(BIN): $(OBJS)
	@mkdir -p $(BINDIR)
	$(LD) $(LINKFLAGS) -o $@ $^

$(OBJS): $(SRCS)
	@mkdir -p $(OBJ)
	$(AS) $(ASMFLAGS) -o $@ $^

$(OBJ):
	@mkdir -p $@

run: $(BIN)
	./$(BIN)

