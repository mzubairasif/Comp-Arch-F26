# x19 = f
# x20 = g
# x21 = h
# x22 = i
# x23 = j

bne x22, x23, Else
# imm[12]    imm[10:5]  src2       src1        fun3  imm[4:1]   imm[11]   opcode
# 0          000000     10111      10110       000   0110       0         1100011

add x19, x20, x21
beq x0, x0, Exit

Else:
    sub x19, x20, x21
Exit: