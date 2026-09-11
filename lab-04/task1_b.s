li x10, 3
jal x1, fact

j exit

fact:
    addi, x5, x0, 1

    loop:

    mul x5, x5, x10
    addi x10, x10, -1
    beq x0, x10, dne
    jal x0, loop

    dne:
    addi x10, x5, 0
    jalr x0, 0(x1)

exit: