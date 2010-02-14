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

my $bad_days = 0;
foreach my $stamp (sort keys %totals)
{
    ++$bad_days if $totals{$stamp} != $accum{$stamp};
}

print "$bad_days bad days were found.\n";
