addi x10, x0, 10 # g
addi x11, x0, 5 # h
addi x12, x0, 6 # i
addi x13, x0, 2 # j

li sp, 0x100

sw x10, 0(x2)
sw x11, -4(x2)
sw x12, -8(x2)
sw x13, -12(x2)


jal x1, leaf_example

li x10, 1
addi x11, x20, 0
ecall   # should give (10+5) - (6+2) = 7

j exit

leaf_example:
    add x18, x10, x11
    add x19, x12, x13

    sub x20, x18, x19
    
    jalr x0, 0(x1)
exit: