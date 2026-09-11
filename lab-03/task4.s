# init mem for testing

li x10, 0x100   # x base addr
li x11, 0x200   # y base addr

li x12, 0x74657374  # hex for "test"

sw x12, 0(x11)
sw x0, 4(x11)   # "\0"
#--------------------

jal x1, strcpy

j end

strcpy:
    addi sp, sp, -4
    sw x19, 0(sp)
    li x19, 0   # i

    addi x19, x0, 0


    loop:
        add  x5, x11, x19    # calc y addr
        lbu  x6, 0(x5)       # load y[i]

        add  x7, x10, x19    # calc x addr
        sb   x6, 0(x7)       # store into x[i]

        beq  x6, x0, dne     # exit after storing '\0'

        addi x19, x19, 1     # i++
        jal  x0, loop

    dne:
        lw x19, 0(x2)
        addi x2, x2, 4
        jalr x0, 0(x1)

end:


