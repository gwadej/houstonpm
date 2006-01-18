#!/usr/bin/perl
use warnings;
use strict;
use Inline (C => 'DATA',
               LIBS => '-lusb',
               );


__DATA__

__C__
#include <stdio.h>
#include <string.h>
#include <usb.h>

#define NONE	0x00
#define GREEN	0x01
#define RED	0x02
#define BLUE	0x04

#define LED_VENDOR_ID	0x0fc5
#define LED_PRODUCT_ID	0x1223

void hello(){
	printf("Hey, all!\n");
}
void change_color(struct usb_dev_handle *handle, unsigned char color)
{
	char *dummy;

	usb_control_msg(handle,		 	// usb_dev_handle *dev
			0x000000c8,		// int requesttype
			0x00000012,		// int request
			(0x02 * 0x100) + 0x0a,	// int value
			0xff & (~color),	// int index
			dummy,			// char *bytes
			0x00000008,		// int size
			5000);			// int timeout
}

struct usb_device *device_init()
{
	struct usb_bus *usb_bus;
	struct usb_device *dev;

	usb_init();
	usb_find_busses();
	usb_find_devices();

	for (usb_bus = usb_busses; usb_bus; usb_bus = usb_bus->next) {
		for (dev = usb_bus->devices; dev; dev = dev->next) {
			if ((dev->descriptor.idVendor == LED_VENDOR_ID) && 
			    (dev->descriptor.idProduct == LED_PRODUCT_ID))
				return dev;
		}
	}
	return NULL;
}

int main(int argc, char **argv)
{
	struct usb_device *usb_dev;
	struct usb_dev_handle *usb_handle;
	int retval = 1;
	int i;
	unsigned char color = NONE;

	usb_dev = device_init();
	if (usb_dev == NULL) {
		fprintf(stderr, "Device not found\n");
		goto exit;
	}

	usb_handle = usb_open(usb_dev);
	if (usb_handle == NULL) {
		fprintf(stderr, "Not able to claim the USB device\n");
		goto exit;
	}
	
	if (argc == 1) {
		fprintf(stderr, "specify at least 1 color\n");
		goto exit;
	}

	for (i = 1; i < argc; ++i) {
		if (strcasecmp(argv[i], "red") == 0)
			color |= RED;
		if (strcasecmp(argv[i], "blue") == 0)
			color |= BLUE;
		if (strcasecmp(argv[i], "green") == 0)
			color |= GREEN;
		if (strcasecmp(argv[i], "none") == 0)
			color = NONE;
	}
	change_color(usb_handle, color);
	retval = 0;
	
exit:
	usb_close(usb_handle);
	return retval;
}
