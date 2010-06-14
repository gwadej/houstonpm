#!/usr/bin/env perl

use SVG::Sparkline;

my @temps = (61,67,67,77,83,84,82,84,84,86,78,50,44,47,
    54,76,72,78,78,80,80,82,81,77,82,74,77,64,72,75,71);
my $svg = SVG::Sparkline->new( Line => { values=>\@temps } );

print $svg;
