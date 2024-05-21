      .global _start

_start:
      LDR R2, str1
      b .
str1: .word 0xAA55AA55
