# i = x22
# sum = x23

li x10, 10 # terminating cond var


li x20, 0x200 # init address
li x22, 0
Loop1:
    sw x22, 0(x20)
    addi x20, x20, 0x4

    addi x22, x22, 1
    bne x22, x10, Loop1


li x20, 0x200 # reset address
li x23, 0
li x22, 0
Loop2:
    lw x24, 0(x20)
    addi x20, x20, 0x4

    add x23, x23, x24

    addi x22, x22, 1
    bne x22, x10, Loop2
