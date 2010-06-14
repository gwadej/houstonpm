#!/usr/bin/env perl

use SVG;

my $svg = SVG->new( width => 200, height => 150 );
$svg->line( class=>'axes',
    x1=>50, y1=> 20, x2=>50, y2=>130 );
$svg->line( class=>'axes',
    x1=>50, y1=> 130, x2=>150, y2=>130 );
$svg->path( class=>'data',
    d=>'M50,130l10,-50l10,-30l10,40'
      . 'l10,-50l10,20l10,30l10,-80'
);

print $svg->xmlify;
