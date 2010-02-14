#!/usr/bin/env perl

use strict;
use warnings;
use 5.010;
use Time::Local qw(timelocal);

system <<'EOF';
rrdtool create day_test.rrd --step=86400 --start='midnight 20080101' \
    DS:in_g:GAUGE:100000:0:U \
    DS:in_c:COUNTER:100000:0:U \
    DS:in_d:DERIVE:100000:0:U \
    DS:in_a:ABSOLUTE:100000:0:U \
    RRA:AVERAGE:0.999:1:60
EOF

my $start = timelocal( 0, 0, 0, 28, 9, 108 ); # Oct 28, 2008

my @updates;
my $input = 1024;

foreach my $delta ( 0 .. 17280 )
{
    my $update = join( ':', $start+($delta*300), ($input)x4 );
    push @updates, $update;

    given($delta) {
        when(0 == $_%576) { $input += 250; }
        when(0 == $_%288) { $input -= 250; }
    }
}

system( 'rrdtool', 'update', 'day_test.rrd', @updates );

system <<'EOF';
rrdtool graph day_test.png \
    --start='midnight 20081101' --end='midnight 20081201' \
    --title='Month by Day' --width=500 --height=200 \
    --x-grid=DAY:1:DAY:1:DAY:5:0:%d \
    DEF:gauge=day_test.rrd:in_g:AVERAGE \
    AREA:gauge#0000FF:"Gauge"
EOF
