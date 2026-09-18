# INIT MEM FOR TESTING ONLY
li x10, 6   # fib(6) = 8
# ----------------------

jal x1, fib
j exit

fib:
    addi x5, x0, 2
    blt x10, x5, fib_base  # if n < 2, return n directly

    addi sp, sp, -12
    sw x1, 12(sp)   # save return address (ra)
    sw x10, 8(sp)   # save arg n
    sw x8, 4(sp)    # save s0 across nested calls

    # First nested call: fib(n - 1)
    addi x10, x10, -1
    jal x1, fib
    addi x8, x10, 0 # s0 = result of fib(n - 1)

    # Second nested call: fib(n - 2)
    lw x10, 8(sp)   # restore original n
    addi x10, x10, -2
    jal x1, fib # x10 = result of fib(n - 2)

    # fib(n - 1) + fib(n - 2)
    add x10, x8, x10

    # unwind stack
    lw x8, 4(sp)
    lw x1, 12(sp)
    addi sp, sp, 12
    jalr x0, 0(x1)

fib_base:
    # Leaf return: x10 already contains n (0 or 1)
    jalr x0, 0(x1)

exit: