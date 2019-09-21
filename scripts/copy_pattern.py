import sys

src = sys.argv[1]
src_idx = int(sys.argv[2], 0)
dst = sys.argv[3]
dst_idx = int(sys.argv[4], 0)
src_off = src_idx*(8*2)
dst_off = dst_idx*(8*2)

src_pattern = open(src, 'rb').read()[src_off:src_off+8*2]
dst_chr = open(dst, 'rb').read()
open('copied.chr', 'wb').write(dst_chr[0:dst_off] + bytearray(src_pattern) + dst_chr[dst_off+8*2:])
