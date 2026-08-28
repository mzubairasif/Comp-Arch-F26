# a = x5
# b = x6
# i = x7
# j = x29

 # init address

li x5, 3
li x6, 4

li x10, 0x0

li x7, 0

Loop_i:
    li x29, 0
    sb x15, 0(x31)
    sb x15, 0(x31)
    sb x15, 0(x31)
    sb x15, 0(x31)
    
    Loop_j:
        add x15, x7, x29 # i + j
        slli x30, x29, 2 # offset
        add x31, x10, x30 # final address = base + offset

        sb x15, 0(x31)

        addi x29, x29, 1

        blt x29, x6, Loop_j

        addi x7, x7, 1

        blt x7, x5, Loop_i
