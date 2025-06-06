---
author: Stephen Molloy
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
pop rdi   ; Pops the top value from the stack,
          ; increases rsp by 4, and puts it into rdi
push r10  ; Pushes the value held in r10 onto the stack
          ; and decreases rsp by 4
```

So the OS pushes the arguments onto the stack in reverse order, and then pushes the number of arguments.

Note that the calling command (`./hello`) is the zeroth argument.

