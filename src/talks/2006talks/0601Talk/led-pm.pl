#!/usr/bin/perl
use warnings;
use strict;
use Inline (C => 'DATA',
               LIBS => '-lusb',
               );
my %colors = (
		'none'  => 0x00,
		'red'   => 0x02,
		'blue'  => 0x04,
		'green' => 0x01,
	     );
#hello();

my $usb = device_open();
print "$usb\n";

my $color = 0;
$color |= $colors{$_} for @ARGV;

change_color($usb, $color);

device_close($usb);



__DATA__

__C__
#include <stdio.h>
#include <string.h>
#include <usb.h>

#define LED_VENDOR_ID	0x0fc5
#define LED_PRODUCT_ID	0x1223

void *device_init();

void* device_open()
{
	struct usb_device *dev;
	dev = device_init();
	return usb_open(dev);
}

void *device_init()
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
void device_close(void *dev)
{
	usb_close(dev);
}



void change_color(void *handle, unsigned color)
{
	char *dummy;

	usb_control_msg((struct usb_dev_handle*) handle,		 	// usb_dev_handle *dev
			0x000000c8,		// int requesttype
			0x00000012,		// int request
			(0x02 * 0x100) + 0x0a,	// int value
			0xff & (~color),	// int index
			dummy,			// char *bytes
			0x00000008,		// int size
			5000);			// int timeout
}

/* ----
void beep( void *handle )
{
	
	usb_control_msg((struct usb_dev_handle*) handle,		 	// usb_dev_handle *dev
			0x000000c8,		// int requesttype (recipient)
			0x00000012,		// int requesti(model)
			(0x02 * 0x100) + 0x0a,	// int value (major cmd)
			0xff & (~color),	// int index (minor cmd)
			dummy,			// char *bytes (data lsb)
			0x00000008,		// int size (data msb)
			5000);			// int timeout
}
---------- */

void hello(){
	printf("Hey, all!\n");
	void* handle = device_open();
	change_color(handle,2);
	device_close(handle);
}
