nt = open('settings.nam', 'rb').read()
row = []
for i in range(0, len(nt)):
	if 0 == (i & 0xff):
		print('\nsettings_nt_data_%d:\n\t.byte ' % (i / 0x100), end='')
	elif i and 0 == (i & 0xf):
		print('\n\t.byte ', end='')
	row.append('$%02X' % (nt[i]))
	if 16 == len(row):
		print(', '.join(row), end='')
		row = []
