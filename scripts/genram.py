import re
import sys

s = ''';
; ramvars.inc is auto-generated from ram_region.asm
; don't alter directly. bad idea. very bad idea.
;
'''

for it in open(sys.argv[1], 'rb').readlines():
	it = it.decode('utf-8').strip()
	if 0 == len(it):
		continue
	m = re.match(r'([0-9A-F]{6})\s+\d\s+(\w+):', it)
	if not m:
		continue
	s += '%s = $%04X\n' % (m.group(2), int(m.group(1), 16))

v = open(sys.argv[2], 'w')
v.write(s)