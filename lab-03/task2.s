# init mem for testing
addi x10, x0, 10 # g
addi x11, x0, 5 # h
addi x12, x0, 6 # i
addi x13, x0, 2 # j
#--------------------

jal x1, leaf_example


# ecall-ing:
addi x11, x10, 0    
li x10, 1
ecall   # should give (10+5) - (6+2) = 7

j exit

leaf_example:
    # push x18, x19 and x20 onto stack
    addi x2, x2, -12
    sw x18, 0(x2)
    sw x19, 4(x2)
    sw x20, 8(x2)

    add x18, x10, x11   # (g + h)
    add x19, x12, x13   # (i + j)

    sub x20, x18, x19   # f = (g + h) - (i + j)
    addi x10, x20, 0    #ret val stored at x10


    # pop vals back after usage
    lw x18, 0(x2)
    lw x19, 4(x2)
    lw x20, 8(x2)
    addi x2, x2, 12
    
    jalr x0, 0(x1)

exit: