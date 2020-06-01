import sys
import struct
import json

def fds_manufacturer(fds):
	return {
		0x00: { 'en': '<unlicensed>', 'jp': '<非公認>' },
		0x01: { 'en': 'Nintendo', 'jp': '任天堂' },
		0x08: { 'en': 'Capcom', 'jp': 'カプコン' },
		0x0A: { 'en': 'Jaleco', 'jp': 'ジャレコ' },
		0x18: { 'en': 'Hudson Soft', 'jp': 'ハドソン' },
		0x49: { 'en': 'Irem', 'jp': 'アイレム' },
		0x4A: { 'en': 'Gakken', 'jp': '学習研究社' },
		0x8B: { 'en': 'BulletProof Software (BPS)', 'jp': 'BPS' },
		0x99: { 'en': 'Pack-In-Video', 'jp': 'パックインビデオ' },
		0x9B: { 'en': 'Tecmo', 'jp': 'テクモ' },
		0x9C: { 'en': 'Imagineer', 'jp': 'イマジニア' },
		0xA2: { 'en': 'Scorpion Soft', 'jp': 'スコーピオンソフト' },
		0xA4: { 'en': 'Konami', 'jp': 'コナミ' },
		0xA6: { 'en': 'Kawada Co., Ltd.', 'jp': '河田' },
		0xA7: { 'en': 'Takara', 'jp': 'タカラ' },
		0xA8: { 'en': 'Royal Industries', 'jp': 'ロイヤル工業' },
		0xAC: { 'en': 'Toei Animation', 'jp': '東映動画' },
		0xAF: { 'en': 'Namco', 'jp': 'ナムコ' },
		0xB1: { 'en': 'ASCII Corporation', 'jp': 'アスキー' },
		0xB2: { 'en': 'Bandai', 'jp': 'バンダイ' },
		0xB3: { 'en': 'Soft Pro Inc.', 'jp': 'ソフトプロ' },
		0xB6: { 'en': 'HAL Laboratory', 'jp': 'HAL研究所' },
		0xBB: { 'en': 'Sunsoft', 'jp': 'サンソフト' },
		0xBC: { 'en': 'Toshiba EMI', 'jp': '東芝EMI' },
		0xC0: { 'en': 'Taito', 'jp': 'タイトー' },
		0xC1: { 'en': 'Sunsoft / Ask Co., Ltd.', 'jp': 'サンソフト アスク講談社' },
		0xC2: { 'en': 'Kemco', 'jp': 'ケムコ' },
		0xC3: { 'en': 'Square', 'jp': 'スクウェア' },
		0xC4: { 'en': 'Tokuma Shoten', 'jp': '徳間書店' },
		0xC5: { 'en': 'Data East', 'jp': 'データイースト' },
		0xC6: { 'en': 'Tonkin House/Tokyo Shoseki', 'jp': 'トンキンハウス' },
		0xC7: { 'en': 'East Cube', 'jp': 'イーストキューブ' },
		0xCA: { 'en': 'Konami / Ultra / Palcom', 'jp': 'コナミ' },
		0xCB: { 'en': 'NTVIC / VAP', 'jp': 'バップ' },
		0xCC: { 'en': 'Use Co., Ltd.', 'jp': 'ユース' },
		0xCE: { 'en': 'Pony Canyon / FCI', 'jp': 'ポニーキャニオン' },
		0xD1: { 'en': 'Sofel', 'jp': 'ソフエル' },
		0xD2: { 'en': 'Bothtec, Inc.', 'jp': 'ボーステック' },
		0xDB: { 'en': 'Hiro Co., Ltd.', 'jp': 'ヒロ' },
		0xE7: { 'en': 'Athena', 'jp': 'アテナ' },
		0xEB: { 'en': 'Atlus', 'jp': 'アトラス' }
	}[fds_u8(fds)]

def fds_str(fds, n):
	try:
		return fds.read(n).decode('utf-8')
	except:
		return '?'*8

def fds_u8(fds):
	return struct.unpack('B', fds.read(1))[0]

def fds_u16(fds):
	return struct.unpack('<H', fds.read(2))[0]

def fds_chr(fds):
	return fds.read(1).decode('utf-8')

def _from_bcd(n):
	return ((((n & 0xF0) >> 4) * 10) + (n & 0x0F))

def fds_date(fds):
	y = _from_bcd(fds_u8(fds))
	m = _from_bcd(fds_u8(fds))
	d = _from_bcd(fds_u8(fds))
	return '%d-%d-%d' % (y + 1925, m, d)

def fds_array(fds, n):
	return int.from_bytes(fds.read(n), byteorder='little', signed=False)

def fds_block_info(fds):
	if 0x01 != fds_u8(fds):
		raise 'expected block info type'
	if '*NINTENDO-HVC*' != fds_str(fds, 0x0E):
		raise 'expected block info magic'
	return {
		'manufacturer': fds_manufacturer(fds),
		'game_name': fds_str(fds, 3),
		'game_type': fds_chr(fds),
		'game_version': fds_u8(fds),
		'side_number': fds_u8(fds),
		'disk_number': fds_u8(fds),
		'disk_type': [ 'normal', 'shutter' ][fds_u8(fds)],
		'unknown0': fds_u8(fds),
		'boot_file': fds_u8(fds),
		'unknown1': fds_array(fds, 5),
		'manufature_date': fds_date(fds),
		'country_code': fds_u8(fds),
		'unknown2': fds_u8(fds),
		'unknown3': fds_u8(fds),
		'unknown4': fds_u16(fds),
		'unknown5': fds_array(fds, 5),
		'rewrite_date': fds_date(fds),
		'unknown6': fds_u8(fds),
		'unknown7': fds_u8(fds),
		'serial_nr': fds_u16(fds),
		'unknown8': fds_u8(fds),
		'rewrites': fds_u8(fds),
		'disk_side': fds_u8(fds),
		'unknown': fds_u8(fds),
		'price': fds_u8(fds)
	}

def fds_file_table(fds, bi):
	if 2 != fds_u8(fds):
		raise 'expected file amount block'
	num_files = fds_u8(fds)
	files = []
	for i in range(0, num_files):
		if 3 != fds_u8(fds):
			raise 'expected file info block'
		f = {
			'file_nr': fds_u8(fds),
			'file_id': fds_u8(fds),
			'filename': fds_str(fds, 8),
			'ram_addr': fds_u16(fds),
			'size': fds_u16(fds),
			'type': [ 'PRG', 'CHR', 'NT' ][fds_u8(fds)],
		}
		if 4 != fds_u8(fds):
			raise 'expected file data block'
		f['data'] = fds.read(f['size'])
		files.append(f)
	return files

fds = open(sys.argv[1], 'rb')

block_info = fds_block_info(fds)
file_table = fds_file_table(fds, block_info)

bank_id = 0

for it in file_table:
	name = 'bank%d-%s.%s' % (bank_id, it['filename'], it['type'])
	print('File %s (Bank %d): RAM %04X, size: %04X' % (name, bank_id, it['ram_addr'], it['size']))
	bank_id += 1
	open(name, 'wb').write(it['data'])
	it.pop('data')

open('%s.json' % (block_info['game_name']), 'w').write(json.dumps({
	'info': block_info,
	'files': file_table
}, indent = 4))
