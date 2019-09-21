import sys

def compare(s, d):
	for i in range(0, len(s)):
		if s[i] != d[i]:
			return False
	return True

a = open(sys.argv[1], 'rb').read()

dups = []
count = int(len(a) / (8*2))
print('Searching %d patterns...' % (count))

for x in range(0, count):
	src = a[x*(8*2):(x+1)*(8*2)]
	for y in range(x + 1, count):
		dst = a[y*(8*2):(y+1)*(8*2)]
		if compare(src, dst):
			dups.append({ 'src': x, 'dst': y })

print('Duplicates:')
for it in dups:
	print('Pattern: 0x%02X (%d) == 0x%02X (%d)' % (it['src'], it['src'], it['dst'], it['dst']))


