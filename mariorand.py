import sys

def _ror(val, carry):
	next_carry	= bool(val & 1)
	val			= (val >> 1)
	if carry:
		val |= 0x80
	return val, next_carry

def random_init():
	return [ 0xA5 ] + ([ 0 ] * 6)

def random_advance(seed):
	carry = bool((seed[0] & 0x02) ^ (seed[1] & 0x02))

	for i in range(0, len(seed)):
		seed[i], carry = _ror(seed[i], carry)

	return seed

def is_seed(s, needle):
	for i in range(0, len(s)):
		if s[i] != needle[i]:
			return False
	return True

find = [ ]
seed = random_init()
total = 0

#while True:
for i in range(0, 100000):
	seed = random_advance(seed)

	# xxx = [ 0x8C, 0xDD, 0xC4, 0x7F, 0xF7, 0x08, 0xE6 ]
	# xxx = [ 0xEA, 0x91, 0x44, 0x66, 0xEE, 0x23, 0xFF ]
	# xxx = [0x6F, 0x5D, 0x83, 0x38, 0x3E, 0x4E, 0x32]
	# xxx = [0x1E, 0x2A, 0x16, 0x42, 0x6E, 0xEA, 0x37]
	# xxx = [0xF3, 0x24, 0xC2, 0x8B, 0x0E, 0x18, 0x04 ]
	xxx = [ 0x60, 0x10, 0xD0, 0xF1, 0x50, 0xB2, 0x13 ]
	if is_seed(seed, xxx):
		rule = int(i / 21)
		off = int(i % 21)
		print('%d: %d, %d' % (i, rule, off))
		sys.exit(1)

	#if seed in find:
	#	print('[%d] Found block!' % (i))
	#	print('#' * 60)
	total += 1
