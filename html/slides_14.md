---
author: Stephen Molloy
---

# Not covered

- Floating point
    - Dedicated registers
    - Hardware based parallelisation (SIMD)
- Advanced instructions: For example:
    - `stosb`: stores the value of `rax` to the location pointed to by `rdi` and increments `rdi`
    - `rep`: rep repeats a command while `rcx`!=0, decrementing `rcx` each time
- A whole bunch of other stuf
    - Remember, I am nothing more than an enthusiastic idiot

```asm
%macro ZERO_MEM 2
    mov rdi, %1
    mov rcx, %2
    xor rax, rax
    rep stosb    ; stosb stores the value of RAX to the location pointed to by RDI and increments RDI
                 ; rep repeats this while RCX!=0, decrementing RCX each time
%endmacro
```

