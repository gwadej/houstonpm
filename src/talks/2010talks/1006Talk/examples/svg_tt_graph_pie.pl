#!/usr/bin/env perl

use SVG::TT::Graph::Pie;
my $graph = SVG::TT::Graph::Pie->new({
    'height' => 200, 'width' => 350,
    'compress' => 0, 'expand_greatest' => 1,
    'fields' => [ qw/Jan Feb Mar Apr May/ ],
});

$graph->add_data({ 'data' => [ 50, 60, 53, 58 ], });

print $graph->burn;

