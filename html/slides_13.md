---
author: Stephen Molloy
---

# Function args

We saw an example of calling a function when we organised the syscalls

- Arg 0 in rax
- Arg 1 in rdi
- Arg 2 in rsi
- Etc.

But this is just a convention.  x86_64 doesn't specify that you must do this

In reality, function args are not really a concept at this level.  A function is a fancy `jmp`.

We are free to make our own convention.

- Pass via the stack (as Linux does when the executable was called)
- Pass via registers (as Linux does with syscalls)
- Something fancier

Here I will copy the syscall way of working

