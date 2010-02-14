#!/usr/bin/env perl

use strict;
use warnings;
use 5.010;

my $totals_file = 'totals';

my %totals;
my %accum;

while(<>)
{
    chomp;
    my ($stamp, $bytes) = split /=/, $_;
    if ( $ARGV eq $totals_file )
    {
        $totals{$stamp} = $bytes;
    }
    else
    {
        $accum{$stamp} += $bytes;
    }
}

if( scalar(keys %totals) != scalar(keys %accum) )
{
    print "The number of lines in the totals files doesn't match the individual files.\n";
}

foreach my $stamp (sort keys %totals)
{
    print "$stamp: $totals{$stamp} != $accum{$stamp}\n"
        if $totals{$stamp} != $accum{$stamp};
}
