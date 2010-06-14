#!/usr/bin/env perl

use strict;
use warnings;
use 5.010;

use SVG::TT::Graph::Line;
open my $cfh, '>', 'images/business_graphics.svg' or die "Unable to write 'business_graphics.svg': $!\n";
print $cfh <<'EOH';
<svg xmlns="http://www.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink"
   viewBox="0 0 800 600">
  <?xml-stylesheet href="../style/lines.css" type="text/css"?>
EOH
{
    my $graph = SVG::TT::Graph::Line->new({
        'height' => 200,
        'width' => 350,
        'compress' => 0,
        'show_data_values' => 0,
        'show_y_title' => 1,
        'y_title' => 'Temp. (F)',
        'show_x_title' => 1,
        'x_title' => 'Date',
        'stagger_x_labels' => 1,
        'style_sheet' => '../style/lines.css',
        'fields' => [ 1 .. 30 ],
    });

    $graph->add_data({
        'data' => [61,67,67,77,83,84,82,84,84,86,78,50,44,47,54,76,72,78,78,80,80,82,81,77,82,74,77,64,72,75],
        'title' => 'High Temperatures',
    });
    $graph->add_data({
        'data' => [32,29,38,44,59,62,67,64,68,69,50,43,42,41,47,47,48,45,44,46,51,67,69,57,55,47,38,37,45,52],
        'title' => 'Low Temperatures',
    });

    my $svg = $graph->burn;
    $svg =~ s/<!DOCTYPE[^>]+>\n//sm;
    $svg =~ s/<\?xml[^>]+>\n//gsm;
    $svg =~ s/width/x="10" y="10" id="line" preserveAspectRatio="xMidyMid" width/;
    print $cfh $svg;
}

use SVG::TT::Graph::Bar;
{
    my $graph = SVG::TT::Graph::Bar->new({
        'height' => 200,
        'width' => 350,
        'compress' => 0,
        'show_data_values' => 0,
        'show_y_title' => 1,
        'y_title' => 'Rain Fall',
        'show_x_title' => 1,
        'x_title' => 'Month',
        'style_sheet' => '../style/lines.css',
        'fields' => [ qw/Jan Feb Mar Apr May Jun Jul Aug Sep Oct Nov Dec/ ],
    });

    $graph->add_data({
        'data' => [
            4.25, 3.01, 2.41, 1.46, 5.11, 2.06, 1.09, 4.54, 5.62, 5.26, 2.92, 1.68,
        ],
        'title' => 'Set 1',
    });
    $graph->add_data({
        'data' => [
            4.62, 4.00, 3.19, 3.46, 4.57, 6.84, 4.36, 7.45, 12.07, 8.67, 4.54, 3.78,
        ],
        'title' => 'Set 2',
    });

    my $svg = $graph->burn;
    $svg =~ s/<!DOCTYPE[^>]+>\n//sm;
    $svg =~ s/<\?xml[^>]+>\n//gsm;
    $svg =~ s/width/x="400" y="10" id="bar" preserveAspectRatio="xMidyMid" width/;
    print $cfh $svg;
}


use SVG::TT::Graph::Pie;
{
    my $graph = SVG::TT::Graph::Pie->new({
        'height' => 200,
        'width' => 350,
        'compress' => 0,
        'expand_greatest' => 1,
        'fields' => [ qw/Jan Feb Mar Apr May/ ],
    });

    $graph->add_data({
        'data' => [ map { rand(50)+10 } 0..4 ],
        'title' => 'Set 1',
    });

    my $svg = $graph->burn;
    $svg =~ s/<!DOCTYPE[^>]+>\n//sm;
    $svg =~ s/<\?xml[^>]+>\n//gsm;
    $svg =~ s/width/x="300" y="210" id="pie" preserveAspectRatio="xMidyMid" width/;
    print $cfh $svg;
}

print $cfh <<'EOH';
</svg>
EOH
close $cfh;

{
    my $graph = SVG::TT::Graph::Bar->new({
        'height' => 200,
        'width' => 350,
        'compress' => 0,
        'show_data_values' => 0,
        'show_y_title' => 1,
        'y_title' => 'Number of Scores',
        'show_x_title' => 1,
        'x_title' => 'Percentile',
        'style_sheet' => '../style/lines.css',
        'bar_gap' => 0,
        'scale_integers' => 1,
        'scale_divisions' => 5,
        'fields' => [ qw/20 30 40 50 60 70 80 90 100/ ],
    });

    $graph->add_data({
        'data' => [
           0, 1, 2, 2, 5, 10, 20, 15, 5 
        ],
        'title' => 'Set 1',
    });

    my $svg = $graph->burn;
    $svg =~ s/<!DOCTYPE[^>]+>\n//sm;
    $svg =~ s/width="350" height="200"/preserveAspectRatio="xMidyMid" width="100%" height="100%"/;
    open my $fh, '>', 'images/histogram.svg' or die "Unable to write 'histogram.svg': $!\n";
    print $fh $svg;
    close $fh;
}

