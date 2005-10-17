#! /usr/bin/perl -w

# graph_jd_mag.pl



# Purpose: plot the truncated JD and magnitude data for SS Cyg

# Input: the truncated JD mag file coming from jd_mag_fetch.pl

# Output: a png graphics file

# Author: W. G. Dillon.



# Future Enhancements
#     Add dynamic axis scaling

# .......................................................................

# use strict;

#                 main variables
  my $DEBUG   = 0;
  my $version = '1.1';
  print "\n graph_jd_mag.pl version $version \n";
  my $graph1  = 'ss_cyg_jd_mag.png';                      # Section total graph


  print "\n Enter the input jd/mag file name:  ";
  my $in_file = <>;
  chomp ($in_file);
  print "\n You entered: $in_file.\n";
  

  open (INPUT, $in_file) || die "Can't open $in_file, error $!\n";

  use GD;
  use GD::Graph::points;


  # ....................... get the input data and parse it.........................

  @lines = <INPUT>;


  print "\n";

  my $date;     # put the truncated JD here
  my @dates;    # all dates
  my $mag;      # put the magnitude for the truncated JD here
  my @mags;     # all mags

  foreach $line (@lines)
  {
      if ($DEBUG) {print "$line";}

     ## REWRITE USING SPLIT FUNCTION!

     ($date, $mag) 
        = ($line =~ m/(\S+),\s+(\S+)/ );
      
     $mag *= -1;          # reverse sign of magnitude for plotting purposes

     push (@dates, $date);
     push (@mags,  $mag);

  }  # end of foreach loop on the input file



  my $num_dates = $#dates + 1;   # get the number of dates being plotted
     print "\n\n The number of JD/mag pairs being plotted is: $num_dates.\n";


  my @data     = ( [@dates], [@mags] );

		
  # ......................   graph ..............................................



  my $graph =     new GD::Graph::points(50000, 450);

  $graph->set(
                title         => "Magnitude estimates for SS Cyg",
		        x_label       => 'Truncated JD',
		        y_label       => 'Magnitude',
		        y_max_value   => -7,
                y_min_value   => -13,
		        y_tick_number => 6,
		        y_all_ticks   => 1, 
                x_min_value   => 19000.,
                x_max_value   => 54000.,
                x_tick_number => 35,
                markers       => [1],
                marker_size   => 1,     
	      );
		
  $graph->set_legend_font(GD::gdFontTiny);

  my $gd     = $graph->plot(\@data);


  open OUT,  ">$graph1" or die "Couldn't open for output: $!";

  binmode (OUT);

  print OUT  $gd->png();

  close OUT;

print "\n graph_jd_mag.pl complete. \n";

# ===================================================================
# History
#
# Ask for input filename, reverse sign on magnitude                 v1.1  10-Oct_2005
# First working version                                             v1.0  10-Oct-2005

