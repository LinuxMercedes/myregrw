make ARCH=arm CROSS_COMPILE=arm-linux-

obj-m += myregrw.o

#KERNELDIR := /lib/modules/$(shell uname -r)/build
KERNELDIR := ~/esd/linux-2.6.29/

default:
	make -C $(KERNELDIR) M=$(shell pwd) modules
	#gcc -Wall tt-myregrw.c parse_conf.c record_content.c
	gcc -static -Wall tt-myregrw.c parse_conf.c record_content.c -o myregrw

install:
	insmod register_char.ko	
uninstall:
	@rmmod register_char.ko

clean:
	make -C $(KERNELDIR) M=$(shell pwd) clean
	rm -rf *.symvers a.out *.markers *.order
