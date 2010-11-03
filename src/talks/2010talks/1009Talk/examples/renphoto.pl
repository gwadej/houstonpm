#!/usr/bin/perl

use strict;
use warnings;

# Process one file at a time from the command line
foreach my $file ( @ARGV ) {
    my @stat = stat( $file );  # Get file attributes
    my $stamp = $stat[9];  # Modification time
    my $date_time = date_time( $stamp ); # Make formatting the date easier.
    my $newname = $file;

    # The next two lines really do the rename
    $newname =~ s/DSCN(\d+)\.JPG$/Vacation-$date_time-$1-wade.jpg/;
    rename( $file, $newname );
}

# Take a Unix epoch time and generate a human readable string out of it.
sub date_time {
    my ($stamp) = @_;

    my ($sec, $min, $hour, $day, $mon, $year) = localtime( $stamp ); # Extract time components
    $mon += 1;
    $year += 1900;
    return sprintf( '%04d%02d%02d-%02d%02d%02d', $year, $mon, $day, $hour, $min, $sec );
}

