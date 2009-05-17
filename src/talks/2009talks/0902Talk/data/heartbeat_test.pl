#!/usr/bin/env perl

use strict;
use warnings;
use 5.010;
use Time::Local qw(timelocal);

system <<'EOF';
rrdtool create hb_test.rrd --start='midnight 20080101' \
    DS:in_1:GAUGE:60:0:U \
    DS:in_5:GAUGE:300:0:U \
    DS:in_10:GAUGE:600:0:U \
    DS:in_hr:GAUGE:3600:0:U \
    RRA:AVERAGE:0.999:1:17280
EOF

my $start = timelocal( 0, 0, 0, 1, 10, 108 ); # Nov 1, 2008

my @updates;
my $input = 1024;

my @missing = (qw/5 10 15/, 30 .. 40, 60 .. 100, 105, 106, 107);
foreach my $delta ( 0 .. 17280 )
{
    next if $delta ~~ @missing;
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

system( 'rrdtool', 'update', 'hb_test.rrd', @updates );

system <<'EOF';
rrdtool graph hb_test.png \
    --start='midnight 20081101' --end='10:00am 20081101' \
    --title='Heartbeat comparison' --width=500 --height=400 \
    DEF:min=hb_test.rrd:in_1:AVERAGE \
    DEF:m5=hb_test.rrd:in_5:AVERAGE \
    DEF:m10=hb_test.rrd:in_10:AVERAGE \
    DEF:h1=hb_test.rrd:in_hr:AVERAGE \
    LINE1:min#0000FF:"1 minute" \
    LINE:500 \
    LINE1:m5#00FF00:"5 minute":STACK \
    LINE:3000 \
    LINE1:m10#FF0000:"10 minute":STACK \
    LINE:5500 \
    LINE1:h1#FF00FF:"Hour":STACK
EOF

system <<'EOF';
rrdtool graph hb_test2.png \
    --start='midnight 20081101' --end='10:00am 20081101' \
    --title='Heartbeat comparison (no undef)' --width=500 --height=400 \
    DEF:rmin=hb_test.rrd:in_1:AVERAGE \
    DEF:rm5=hb_test.rrd:in_5:AVERAGE \
    DEF:rm10=hb_test.rrd:in_10:AVERAGE \
    DEF:rh1=hb_test.rrd:in_hr:AVERAGE \
    CDEF:min=rmin,UN,0,rmin,IF \
    CDEF:m5=rm5,UN,0,rm5,IF \
    CDEF:m10=rm10,UN,0,rm10,IF \
    CDEF:h1=rh1,UN,0,rh1,IF \
    LINE1:min#0000FF:"1 minute" \
    LINE:500 \
    LINE1:m5#00FF00:"5 minute":STACK \
    LINE:3000 \
    LINE1:m10#FF0000:"10 minute":STACK \
    LINE:5500 \
    LINE1:h1#FF00FF:"Hour":STACK
EOF
