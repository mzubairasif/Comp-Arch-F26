# i = x22
# sum = x23


li x20, 0x200
li x22, 0
Loop1:
    sw x22, 0(x20)
    addi x20, x20, 0x4

    li x10, 10
    addi x22, x22, 1
    bne x22, x10, Loop1

    beq x0, x0, Exit1
Exit1:

li x20, 0x200
li x23, 0
li x22, 0
Loop2:
    lw x24, 0(x20)
    addi x20, x20, 0x4

    li x10, 10
    add x23, x23, x24
    bne x22, x10, Loop2

    beq x0, x0, Exit2
Exit2:
