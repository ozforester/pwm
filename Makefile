# Copyright (c) 2021 ozforester. All rights reserved.
# Use of this source code is goverened by a MIT license
# that can be found in the LICENSE file.


TARGET	 = pwm
SOURCES := $(wildcard *.S)
OBJECTS  = $(SOURCES:.S=.o)
# depending of host platform -no-pie variant may be desirable
CFLAGS = -fno-stack-protector -fno-pic -DF_CPU=4000000 -Wall -mmcu=atmega8 -ffunction-sections -fdata-sections -Os
#CFLAGS = -no-pie -fno-stack-protector -fno-pic -DF_CPU=4000000 -Wall -mmcu=atmega8 -Os

all:
	avr-gcc ${CFLAGS} -c -Wall ${OPT} -mmcu=atmega8 -o ${TARGET}.o ${TARGET}.S
	avr-gcc ${CFLAGS} -Wall ${OPT} -mmcu=atmega8 -o ${TARGET} ${TARGET}.o
	avr-objcopy -O ihex ${TARGET} ${TARGET}.hex
	avr-size ${TARGET}
	avr-size ${TARGET}.hex

flash:
	avrdude -c usbasp -p m8 -B 8 -U flash:w:${TARGET}.hex

clean:
	rm -f $(OBJECTS) ${TARGET} $(TARGET).o $(TARGET).hex
