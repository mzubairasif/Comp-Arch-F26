# x = x11

# 1 = x1
# 2 = x2
# 3 = x3
# 4 = x4

# a = x5
# b = x6
# c = x7
# d = x8

li x1, 1
li x2, 2
li x3, 3
li x4, 4

li x11, 1

beq x11, x1, Case_1
beq x11, x2, Case_2
beq x11, x3, Case_3
beq x11, x4, Case_4
beq x0, x0, default

Case_1:
    add x5, x6, x7
    beq x0, x0, Exit

Case_2:
    sub x5, x6, x7
    beq x0, x0, Exit

Case_3:
    add x5, x6, x6
    beq x0, x0, Exit

Case_4:
    li x30, 2
    div x5, x6, x30
    beq x0, x0, Exit


default:
    li x5, 0
    beq x0, x0, Exit

Exit: