CC=zcc
AS=asmpp.pl
LD=zcc
TARGET=zx
CRT=31

PROJ_NAME=CastleEscape
PRAGMA_FILE=zpragma.inc

C_OPT_FLAGS=-SO2

CFLAGS=+$(TARGET) $(C_OPT_FLAGS) --constsegrodata_user -compiler=sdcc -I$(Z88DK)/include/_DEVELOPMENT/sdcc --legacy-banking -c -pragma-include:$(PRAGMA_FILE)
LDFLAGS=+$(TARGET) --constsegrodata_user -m -clib=sdcc_iy -pragma-include:$(PRAGMA_FILE) -Cz--clearaddr -Cz32767
ASFLAGS=-I$(Z88DK)/lib

OBJECTS =  $(patsubst %.c,%.o,$(wildcard *.c)) $(patsubst %.asm,%.o,$(wildcard *.asm)) tiles/tiles.o sprite/LeftSprite.o sprite/RightSprite.o

all: $(PROJ_NAME).tap
	@grep __code_user_size $(PROJ_NAME).map | sed -e "s/;.*//"
	@grep __data_user_size $(PROJ_NAME).map | sed -e "s/;.*//"
	@grep __rodata_user_size $(PROJ_NAME).map | sed -e "s/;.*//"
	@grep __bss_user_size $(PROJ_NAME).map | sed -e "s/;.*//"
	@grep __BANK_0_size $(PROJ_NAME).map | sed -e "s/;.*//"
	@grep __BSS_UNINITIALIZED_tail $(PROJ_NAME).map | sed -e "s/;.*//"

%.o: %.c $(PRAGMA_FILE) Makefile
	$(CC) $(CFLAGS) -o $@ $<

%.o: %.asm $(PRAGMA_FILE) Makefile
	$(AS) $(ASFLAGS) $<
	
$(PROJ_NAME).tap : $(OBJECTS) $(PRAGMA_FILE) Makefile
	 $(LD) $(LDFLAGS) -startup=$(CRT) $(OBJECTS) -o $(PROJ_NAME).bin -create-app
	 @rm -f *.i
	
.PHONY: clean run dis

clean:
	rm -f $(OBJECTS) *.tap *.bin *.map *.lis *.sym *.i

run: all
	fuse.exe $(PROJ_NAME).tap

dis: all
	z88dk-dis -o 0x8184 -x $(PROJ_NAME).map $(PROJ_NAME)_CODE.bin | less
