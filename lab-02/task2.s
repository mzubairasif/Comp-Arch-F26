# x = x20

# a = x21
# b = x22
# c = x23

li x1, 1
li x2, 2
li x3, 3
li x4, 4

# dummy values ONLY FOR TESTING 
li x20, 2 # for testing
li x22, 8
li x23, 3
# ---------------

beq x20, x1, Case_1
beq x20, x2, Case_2
beq x20, x3, Case_3
beq x20, x4, Case_4
beq x0, x0, default

Case_1:
    add x21, x22, x23
    beq x0, x0, Exit

Case_2:
    sub x21, x22, x23
    beq x0, x0, Exit

Case_3:
    slli x21, x22, 1
    beq x0, x0, Exit

Case_4:
    srli x21, x22, 1
    beq x0, x0, Exit

default:
    li x21, 0
Exit: