nts = [ 'nt', 'settings_nt' ]

for name in nts:
	nt = open('%s.nam' % (name), 'rb').read()
	row = []
	for i in range(0, len(nt)):
		if 0 == (i & 0xff):
			print('\n%s_data_%d:\n\t.byte ' % (name, i / 0x100), end='')
		elif i and 0 == (i & 0xf):
			print('\n\t.byte ', end='')
		row.append('$%02X' % (nt[i]))
		if 16 == len(row):
			print(', '.join(row), end='')
			row = []
