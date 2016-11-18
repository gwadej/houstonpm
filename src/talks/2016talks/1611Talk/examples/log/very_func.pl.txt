#!/usr/bin/env perl

use strict;
use warnings;
use List::Util qw/reduce/;
use 5.010;

my $ip_counts = reduce { $a->{$b}++; $a } +{},
                map    { /\A(\S+)/ }
                grep   { /\bwp-admin\b/ }
                <>;

printf "%s : %d\n", $_->[0], $_->[1]
                foreach sort { $a->[0] cmp $b->[0] }
                        map  { [ $_, $ip_counts->{$_} ] }
                        keys %{$ip_counts};
