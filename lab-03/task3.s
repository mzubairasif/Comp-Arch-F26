# init mem for testing

li x1, 25
li x2, 50

sw x1, 0x118(x0)
sw x2, 0x11C(x0)

#--------------------

addi x10, x0, 0x100 # v[ ]
addi x11, x0, 6 # k

jal x1, swap

j exit

swap:
    slli x11, x11, 2 # idx*4 to get offset
    add x10, x10, x11 # get abs address = base + offset
    
    lw x5, 0(x10) # load v[k]
    lw x6, 4(x10) # load v[k+1]

    sw x6, 0(x10) # store v[k+1] at v[k] loc
    sw x5, 4(x10) # store v[k] at v[k+1] loc

    jalr x0, 0(x1)
exit: