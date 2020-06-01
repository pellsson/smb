from PIL import Image
import sys
i = Image.open(sys.argv[1])

def create_tile(pixels, sx, sy, cm):
	data = [ 0 ] * 16
	y = sy
	while y < (sy + 8):
		x = sx
		while x < (sx + 8):
			px = pixels[x, y]
			if px > 3:
				raise 'too many colors'
			px = cm[px]
			lo = px & 1
			hi = (px & 2) >> 1
			data[(y - sy) + 0] |= lo << (7 - (x - sx))
			data[(y - sy) + 8] |= hi << (7 - (x - sx))
			x += 1
		y += 1
	return data

pixels = i.load() # this is not a list, nor is it list()'able
width, height = i.size

if 0 != (width % 8) or 0 != (height % 8):
	raise 'fucked dimensions %d, %d' % (width, height)

# colormap = [ 3, 0, 2, 1 ] # Somewes
# colormap = [ 3, 0, 2, 1 ] # Roylt
# colormap = [ 3, 0, 1, 2 ] # Kosmic?
# colormap = [ 3, 0, 2, 1 ] # Taven
# colormap = [ 3, 2, 1, 0 ] # taven
colormap = [ 0, 1, 2, 3 ] # Leontoast

tiles = []
ty = 0
while ty < (height / 8):
	tx = 0
	while tx < (width / 8):
		tiles.append(create_tile(pixels, tx * 8, ty * 8, colormap))
		tx += 1
	ty += 1

fp = open(sys.argv[2], 'wb')
for it in tiles:
	fp.write(bytearray(it))
