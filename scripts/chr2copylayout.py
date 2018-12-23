import sys

def copy_chunks(v):
    for i in range(0, len(v), 0x100):
        yield v[i:i + 0x100]

ch = open(sys.argv[1], 'rb').read()
if 0 != (len(ch) & 0xFFF):
	raise 'bad size'

c = list(copy_chunks(ch))
out = []
for i in range(0, len(c)):
	out.append([])
idx = 0
for it in c:
	for i in range(0, len(it)):
		out[idx].append(it[i])
		idx += 1
		if idx >= len(out):
			idx = 0

flat = []
for it in out:
	flat += it

open(sys.argv[2], 'wb').write(bytearray(flat))