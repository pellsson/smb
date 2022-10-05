import re

def nesst_datablock(key, s):
	data = re.search(key + r'=([^\n]+)', s)
	if data is None:
		raise 'Woot'
	odd = 0
	data = data.group(1).split('[')
	ret = bytearray.fromhex(data[0])
	for x in data[1:]:
		n,v = x.split(']')
		n = int(n, 16)
		v = bytearray.fromhex(v)
		ret += bytearray([ret[-1]] * (n - 1))
		ret += v
		odd ^= 1
	return ret

def nt_from_nss(f):
	s = open(f, 'r').read()
	return nesst_datablock('NameTable', s) + nesst_datablock('AttrTable', s)

def convert():
	nts = [ 'intro', 'settings' ]
	for name in nts:
		nt = nt_from_nss('%s.nss' % (name))
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
convert()