#!/usr/bin/perl

# cpanel - ProgPath.pl                            Copyright(c) 2009 cPanel, Inc.
#                                                           All rights Reserved.
# copyright@cpanel.net                                         http://cpanel.net
# This code is subject to the cPanel license. Unauthorized copying is prohibited

use strict;
use warnings;

foreach my $file ( @ARGV ) {
    my @stat = stat( $file );  # Get file attributes
    my $stamp = $stat[9];  # Modification time
    my $date_time = date_time( $stamp );
    my $newname = $file;
    $newname =~ s/DSCN(\d+)\.JPG$/Vacation-$date_time-$1-wade.jpg/;
    rename( $file, $newname );
}


sub date_time {
    my ($stamp) = @_;

    my ($sec, $min, $hour, $day, $mon, $year) = localtime( $stamp ); # Extract time components
    $mon += 1;
    $year += 1900;
    return sprintf( '%04d%02d%02d-%02d%02d%02d', $year, $mon, $day, $hour, $min, $sec );
}

