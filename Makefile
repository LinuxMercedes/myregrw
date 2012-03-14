make ARCH=arm CROSS_COMPILE=/home/nathan/esd/bin/arm-none-linux-gnueabi-

obj-m += myregrw.o

#KERNELDIR := /lib/modules/$(shell uname -r)/build
KERNELDIR := ~/esd/linux/linux-2.6.29/

CROSS_COMPILE := /home/nathan/esd/bin/arm-none-linux-gnueabi-

default:
	make -C $(KERNELDIR) O="/home/nathan/esd/linux/built_kernel" M=$(shell pwd) modules
	#gcc -Wall tt-myregrw.c parse_conf.c record_content.c
	$(CROSS_COMPILE)gcc -march=armv4t -static -g -Wall tt-myregrw.c parse_conf.c record_content.c -o myregrw
	-cp myregrw /var/lib/tftpboot/
	-cp myregrw.ko /var/lib/tftpboot/

install:
	insmod register_char.ko	
uninstall:
	@rmmod register_char.ko

clean:
	make -C $(KERNELDIR) M=$(shell pwd) clean
	rm -rf *.symvers a.out *.markers *.order
