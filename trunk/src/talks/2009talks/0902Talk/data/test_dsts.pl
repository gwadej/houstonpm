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

foreach my $delta ( 0 .. 17280 )
{
    my $update = join( ':', $start+($delta*300), ($input)x4 );
    push @updates, $update;

    given($delta) {
        when(0 == $_%1000) { $input *= 2; }
        when(0 == $_%200) { $input += 256; }
        when(0 == $_%100) { $input -= 128; }
        when(0 == $_%10)  { $input += 25; }
        when(0 == $_%3)   { $input += 5; }
    }
}

system( 'rrdtool', 'update', 'dst_test.rrd', @updates );

system <<'EOF';
rrdtool graph dst_test.png \
    --start='midnight 20081101' --end='midnight 20081201' \
    --title='DST comparison' --width=500 --height=200 \
    DEF:gauge=dst_test.rrd:in_g:AVERAGE \
    DEF:counter=dst_test.rrd:in_c:AVERAGE \
    DEF:derive=dst_test.rrd:in_d:AVERAGE \
    DEF:absolute=dst_test.rrd:in_a:AVERAGE \
    LINE1:gauge#0000FF:"Gauge" \
    LINE1:counter#00FF00:"Counter" \
    LINE1:derive#FF0000:"Derive" \
    LINE1:absolute#FF00FF:"Absolute"
EOF

system <<'EOF';
rrdtool graph dst_test2.png \
    --start='midnight 20081101' --end='midnight 20081201' \
    --title='DST comparison (limited)' --width=500 --height=200 \
    --upper-limit=2000 --rigid \
    DEF:gauge=dst_test.rrd:in_g:AVERAGE \
    DEF:counter=dst_test.rrd:in_c:AVERAGE \
    DEF:derive=dst_test.rrd:in_d:AVERAGE \
    DEF:absolute=dst_test.rrd:in_a:AVERAGE \
    LINE1:gauge#0000FF:"Gauge" \
    LINE1:counter#00FF00:"Counter" \
    LINE1:derive#FF0000:"Derive" \
    LINE1:absolute#FF00FF:"Absolute"
EOF
