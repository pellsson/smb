import re
import sys

block_off = 0
voff = 0
bsize = 0

for it in open(sys.argv[1], 'r').readlines():
	it = it.strip().lower()
	m = re.match(r'.*\.byte\s+(\$?)([a-f0-9][a-f0-9]?)', it)
	if not m:
		raise 'que?'
	v = int(m.group(2), 16) if '$' == m.group(1) else int(m.group(2))

	if 0 == block_off:
		if 0 == v:
			print('Terminator 0')
		else:
			voff = v << 8
			s = ""
	elif 1 == block_off:
		voff = voff | v
	elif 2 == block_off:
		bsize = v
	else:
		if v >= 0 and v <= 9:
			s += chr(ord('0') + v)
		elif v >= 0x0A and v <= 34:
			s += chr(ord('A') + (v - 0xA))
		elif v == 0x24:
			s += ' '
		else:
			s += "\\x%02X" % (v)

		if (block_off - 2) == bsize:
			print('Block at %08X (%d bytes): %s' % (voff, bsize, s))
			block_off = -1
		# print("%d vs %d" % (block_off, bsize))
	block_off += 1

print(s)