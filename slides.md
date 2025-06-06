---
author: Stephen Molloy
---

# Back to basics. x86_64 Linux assembly

.

.

.

.

.

## Stephen Molloy

## 13th June, 2025

## MAXIV, Lund, Sweden

---

# Back to basics. x86_64 Linux assembly

Welcome to this intro to x86_64 assembly programming for Linux.

Please make sure to remember that I am nothing more than an enthusiastic idiot.

Do not confuse me with a real developer.

---

# Assembly

The language and the code you write are entirely specific to details of the CPU and the OS.

For example, ASM written for x86_64 Linux will almost certainly not work on x86_64 Windows:

    Even a basic "Hello world" will fail on another system

Why?

---

# OS-specific functionality

The OS provides access to the hardware: in/out streams, network, memory, etc.

This is typically done using `syscalls` -- requests to the operating system to provide specific functionality

For example, printing a string to `stdout` would be done by providing the address of the string in memory as well as its length, and then making the appropriate syscall

---

# CPU-specific features

## Instructions

Each CPU will come with its own instruction set.

For example, instructions that move data around, or that perform arithmetic operations on data

In many cases there will also be dedicated floating point instructions

## Data storage

Most CPU's have a small amount of storage space for data.  These are known as registers, and each can typically hold a single piece of data whose size in bits is equal to the bit-width of the CPU bus.

That is, the x86_64 registers are 64 bits wide.

(Note that this is different from the various caches levels in a CPU.  Register access is controlled by the programmer, while the differnt caches are not.)

Registers are accessible within one or two clock cycles, and so a couple of orders of magnitude faster than main memory access.

---

# x86_64 registers

| Register | 32 bit | 16 bit | 8 bit | Typical use   |
|----------|--------|--------|-------|---------------|
| rax      | eax    | ax     | ah,al | Return value  |
| rbx      | ebx    | bx     | bh,bl |               |
| rcx      | ecx    | cx     | ch,cl | Arg 4         |
| rdx      | edx    | dx     | dh,dl | Arg 3         |
| rsi      | esi    | si     | sil   | Arg 2         |
| rdi      | edi    | di     | dil   | Arg 1         |
| rbp      | ebp    | bp     | bpl   | Frame pointer |
| rsp      | esp    | sp     | spl   | Stack pointer |
| r8       | r8d    | r8w    | r8b   | Arg 5         |
| r9       | r9d    | r9w    | r9b   | Arg 6         |
| r10      | r10d   | r10w   | r10b  |               |
| r11      | r11d   | r11w   | r11b  |               |
| r12      | r12d   | r12w   | r12b  |               |
| r13      | r13d   | r13w   | r13b  |               |
| r14      | r14d   | r14w   | r14b  |               |
| r15      | r15d   | r15w   | r15b  |               |


There's a lot here that is a little tough, but an example will help

---

# What is before `Hello world`?

Can we write a function that does nothing?

A function that immediately returns to the prompt?

---

# Seg fault on return?

When a function is called, the CPU needs to know which memory address to jump back to.

This return address is stored on the stack.

So, the `ret` function will fetch this from the stack, and then jump to it.

But in this case, the `_start` function was never called!

`ret` will effectively jump to whatever garbage happens to be at the top of the stack --> segmentation fault.

Instead we need to tell the OS that we are done and that the process should be killed

---

# Syscalls

https://www.chromium.org/chromium-os/developer-library/reference/linux-constants/syscalls/#x86_64-64-bit

1. Find the number of the syscall you want
1. Place this value into the `rax` register
1. Place any other arguments into `rdi`, `rsi`, `rdx`, etc.
1. Issue the `syscall` instruction

## For example

Exiting a function is done by a syscall

```asm
mov rax, 60   ; the exit syscall has a value of 60
mov rdi, 0    ; the value to return
syscall       ; Go!
```

---

# Hello world

To print something to screen (i.e., to `stdout`), we need to know two things:

1. How to prepare the `write` syscall.
1. How to store data in our ASM file.

---

# Command line arguments

Data is passed to the executable via the `stack`

This is a region of memory that the OS provides to all executables.  It is indicated by the `rsp` register, and it grows downwards

| Stack                      |           |
|----------------------------|-----------|
| Etc.                       | rsp + ... |
| Address of second argument | rsp + 8   |
| Address of first argument  | rsp + 4   |
| Number of arguments        | rsp       |

The stack is manipulated by `pop`ping data off it, and `push`ing data to it.

```asm
pop rdi   ; Pops the top value from the stack, increases rsp by 4, and puts it into rdi
push r10  ; Pushes the value held in r10 onto the stack and decreases rsp by 4
```

So the OS pushes the arguments onto the stack in reverse order, and then pushes the number of arguments.

Note that the calling command (`./hello`) is the zeroth argument.

