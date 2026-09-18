# INIT MEM FOR TESTING ONLY
li x10, 0x200      # base address
li x11, 10  # len

li x5, 23
sw x5, 0(x10)
li x5, 12
sw x5, 4(x10)
li x5, 5
sw x5, 8(x10)
li x5, 20
sw x5, 12(x10)
li x5, 21
sw x5, 16(x10)
li x5, 50
sw x5, 20(x10)
li x5, 65
sw x5, 24(x10)
li x5, 44
sw x5, 28(x10)
li x5, 75
sw x5, 32(x10)
li x5, 99
sw x5, 36(x10)

# --------------------



jal x1, bubble        # call procedure
j exit

bubble:
    # edge check:
    beq x10, x0, ret
    addi x5, x0, 1
    ble x11, x5, ret

Do:
    addi x7, x0, 0        # swap = false
    addi x12, x0, 1       # i = 1

for:
    bge x12, x11, endwhile
    slli x5, x12, 2       # offset
    add x5, x5, x10       # arr[i]
    addi x6, x5, -4       # arr[i-1]

    lw x28, 0(x5)         # arr[i]
    lw x29, 0(x6)         # arr[i-1]

    bge x28, x29, endfor  

    # swap
    sw x29, 0(x5)
    sw x28, 0(x6)
    addi x7, x0, 1        # swap = true

endfor:
    addi x12, x12, 1      # i++
    jal x0, for

endwhile:
    bne x7, x0, Do        # repeat pass if a swap occurred

ret:
    jalr x0, 0(x1)        

exit: