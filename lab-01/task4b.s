# a = 0x100, 8 bit
# b = 0x200, 16 bit
# c = 0x300, 32 bit

# x1 = a[i]
# x2 = b[i]
# x3 = c[i]

# x5, x6, x7 offset calcs

# 0th iter
lb x1, 0x100(x0)
lh x2, 0x200(x0)
add x4, x1, x2
sw x4, 0x300(x0)

# 1th iter
lb x1, 0x100(x0)
lh x2, 0x200(x0)
add x4, x1, x2
li x5, 32
sw x4, 0x300(x5)

# 2th iter
lb x1, 0x100(x0)
lh x2, 0x200(x0)
add x4, x1, x2
li x6, 64
sw x4, 0x300(x6)

# 3th iter
lb x1, 0x100(x0)
lh x2, 0x200(x0)
li x7, 96
add x4, x1, x2
sw x4, 0x300(x7)

