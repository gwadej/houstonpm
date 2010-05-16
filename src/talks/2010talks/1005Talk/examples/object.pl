#!/usr/bin/env perl

use strict;
use warnings;
use Text::CSV_XS;

# create parsing object
my $csv = Text::CSV_XS->new({ binary => 1, eol => $/ });
# for all lines
while (my $row = $csv->getline( *ARGV )) { # Object parses line into fields
                                           # discard missing values
    next unless defined $row->[1] && length $row->[1];
    print $row->[1], "\n";                 # print with newlines
}

