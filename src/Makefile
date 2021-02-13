CC=zcc
AS=asmpp.pl
LD=zcc
TARGET=zx
CRT=31
RODATA=rodata_user
PROJ_NAME=CastleEscape
PRAGMA_FILE=zpragma.inc
ASMDEPS=	\
			$(wildcard *.inc) \
			$(wildcard *.scr) \
			$(wildcard *.afb) \
			$(wildcard *.dat) \
			$(wildcard music/*.mus) \
			$(wildcard music/*.inc)

C_OPT_FLAGS=-SO3

CFLAGS=+$(TARGET) $(C_OPT_FLAGS) --codesegcode_user --constseg$(RODATA) -compiler=sdcc -I$(Z88DK)/include/_DEVELOPMENT/sdcc -c -pragma-include:$(PRAGMA_FILE)
LDFLAGS=+$(TARGET) --codesegcode_user --constseg$(RODATA) -m -clib=sdcc_iy -pragma-include:$(PRAGMA_FILE) -Cz--clearaddr=32767 -Cz--screen=title.scr
ASFLAGS=-I$(Z88DK)/lib

OBJECTS =	$(patsubst %.c,%.o,$(wildcard *.c)) \
			$(patsubst %.asm,%.o,$(wildcard *.asm)) \
			sprite/LeftSprite.o \
			sprite/RightSprite.o

all: $(PROJ_NAME).tap
	@grep __code_user_size $(PROJ_NAME).map | sed -e "s/;.*//"
	@grep __data_user_size $(PROJ_NAME).map | sed -e "s/;.*//"
	@grep __rodata_user_size $(PROJ_NAME).map | sed -e "s/;.*//"
	@grep __bss_user_size $(PROJ_NAME).map | sed -e "s/;.*//"
	@grep __BANK_0_size $(PROJ_NAME).map | sed -e "s/;.*//"
	@grep __BANK_5_size $(PROJ_NAME).map | sed -e "s/;.*//"
	@grep __BANK_7_size $(PROJ_NAME).map | sed -e "s/;.*//"
	@grep __BSS_UNINITIALIZED_tail $(PROJ_NAME).map | sed -e "s/;.*//"

%.o: %.c $(PRAGMA_FILE) Makefile
	$(CC) $(CFLAGS) -o $@ $<

%.o: %.asm $(PRAGMA_FILE) Makefile $(ASMDEPS)
	$(AS) $(ASFLAGS) $<
	
$(PROJ_NAME).tap : $(OBJECTS) $(PRAGMA_FILE) Makefile
	 $(LD) $(LDFLAGS) -startup=$(CRT) $(OBJECTS) -o $(PROJ_NAME).bin -create-app
	 @rm -f *.i
	
.PHONY: clean run dis

clean:
	rm -f *.[oi] *.tap *.bin *.map *.lis *.sym sprite/*.o

run: all
	fuse.exe $(PROJ_NAME).tap

dis: all
	z88dk-dis -o 0x8184 -x $(PROJ_NAME).map $(PROJ_NAME)_CODE.bin | less
