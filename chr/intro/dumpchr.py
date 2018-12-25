import sys
v = bytearray(open(sys.argv[1], 'rb').read())
c = []
for it in sys.argv[3:]:
	flip = False
	if '!' == it[0]:
		flip = True
		it = it[1:]
	off = int(it, 16) * 16
	pattern = v[off:off + 16]
	if flip:
		for i in range(0, len(pattern)):
			pattern[i] = int('{:08b}'.format(pattern[i])[::-1], 2)
	c += pattern
if len(c):
	open(sys.argv[2], 'wb').write(bytearray(c))
