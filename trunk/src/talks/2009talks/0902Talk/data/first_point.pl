#!/usr/bin/env perl

use strict;
use warnings;
use 5.010;
use Time::Local qw(timelocal);

system <<'EOF';
rrdtool create dst_test.rrd --start='midnight 20080101' \
    DS:in_g:GAUGE:3600:0:U \
    DS:in_c:COUNTER:3600:0:U \
    DS:in_d:DERIVE:3600:0:U \
    DS:in_a:ABSOLUTE:3600:0:U \
    RRA:AVERAGE:0.999:1:17280 \
    RRA:AVERAGE:0.999:12:1440 \
    RRA:MIN:0.999:12:1440 \
    RRA:MAX:0.999:12:1440 \
    RRA:LAST:0.999:12:1440
EOF

my $start = timelocal( 0, 0, 0, 1, 10, 108 ); # Nov 1, 2008

my @updates;
my $input = 1024;

foreach my $delta ( 0 .. 100 )
{
   push @updates, join( ':', $start+$delta*10, ($input)x4 );
}

system( 'rrdtool', 'update', 'dst_test.rrd', @updates );

