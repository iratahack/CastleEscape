#!/bin/bash
set -u

tileDir=tiles

mkdir -p ${tileDir}

# width in tiles. zero offset
width=11
# height in tiles. zero offset
height=13
tile=0
tileSheet="sprites.png"
tileSet=${tileDir}/tiles.c

echo "/* Autogenerated tileset */" > $tileSet

for y in $(seq 0 $height)
do
	for x in $(seq 0 $width)
	do
		let tx=$x*8
		let ty=$y*8
		echo "$tx,$ty tile${tile}.png -> tile${tile}.h"
		convert ${tileSheet} -crop 8x8+$tx+$ty ${tileDir}/tile${tile}.png
#		convert ${tileDir}/tile${tile}.png -threshold 50% -negate ${tileDir}/tile${tile}.h
		convert ${tileDir}/tile${tile}.png -threshold 1% ${tileDir}/tile${tile}.h
		sed -i s/MagickImage/tile${tile}/ ${tileDir}/tile${tile}.h
		sed -i "s/0x50, 0x34, 0x0A, 0x38, 0x20, 0x38, 0x0A, //g" ${tileDir}/tile${tile}.h
		sed -i "s/static //" ${tileDir}/tile${tile}.h
		echo "#include \"tile${tile}.h\"" >> $tileSet
		let tile=$tile+1
	done
done

echo "Converting to assembly..."
zcc +zx -S ${tileSet} -o ${tileDir}/tiles.inc

echo "Formatting..."
# Remove comments
sed -i -e "/^\s*;/d" ${tileDir}/tiles.inc
# Remove blank lines
sed -i -e "/^$/d" ${tileDir}/tiles.inc
# Remove lines containing unneeded directives
sed -i -e "/^\s*[C_LINE|SECTION|MODULE|INCLUDE|GLOBAL]/d" ${tileDir}/tiles.inc
# Remove underscores
#sed -i -e "s/._/./" ${tileDir}/tiles.inc

asmstyle.pl ${tileDir}/tiles.inc

cp -i ${tileDir}/tiles.inc ../src
echo "Done"
