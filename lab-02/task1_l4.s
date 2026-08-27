# i = x22
# k = x24

Loop:
    slli x10, x22, 3
    add x1, x10, x25
    ld x9, 0(x10)
    bne x9, x24, Exit
    addi x22, x22, 1
    beq, x0, x0, Loop
Exit: