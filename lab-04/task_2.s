li x10, 10

jal x1, tri
j end

tri:
    addi sp, sp, -8 # space for 2 items
    sw x1, 4(sp)    # save ret addr
    sw x10, 0(sp)   # save arg n

    addi x5, x10, -1    #x5 = n-1
    bge x5, x0, L1      # ig (n-1)>=0, goto L1

    addi x10, x0, 0 # ret 0
    addi sp, sp, 8  # pop stack
    jalr x0, 0(x1)  # return

L1:
    addi, x10, x10, -1  # arg = n-1
    jal x1, tri

    addi x6, x10, 0 # save result of tri(n-1)
    lw x10, 0(sp)   # restore original n
    lw x1, 4(sp)    # restore ret addr
    addi sp, sp, 8  # pop stack

    add x10, x10, x6    # n + tri(n-1)
    jalr x0, 0(x1)  # return
    
end: