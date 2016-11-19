#!/usr/bin/env perl

use strict;
use warnings;
use List::Util qw/reduce/;
use 5.010;

my %ip_counts;
while(<>)
{
    next unless /\bwp-admin\b/;
    my ($ip) = /\A(\S+)/;
    $ip_counts{$ip}++;
}

foreach my $ip (sort keys %ip_counts)
{
    printf "%s : %d\n", $ip, $ip_counts{$ip};
}
