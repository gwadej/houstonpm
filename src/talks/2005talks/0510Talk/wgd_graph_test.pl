#! /usr/bin/perl -w

# testing the script given in Perl Graphics Programming, p. 117

use GD;
use GD::Graph::lines;

my @data = ( [qw(1957 1956 1957 1958 
                 1959 1960 1961 1962
				 1963 1964 1965 1966
				 1967 1968 1969 1970
				 1971 1972 1973)],
				 
			  # thousands of people in New York
			  [2, 5, 16.8, 18, 19, 22.6, 26, 32,
			   34, 39, 43, 48, 49, 49, 54.2, 58,
			   68, 72, 79],
			   
			  # thousands of people in SF
			  [11, 18, 29.4, 35.7, 36, 38.2, 36, 41,
			   45, 49, 50, 51, 51.4, 52.6, 53.2, 54, 
			   67, 73,78],
			   
			   # thousands of people in Peoria
			   [5, 8, 24, 32, 37, 40, 50, 55,
				61, 63, 61, 60, 65.5, 68, 71, 69,
				73, 73.5, 78, 78.5]
			);
			
my $graph = new GD::Graph::lines( );

$graph->set(
        title         => "America's love affair with cheese",
		x_label       => 'Time',
		y_label       => 'People (thousands)',
		y_max_value   => 80,
		y_tick_number => 8,
		x_all_ticks   => 1, 
		y_all_ticks   => 1, 
		x_label_skip  => 3,
		);
		
$graph->set_legend_font(GD::gdFontTiny);
$graph->set_legend('New York', 'San francisco', 'Peoria');

my $gd = $graph->plot(\@data);

open OUT, ">cheese.png" or die "Couldn't open for output: $!";
binmode (OUT);
print OUT $gd->png();
close OUT;

print "\n Done through, baby!";

#end main program =====================================================

