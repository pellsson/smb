import sys
import binascii
import re

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

find = [ ]

def generate_quick_resume(framerule_frames):
	seed = random_init()
	for base_i in range(0, 5):
		base = base_i * 32
		print("quick_resume_" + str(base) + ":")
		for i in range(0, 32):
			rngbase = (base + i)  * 100
			print('	.byte ' + ', '.join('${:02x}'.format(x) for x in seed) + ', $00 ; Base for ' + str(rngbase))
			if rngbase >= 9900:
				return
			for u in range(0, (100 * framerule_frames)):
				seed = random_advance(seed)

def generate_quick_resume_both():
	print(".macro QUICKRESUME")
	print(".ifdef PAL")
	generate_quick_resume(18)
	print(".else")
	generate_quick_resume(21)
	print(".endif")
	print(".endmacro")

def locate_seed_frame(framerule_frames, needle):
	needle_ary = list(map(int, bytearray.fromhex(re.sub("[^0-9a-fA-F]", "", needle))))
	seed = random_init()
	for i in range(0, 100000):
		seed = random_advance(seed)
		if seed != needle_ary:
			continue
		rule = int(i / framerule_frames)
		off = int(i % framerule_frames)
		print('found on frame: %d, framerule: %d, framerule offset: %d' % (i, rule, off))

generate_quick_resume_both()
#locate_seed_frame(21, "E9E635F9926145")
