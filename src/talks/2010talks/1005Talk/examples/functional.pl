#!/usr/bin/env perl

use strict;
use warnings;

print map { $_, "\n" }                  # add newlines, print list
      grep { defined $_ && length $_ }  # discard missing values
      map { chomp; (split /,/, $_)[1] } # extract field
      <>;                               # read lines from input
