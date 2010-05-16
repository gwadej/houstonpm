#!/usr/bin/env perl

use strict;
use warnings;

while(<>) {                                    # for all lines
    chomp;                                     # discard newline
    my @f = split /,/, $_;                     # split into fields
    next unless defined $f[1] && length $f[1]; # discard missing values
    print $f[1], "\n";                         # print with newline
}

