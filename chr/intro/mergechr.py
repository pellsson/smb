import sys

rom = []

for it in sys.argv[2:]:
	rom += open(it, 'rb').read()
	if 0 != len(rom) & 1:
		raise 'Unaligned CHR %s' % (it)

if len(rom):
	if 0 != (len(rom) % 0x1000):
		rom = rom + ([ 0xff ] * (0x1000 - len(rom) % 0x1000))
	open(sys.argv[1], 'wb').write(bytearray(rom))