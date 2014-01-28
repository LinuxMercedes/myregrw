#define _GNU_SOURCE
#include <stdio.h>
#include <stdlib.h>
#include <ctype.h>
#include <fcntl.h>		/* open */
#include <unistd.h>		/* exit */
#include <stdlib.h>	
#include <string.h>
#include <sys/ioctl.h>		/* ioctl */
#include <errno.h>
#include <signal.h>

#include "myregrw.h"
#include "phy_addr.h"

#define DEVICE_NAME "./regrw"
#define LEN 30

extern int query_lines(const char *filename);
extern int parse_config(const char *filename, struct config_info *p_config_info, int mode);

/* SIGINT (ctrl-c) handler */
static int done = 0;

void cleanup(int signum)
{
  printf("Received signal %d, cleaning up...\n", signum);
  done++;
  return;
}

void __record_contend(FILE *fp, unsigned long reg_info[])
{
	int ret=0;
	char buf[LEN]={0};

  sprintf(buf, "%lx\t\t%-lx\n", reg_info[0], reg_info[1]);
  
  ret = fwrite(buf, strlen(buf), 1, fp);

  if(ret != 1)
    printf("Error in recording the contents of registers!\n");
}

void record_contend(const char *config_fp, const char *content_fp, int mode, int forever)
{
	int fd;
	int num;
	unsigned int i, j;
	int ret_val;

	FILE *fp;

	/*
	 * reg_info[0] : register address
	 * reg_info[1] : register data  tobe write to the address 
	 */
	unsigned long reg_info[2] ={0};

	struct config_info *p_config_info, *p_config_info_bat;

  //Register ctrl-c handler
  signal(SIGINT, cleanup);

	fd = open(DEVICE_NAME, O_RDWR);
	if(fd < 0)
	{
		printf("error:  %s (%d)\n", strerror(errno), errno);
		return;
	}
	
	num = query_lines(config_fp);
	printf("There are %d items in file %s, totally.\n", num, config_fp);


	p_config_info = (struct config_info *)(malloc(num*sizeof(struct config_info)));
	if (p_config_info == NULL) {
		printf("no mem avaliable\n");
		exit(1);
	}
	p_config_info_bat = p_config_info;

  //Read the config
	parse_config(config_fp, p_config_info, mode);

  // Open the file for the register data in append mode
	fp = fopen(content_fp, "a+");
	if (fp == NULL) {
		printf("Cannot open configuration file %s\n", content_fp);
		exit(-1);
	}
  
  //Read the registers listed num times or forever
  for(i=0; (i<num || forever) && (!done); i++) {
    //If we're looping forever, loop back to the beginning of the registers to read
    if(i%num== 0) {
      p_config_info = p_config_info_bat;
//      i = 0; /* Prevent integer overflow */
    }

    //Read each register
		for(j=0; (j<p_config_info->count) && (!done) ; j++) {
			if (p_config_info->base_addr%4 == 0) {
				reg_info[0] = p_config_info->base_addr;
			} else {
				printf("The base address must be aligned with 4\n");
			}
			if (0 == mode)
				ret_val = ioctl(fd, MYREGRW_WRITE, reg_info);
			else
				ret_val = ioctl(fd, MYREGRW_READ, reg_info);
			if (ret_val < 0) {
				printf("ioctl put and get msg failed : %d\n", ret_val);
			} else {
				printf("addr = %lx,\tvalue = %lx\n", reg_info[0], reg_info[1]);
//				__record_contend(fp, reg_info);
			}
		}
		p_config_info++;
	}	

	if(p_config_info_bat)
		free(p_config_info_bat);

  printf("read %d times\n", i);
	
	fclose(fp);
	close(fd);
}
