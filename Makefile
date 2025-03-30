PROJECT=foo
CPU ?= cortex-m3
BOARD ?= stm32vldiscovery

qemu:
	arm-none-eabi-as -mthumb -mcpu=$(CPU) -ggdb -c foo.S -o foo.o
	arm-none-eabi-ld -Tmap.ld foo.o -o foo.elf
	arm-none-eabi-objdump -D -S foo.elf > foo.elf.lst
	arm-none-eabi-readelf -a foo.elf > foo.elf.debug
	arm-none-eabi-objcopy -O binary foo.elf foo.bin
	xxd -e -c4 -g 4 foo.bin
	qemu-system-arm -S -M $(BOARD) -cpu $(CPU) -nographic -kernel $(PROJECT).elf -gdb tcp::1234

gdb:
	gdb-multiarch -q $(PROJECT).elf -ex "target remote localhost:1234"

clean:
	rm -rf *.out *.elf .gdb_history *.lst *.debug *.o *.bin