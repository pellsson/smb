import sys
import json
from itertools import islice

area_vars = [
	"ScreenEdge_PageLoc",
	"Player_PageLoc",
	"WorldNumber",
	"AreaNumber",
	"LevelNumber",
]

def chunks(l, n):
	for i in range(0, len(l), n):
		yield l[i:i + n]

def make_load_area_function(j):
	global area_vars
	print('%s_load_area:' % (j['name']))
	for it in area_vars:
		print('\t\tlda #$%02X' % (j['memory'][it]))
		print('\t\tsta %s' % (it))
	print('\t\tlda #$%02X' % (j['memory']['ScreenRight_X_Pos']))
	print('\t\tsta FpgScrollTo')
	print('\t\trts')

def make_reset_attempt_function(j):
	global area_vars
	arrays = {}
	fixed = []
	movs = ''
	for k, v in j['memory'].items():
		if k in area_vars:
			continue
		if isinstance(v, list):
			if len(v) not in arrays:
				arrays[len(v)] = []
			arrays[len(v)].append({ 'name': k, 'data': v })
			fixed.append(k)
		else:
			movs += '\t\tlda #$%02X\n' % (v)
			movs += '\t\tsta %s\n' % (k)

	for arr_len, arrs in arrays.items():
		for a in arrs:
			print('%s_%s:' % (j['name'], a['name']))
			print('\t.byte %s' % (', '.join([ '$%02X' % (it) for it in a['data'] ])))

	print('')
	print('%s_reset:' % (j['name']))
	print('\t\tlda $2') # low addr
	print('\t\tclc') 
	print('\t\tadc #$%02X' % (j['enemy_ptr_offset'] & 0xff))
	print('\t\tsta EnemyDataLow')
	print('\t\tlda $3')
	print('\t\tadc #$%02X' % (j['enemy_ptr_offset'] >> 8))
	print('\t\tsta EnemyDataHigh')

	for arr_len, arrs in arrays.items():
		chunk_id = 0
		for x in chunks(arrs, 20):
			print('\t\tldx #$%02X' % (arr_len - 1))
			loop_target = '%s_init_len%d_%d' % (j['name'], arr_len, chunk_id)
			print('%s:' % (loop_target))
			for it in x:
				print('\t\tlda %s_%s, x' % (j['name'], it['name']))
				print('\t\tsta %s, x' % (it['name']))
			print('\t\tdex')
			print('\t\tbpl %s' % (loop_target))
			chunk_id += 1

	for k, v in j['memory'].items():
		if k in fixed or k in area_vars:
			continue
		print('\t\tlda #$%02X' % (v))
		print('\t\tsta %s' % (k))
	print('\t\trts')

def get_input(s):
	k = 0
	b = { 'a': 0x80, 'b': 0x40, 'l': 0x02, 'r': 0x01 }
	for it in s.lower():
		k |= b[it]
	return k

def get_text(s):
	b = []
	for it in s.lower()[0:8]:
		n = ord(it)
		if ' ' == it:
			b.append(0x24)
		elif '-' == it:
			b.append(0x28)
		elif '!' == it:
			b.append(0x2b)
		elif n >= ord('0') and n <= ord('9'):
			b.append(n - ord('0'))
		else:
			b.append(0x0a + n - ord('a'))
	b = b + [ 0x24 ] * (8 - len(b))
	return ', '.join([ '$%02X' % (it) for it in b ])

def compare_rules(a, b):
    ka = set(a).difference([ 'frame', 'comment' ])
    kb = set(b).difference([ 'frame', 'comment' ])
    return ka == kb and all(a[k] == b[k] for k in ka)

def make_rules(name, rules):
	ind = '\t\t'

	for i in range(0, len(rules)):
		print('%s_ruleset%d:' % (name, i))
		print(ind + 'ldy FrameCounter')
		print(ind + 'lda SavedJoypadBits')
		print(ind + 'and #$C3') #only care for L,R,A,B
		j = 0
		while j < len(rules[i]):
			rule = rules[i][j]
			merge = j + 1
			while merge < len(rules[i]):
				if not compare_rules(rules[i][j], rules[i][merge]):
					break
				merge += 1

			print('%s_ruleset%d_rule%d:' % (name, i, j))
			print(ind + 'cpy #$%02X' % (rule['frame']))
			next_rule_name = ''

			if (j + 1) == merge:
				next_rule_name = '%s_ruleset%d_rule%d' % (name, i, j + 1)
				# nothing to merge
				print(ind + 'bne %s' % (next_rule_name))
			else:
				j = merge - 1
				rule = rules[i][j]
				next_rule_name = '%s_ruleset%d_rule%d' % (name, i, j + 1)
				print(ind + 'bmi %s' % (next_rule_name))
				print(ind + 'cpy #$%02X' % (rule['frame'] + 1))
				print(ind + 'bpl %s' % (next_rule_name))

			if 'lock' == rule['method']:
				print(ind + 'pha')
				print(ind + 'lda FpgFlags')
				print(ind + 'ora #$20')
				print(ind + 'sta FpgFlags')
				print(ind + 'pla')
			elif 'input' == rule['method']:
				print(ind + 'cmp #$%02X' % (get_input(rule['input'])))
				print(ind + 'beq %s_ruleset%d_rule%d' % (name, i, j + 1))
				print(ind + 'lda #$%02X' % (get_input(rule['input'])))
				print(ind + 'jmp fpg_failed_input')
			elif 'input_opt' == rule['method']:
				print(ind + 'and #$%02X' % (get_input(rule['opt']) ^ 0xff))
				print(ind + 'cmp #$%02X' % (get_input(rule['input'])))
				print(ind + 'beq %s_ruleset%d_rule%d_restore_input' % (name, i, j + 1))
				print(ind + 'lda #$%02X' % (get_input(rule['input'])))
				print(ind + 'jmp fpg_failed_input')
				print('%s_ruleset%d_rule%d_restore_input:' % (name, i, j + 1))
				print(ind + 'lda SavedJoypadBits')
			elif 'pixel' == rule['method']:
				print(ind + 'ldx Player_X_Position')
				print(ind + 'cpx #$%02X' % (rule['x']))
				print(ind + 'beq %s_ruleset%d_rule%d_y' % (name, i, j))
				print(ind + 'jmp fpg_failed_pos_x')
				print('%s_ruleset%d_rule%d_y:' % (name, i, j))
				print(ind + 'ldx Player_Y_Position')
				print(ind + 'cpx #$%02X' % (rule['y']))
				print(ind + 'beq %s_ruleset%d_rule%d' % (name, i, j + 1))
				print(ind + 'jmp fpg_failed_pos_y')
			elif 'win' == rule['method']:
				print(ind + 'jmp fpg_win')
			elif 'x_ge' == rule['method']:
				print(ind + 'ldx Player_X_Position')
				print(ind + 'cpx #$%02X' % (rule['x']))
				print(ind + 'bpl %s_ruleset%d_rule%d' % (name, i, j + 1))
				print(ind + 'jmp fpg_failed_pos_x')
			elif 'x' == rule['method']:
				print(ind + 'ldx Player_X_Position')
				print(ind + 'cpx #$%02X' % (rule['x']))
				print(ind + 'beq %s_ruleset%d_rule%d' % (name, i, j + 1))
				print(ind + 'jmp fpg_failed_pos_x')
			elif 'y' == rule['method']:
				print(ind + 'ldx Player_Y_Position')
				print(ind + 'cpx #$%02X' % (rule['y']))
				print(ind + 'beq %s_ruleset%d_rule%d' % (name, i, j + 1))
				print(ind + 'jmp fpg_failed_pos_y')
			else:
				raise 'Dont understand method'
			j += 1
		print('%s_ruleset%d_rule%d:' % (name, i, len(rules[i])))
		print(ind + 'rts')
	print('%s_rulesets:' % (name))
	for i in range(0, len(rules)):
		print('\t.word %s_ruleset%d' % (name, i))
	print('''%s_validate:
		lda FpgRuleset
		asl
		tay
		lda %s_rulesets, y
		sta $0
		lda %s_rulesets+1, y
		sta $1
		jmp ($0)
	''' % (name, name, name))


print('''
	.include "org.inc"
	.include "mario.inc"
	.include "shared.inc"
	.include "macros.inc"
	.segment "bank6"
	.org $8000
''')

scenarios = []
for i in range(1, len(sys.argv)):
	j = json.loads(open(sys.argv[i], 'r').read())

	j['pretty_name'] = j['name']
	j['name'] = 'scen_' + j['name'].replace(' ', '_').replace('-', '_')

	make_load_area_function(j)
	make_reset_attempt_function(j)
	make_rules(j['name'], j['rules'])

	scenarios.append(j)

print('fpg_num_configs: .byte $%02X' % (len(scenarios)))

for i in range(0, len(scenarios)):
	name = scenarios[i]['name']
	pretty_name = scenarios[i]['pretty_name']
	if (0 == i): print('fpg_configs:')
	print('\t\t.byte %s ; %s' % (get_text(pretty_name), pretty_name))
	if (0 == i): print('fpg_load_area_func:')
	print('\t\t.word %s_load_area' % (name))
	if (0 == i): print('fpg_reset_func:')
	print('\t\t.word %s_reset' % (name))
	if (0 == i): print('fpg_validate_func:')
	print('\t\t.word %s_validate' % (name))
	if (0 == i): print('fpg_num_routes:')
	print('\t\t.byte $%02X' % (len(scenarios[i]['rules']))) # align to 0x10
	print('\t\t.byte 0') # align to 0x10


print('.include "scen_exports.asm"')


