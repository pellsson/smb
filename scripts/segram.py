import sys
import re

first = sys.argv[3]
last = sys.argv[4]

lbl =  { first: 0, last: 0 }

for it in open(sys.argv[1], 'rb').readlines():
	it = it.decode('utf-8').strip()
	if 0 == len(it):
		continue
	m = re.match(r'([0-9A-F]{6})\s+\d\s+(\w+):', it)
	if not m:
		continue
	if(m.group(2) in lbl):
		lbl[m.group(2)] = int(m.group(1), 16)

if 0 == lbl[first] or 0 == lbl[last]:
	print('Unable to find labels')
	sys.exit(-1)

off_lo = lbl[first] - 0x6000
off_hi = lbl[last] - 0x6000

if off_lo > off_hi:
	off_lo, off_hi = off_hi, off_lo

b = open(sys.argv[2], 'rb').read()

if off_hi > len(b):
	print('broken input file')
	sys.exit(-1)

open(sys.argv[5], 'wb').write(b[off_lo:off_hi])
