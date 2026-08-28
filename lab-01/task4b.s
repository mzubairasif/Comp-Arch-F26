# base addresses
li x11, 0x100
li x12, 0x200
li x13, 0x300

# 0th iter
lb x1, 0(x11)   # x1 = a[i], 1 byte
lh x2, 0(x12)   # x2 = b[i], 2 byte
add x3, x1, x2  # x3 = c[i], 4 byte
sw x3, 0(x13)

# 1th iter
lb x1, 1(x11)
lh x2, 2(x12)
add x3, x1, x2
sw x3, 4(x13)

# 2th iter
lb x1, 2(x11)
lh x2, 4(x12)
add x3, x1, x2
sw x3, 8(x13)

# 3th iter
lb x1, 3(x11)
lh x2, 6(x12)
add x3, x1, x2
sw x3, 12(x13)

end:
    j end

