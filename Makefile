AS = nasm
LD = ld
TARGET = c4
FORMAT = elf

SOURCE1 = c4.asm
SOURCE2 = check_win.asm
OBJ1 = c4.o
OBJ2 = cw.o

$(TARGET): $(OBJ1) $(OBJ2)
	$(LD) $(OBJ2) $(OBJ1) -I/lib/ld-linux.so.2 -lc -o $(TARGET)

$(OBJ1): $(SOURCE1)
	$(AS) $(SOURCE1) -g  -f $(FORMAT) -o $(OBJ1)

$(OBJ2): $(SOURCE2)
	$(AS) $(SOURCE2) -g -f $(FORMAT) -o $(OBJ2)
clean:
	rm *.o

