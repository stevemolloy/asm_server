---
author: Stephen Molloy
---

# Loops

ASM has no constructs for while loops or for loops.

Instead it has a collection of commands to jump to different locations in the code.  Conditionally or unconditionally.

```asm
    mov rbx, 0
.loop:
    WRITE STDOUT, hello_msg, hello_msg_len
    inc rbx
    cmp rbx, 10
    jl .loop
```

```C
int i = 0;
while (i < 10) {
    fputs(hello_msg, stdout);
    i++;
}
```


