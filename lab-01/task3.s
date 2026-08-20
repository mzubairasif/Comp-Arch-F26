# x1=a
# x2=b
# x3=c
# x4=d
# x5=e

# x6=a+b
# x7=a-d
# x8=b-a

.text
.globl main
main:
    li x1, 5    # a=5
    addi x2, x0, 0  # b = 0 + 0
    addi x1, x2, 32 # a = b + 32

    add x6, x1, x2  # a + b
    addi x4, x6, -5 # d = (a + b) - 5

    sub x7, x1, x4  # a - d
    sub x8, x2, x1  # b - a

    add x5, x7, x8  # e = (a - d) + (b - a)
    add x5, x5, x4  # e = e + d

    add x5, x5, x5  # e = e + e
    add x5, x1, x2  # e = a + b
    add x5, x5, x4  # e = e + d

end:
    j end