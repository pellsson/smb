import sys
import re

def fix_argument(a, comment):
	c = comment.split()
	if len(c) >= 2:
		if 'RENAME' == c[0] or 'RELOC' == c[0]:
			return ' '.join(c[1:])
	return a

def fix_instruction(inst, comment):
	inst = inst.strip()

	if 0 == len(inst):
		return ''
	if 'REMOVE' == comment:
		return '\t\t; ' + inst

	tokens = [ it.strip() for it in inst.split(None, 1) ]
	if '.BYTE' == tokens[0]:
		return '\t\t' + '.byte ' + fix_argument(tokens[1], comment)
	elif '.WORD' == tokens[0]:
		m = re.match(r'\$[0-9a-fA-F]{4}.*', fix_argument(tokens[1], comment))
		if m:
			if '$ffff' != tokens[1].lower():
				print(tokens[1].lower())
				raise 'nope'
		s = ''
		if 'NonMaskableInterrupt' == tokens[1]:
			s = '\t.seekoff $FFFA $EA\n'
		return s + '\t\t' + '.word ' + tokens[1]

	if len(tokens) > 2:
		print(inst)
		raise 'dont understand'	
	mnem = tokens[0].lower()
	s = '\t\t' + mnem
	if mnem in [ 'lsr', 'asl', 'rol', 'ror' ]:
		if 'a' == tokens[1].lower():
			tokens.pop()
	if 2 == len(tokens):
		tokens[1] = fix_argument(tokens[1], comment)
		m = re.match(r'\$[0-9a-fA-F]{4}.*', tokens[1])
		if m:
			print(tokens[1])
			#raise 'nopexx'
		if tokens[1][-2:] == ',X' or tokens[1][-2:] == ',Y':
			tokens[1] = tokens[1][0:-2] + tokens[1][-2:].lower()
		s += ' ' + tokens[1]
	return s

lines = open(sys.argv[1], 'rb').readlines()
fixed = []
beg = 0

for beg in range(0, len(lines)):
	line = lines[beg]
	if re.match(r'\s*\* =\s*\$8000.*', line.decode('utf-8', errors = 'ignore')):
		break
if beg == len(lines):
	print('Nah')
	sys.exit(-1)

fixed.append('\t.org $8000')
fixed.append('\t.vars vars.inc')
fixed.append('\tFDS_Delay132:') # kill ones it builds.
fixed.append('\tFDS_LoadFiles:') # kill ones it builds.
for i in range(beg + 1, len(lines)):
	line = lines[i].decode('utf-8', errors = 'ignore')
	parts = [ it.strip() for it in line.split(';', 1) ]
	line = parts[0]
	comment = '' if len(parts) < 2 else parts[1]
	for j in range(i + 1, len(lines)):
		next_line = lines[j].decode('utf-8', errors = 'ignore').strip()

		if len(next_line) and '; End' == next_line[0:5]:
			break
		if len(next_line) and ';' == next_line[0]:
			comment = next_line[1:].strip()
		else:
			break
	if 0 == len(line):
		continue
	if '*' == line[0]:
		break
	label = line.split(':', 1)
	code = ''
	if 2 == len(label):
		fixed.append(label[0].strip() + ':')
		code = fix_instruction(label[1], comment)
	else:
		code = fix_instruction(line, comment)
	if len(code):
		fixed.append(code)

for it in fixed:
	print(it)
