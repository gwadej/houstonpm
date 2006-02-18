#!/usr/bin/perl
use warnings;
use strict;
use Inline (C => 'DATA',
		ENABLE => 'AUTOWRAP',
               LIBS => '-lusb',
               );


my %colors = (
		'none'  => 0x00,
		'green' => 0x01,
		'red'   => 0x02,
		'blue'  => 0x04,
	     );

my $speed=.02;

my $color = 0;
$color |= $colors{$_} for @ARGV;

my $usb = device_open();
change_color($usb, $color);
my $dim_color = int($color >>1);
#dim_color($usb,$dim_color,30);


#for (my $val=0;$val < 80;$val++){
#	perl_dim_color($usb,$dim_color,$val);
##dim_color($usb,$dim_color,$val);
#	select(undef,undef,undef,$speed);
#}

#for (my $val=80;$val >0;$val--){
#	dim_color($usb,$dim_color,$val);
#	select(undef,undef,undef,$speed);
#}


sub perl_dim_color {
	my ($handle, $color, $bright)=@_;
	control_msg($handle,
			0xc8,
			0x12,
			8714, # 10 + 34*256
			($color + ($bright * 256)),
			0x0,
			0x8,
			5000);
}
button_setup($usb, beep=>1,cancel=>1);
sub button_setup {
	my $handle = shift;
       	my %parms = @_;
	my ($lsb, $msb)=(0,0);
	if (exists $parms{"beep"}) {
		$msb |= 128 if $parms{"beep"}==1;
		$lsb |= 128 if $parms{"beep"}==0;
	}
	if (exists $parms{"cancel"}) {
		$msb |= 64 if $parms{"cancel"}==1;
		$lsb |= 64 if $parms{"cancel"}==0;
	}
			control_msg($handle,
			0xc8,
			0x12,
			(10 + (38 * 256)), # 38, enable events counter
			(1 +  (0 * 256)), # lsb bits on, msb bits off 
			0x0,
			0x8,
			5000);
	control_msg($handle,
			0xc8,
			0x12,
			(10 + (72 * 256)), # 72, button setup
			($lsb   + ($msb * 256)), # lsb bits off, msb bit 6 (auto clear) & 7 (auto confirm) on
			0x0,
			0x8,
			5000);
}

flash_color($usb, $color, 1);
sub flash_color {
	my ($handle, $color, $onoff) = @_;

	my ($lsb,$msb);
	if ($onoff) {
		$lsb=0;
		$msb=$color;
	}else{
		$lsb=$color;
		$msb=0;
	}
	control_msg($handle,
			0xc8,
			0x12,
			(10 + (20 * 256)), # 20, enable/disable flash mode
			($lsb   + ($msb * 256)), # lsb disables, msb enables
			0x0,
			0x8,
			5000);
}

color_speed ($usb, $color, 200, 20);
sub color_speed {
	my ($handle, $color, $duty_on, $duty_off) = @_;

	my $minor=0; # 0 - noop
	$minor=21 if $color == 1;
	$minor=22 if $color == 2;
	$minor=23 if $color == 4;
	print "color is $color\n";
	print "minor is $minor\n";
	control_msg($handle,
			0xc8,
			0x12,
			(10 + ($minor * 256)), # 21, 22, 23 duty cycle
			($duty_off   + ($duty_on * 256)), # lsb off, msb on
			0x0,
			0x8,
			5000);
}
setup_buzzer ($usb, 29, 3, 50, 50);
sub setup_buzzer {
	my ($handle, $freq, $repeat, $duty_on, $duty_off) = @_;

	control_msg($handle,
			0xc8,
			0x12,
			(10 + (70 * 256)), # 70, buzzer setup
			(1   + ($freq * 256)), # lsb on/off, msb freq
			$repeat,
			0x8,
			5000);
}
#	usb_control_msg((struct usb_dev_handle*) handle,		 	// usb_dev_handle *dev
#			0x000000c8,		// int requesttype
#			0x00000012,		// int request
#			(0x02 * 0x100) + 0x0a,	// int value
#			0xff & (~color),	// int index
#			dummy,			// char *bytes
#			0x00000008,		// int size
#			5000);			// int timeout


device_close($usb);
__DATA__

__C__

#include <usb.h>

#define LED_VENDOR_ID	0x0fc5
#define LED_PRODUCT_ID	0x1223


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
	printf("Device not found.\n");
	exit(1);
	return NULL;
}

void* device_open()
{
	struct usb_device *dev;
	dev = device_init();
	return usb_open(dev);
}

void device_close(void *dev)
{
	usb_close(dev);
}



void change_color(void *handle, unsigned color)
{
	char *dummy=NULL;

	usb_control_msg((struct usb_dev_handle*) handle,		 	// usb_dev_handle *dev
			0x000000c8,		// int requesttype
			0x00000012,		// int request
			(0x02 * 0x100) + 0x0a,	// int value
			0xff & (~color),	// int index
			dummy,			// char *bytes
			0x00000008,		// int size
			5000);			// int timeout
}
void dim_color( void *handle, unsigned color, unsigned brightness)
{
	char *dummy;

	usb_control_msg((struct usb_dev_handle*) handle,		 	// usb_dev_handle *dev
			0x000000c8,		// int requesttype (recipient)
			0x00000012,		// int requesti(model)
			0x0a + (0x22 * 0x100),	// int value (major cmd + minor cmd)
			color + (brightness * 0x100),	// int index (LSB + MSB)
			dummy,			// char *bytes
			0x00000008,		// int size
			5000);			// int timeout
}
void control_msg( void *handle, int requesttype, int request, int value, int index, char bytes, int size, int timeout)
{

	usb_control_msg((struct usb_dev_handle*) handle,
			requesttype,
			request,
			value,
			index,
			bytes,
			size,
			timeout);
}
