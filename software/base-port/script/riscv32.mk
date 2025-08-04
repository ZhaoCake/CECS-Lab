CROSS_COMPILE := /home/zhaocake/WorkSpaces/RiscV/CECS-Lab/../riscv64-multilib/bin/riscv32-unknown-elf-
COMMON_FLAGS  := -march=rv32im_zicsr_zifencei -mabi=ilp32 -fno-pic 
CFLAGS        += $(COMMON_FLAGS) -static -fdata-sections -ffunction-sections
AFLAGS        += $(COMMON_FLAGS) 
LDFLAGS       += -melf32lriscv --no-warn-rwx-segments -static --gc-sections -e _start