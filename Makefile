####################################################################
# DEFINATIONS
####################################################################


PROJECT= main

# Cpu
MCU = cortex-m0

# Debug level
DBG = -g3

# Optimisation level
OPT = -O0

DEF = -DCORE_M0
####################################################################
# DEFAULT FILES & DIRECETORIES
####################################################################

SRC = ./driver/StdDriver/src ./src ./driver/Device/Nuvoton/NUC1311/Source

INC_DIR = ./driver/CMSIS/Include ./driver/Device/Nuvoton/NUC1311/Include \
		  ./driver/StdDriver/inc ./inc

SRC_FILES =  $(foreach dir,$(SRC),$(wildcard $(dir)/*.c))
ASM_FILES = ./driver/Device/Nuvoton/NUC1311/Source/GCC/startup_NUC1311.s

# Binary Folder
BUILD_DIR = ./build
# Object Folder
OBJ_DIR = $(BUILD_DIR)/obj

LINKER = ./driver/Device/Nuvoton/NUC1311/Source/GCC/gcc_arm.ld

# Header Files
INC = $(patsubst %, -I%, $(INC_DIR))


####################################################################
# TOOLS
####################################################################

PREFIX = arm-none-eabi-
CC = $(PREFIX)gcc
CXX = $(PREFIX)g++
GDB = $(PREFIX)gdb
CP = $(PREFIX)objcopy
AS = $(PREFIX)gcc -x assembler-with-cpp
HEX = $(CP) -O ihex
BIN = $(CP) -O binary -S


####################################################################
# FILES
####################################################################

OBJ_FILES = $(addprefix $(OBJ_DIR)/,$(notdir $(SRC_FILES:.c=.o)))
vpath %.c $(sort $(dir $(SRC_FILES)))

OBJ_FILES += $(addprefix $(OBJ_DIR)/,$(notdir $(ASM_FILES:.s=.o)))
vpath %.s $(sort $(dir $(ASM_FILES)))

####################################################################
# FLAGS
####################################################################


#DEF +=  -D__USE_LPCOPEN -DNO_BOARD_LIB
#
#CMFLAGS = -mcpu=$(MCU) -mthumb
#CFLAGS = $(DEF) -fmessage-length=0 -fno-builtin -ffunction-sections $(INC) $(CMFLAGS) \
#		 -MMD -MP -MF"$(@:%.o=%.d)" -MT"$(@:%.o=%.o)" -MT"$(@:%.o=%.d)"
#
#LDFLAGS = -nostdlib   $(CMFLAGS) -T$(LINKER)


CFLAGS = $(DEF) -mthumb -mcpu=cortex-m0
CFLAGS+= -O0 -g0 -ffunction-sections -fmessage-length=0  -fno-stack-protector -fdata-sections
#CFLAGS+= -flto -fno-builtin -nostdlib
CFLAGS+= -MD -std=c99 -w #-Wall #-pedantic
CFLAGS+= -DCORE_M0PLUS -D__GNU_ARM #-D__USE_CMSIS
#CFLAGS+= -DDEBUG -DDEBUG_ENABLE #-D__USE_LPCOPEN
CFLAGS+= -lrdimon -lc --specs=nano.specs --specs=rdimon.specs



## Assembler flags
ASFLAGS = -c -x assembler-with-cpp -D__START=main
LDFLAGS = $(CFLAGS) -T $(LINKER) -Wl,--gc-sections -lgcc -Wl,-Map=$(BUILD_DIR)/$(PROJECT).map
####################################################################
# RULES
####################################################################

all:  $(BUILD_DIR) $(OBJ_FILES) $(BUILD_DIR)/$(PROJECT).elf  $(BUILD_DIR)/$(PROJECT).hex $(BUILD_DIR)/$(PROJECT).bin
	@echo "Output code size:"
	@echo "****************************************"
	@echo "         Compilation Complete           "
	@echo "****************************************"
	@$(PREFIX)size  $(BUILD_DIR)/$(PROJECT).elf

$(OBJ_DIR)/%.o:: %.c
	$(info CC	$(notdir $<))
	@$(CC) $(INC) $(CFLAGS) -o $@ -c $<

$(OBJ_DIR)/%.o:: %.s
	$(info AS	$(notdir $<))
	@$(AS) $(ASFLAGS) -o $@ -c $<

$(BUILD_DIR)/%.elf: $(OBJ_FILES)
	$(info LD	$@)
	@$(CC) $(LDFLAGS) $(OBJ_FILES) -o $@

$(BUILD_DIR)/%.hex: $(BUILD_DIR)/%.elf
	$(info HEX	$<)
	@$(HEX) $< $@

$(BUILD_DIR)/%.bin: $(BUILD_DIR)/%.elf
	$(info BIN	$<)
	@$(BIN) $< $@

$(BUILD_DIR):
	$(info Creating directories...)
	@mkdir -p $(BUILD_DIR)
	@mkdir -p $(OBJ_DIR)

flash: all
	sudo openocd -f "/home/cagatay/gitFiles/OpenOCD-Nuvoton/tcl/interface/nulink.cfg" -f "/home/cagatay/gitFiles/OpenOCD-Nuvoton/tcl/target/numicroM0.cfg" -c "program ./build/main.bin verify reset exit"
clean:
	rm -fR $(BUILD_DIR)

test:
	@echo $(OBJ_FILES)
	@echo "=========================="
	@echo $(SRC_FILES)
