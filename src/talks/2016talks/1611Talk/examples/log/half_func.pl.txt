#!/usr/bin/env perl

use strict;
use warnings;
use List::Util qw/reduce/;
use 5.010;

my $ip_counts = reduce { $a->{$b}++; $a } +{},
                map    { /\A(\S+)/ }
                grep   { /\bwp-admin\b/ }
                <>;

foreach my $ip (sort keys %{$ip_counts})
{
    printf "%s : %d\n", $ip, $ip_counts->{$ip};
}
