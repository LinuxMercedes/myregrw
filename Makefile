make ARCH=arm CROSS_COMPILE=/home/nathan/esd/bin/arm-none-linux-gnueabi-

obj-m += myregrw.o

#KERNELDIR := /lib/modules/$(shell uname -r)/build
KERNELDIR := ~/esd/linux/linux-2.6.29/

CROSS_COMPILE := /home/nathan/esd/bin/arm-none-linux-gnueabi-
EXTRA_CFLAGS := -march=armv4t -static -Wall
RELFLAGS := -O3
DBGFLAGS := -g

default:
	make -C $(KERNELDIR) O="/home/nathan/esd/linux/built_kernel" M=$(shell pwd) modules
	#gcc -Wall tt-myregrw.c parse_conf.c record_content.c
	$(CROSS_COMPILE)gcc $(EXTRA_CFLAGS) $(RELFLAGS) tt-myregrw.c parse_conf.c record_content.c -o myregrw
	-cp myregrw /var/lib/tftpboot/
	-cp myregrw.ko /var/lib/tftpboot/

debug:
	make -C $(KERNELDIR) O="/home/nathan/esd/linux/built_kernel" M=$(shell pwd) modules
	$(CROSS_COMPILE)gcc $(EXTRA_CFLAGS) $(DBGFLAGS) tt-myregrw.c parse_conf.c record_content.c -o myregrw
	-cp myregrw /var/lib/tftpboot/
	-cp myregrw.ko /var/lib/tftpboot/

package: default
	mkdir -p regrw
	cp myregrw regrw/
	cp myregrw.ko regrw/
	cp use.txt regrw/
	-rm myregrw.zip
	zip myregrw.zip regrw/*
	-rm -r regrw/

install:
	insmod register_char.ko	
uninstall:
	@rmmod register_char.ko

clean:
	make -C $(KERNELDIR) M=$(shell pwd) clean
	rm -rf *.symvers a.out *.markers *.order
