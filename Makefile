SRC = src
OBJ = objs

SRCS = $(wildcard $(SRC)/*.asm)
OBJS = $(patsubst $(SRC)/%.asm, $(OBJ)/%.o, $(SRCS))

BINDIR = bin
BIN = $(BINDIR)/asm_server

all: $(BIN)

$(BIN): $(OBJS)
	@mkdir -p $(BINDIR)
	ld -g -o $@ $^

$(OBJS): $(SRCS)
	@mkdir -p $(OBJ)
	nasm -g -f elf64 -o $@ $^

# $(BIN): $(OBJS)
# 	@mkdir -p $(@D)
# 	$(CC) $(CFLAGS) $^ -o $@ $(CLIBS)

# $(OBJ)/%.o: $(SRC)/%.c
# 	@mkdir -p $(@D)
# 	$(CC) $(CFLAGS) $(CINCLUDES) -c $< -o $@

# clean:
# 	rm -rf $(BINDIR) $(OBJ)

$(OBJ):
	@mkdir -p $@

# run: $(BIN)
# 	$(BIN)

run: $(BINDIR)/asm_server
	./$(BINDIR)/asm_server

