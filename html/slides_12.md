---
author: Stephen Molloy
---

# Functions

Functions are called using the `call` keyword and returned from with the `ret` keyword

`call` knows where to jump to since it takes a memory address, but how does the CPU know which memory address to return to?

- The return address is stored on the stack.

What about function arguments?  How are they passed?

