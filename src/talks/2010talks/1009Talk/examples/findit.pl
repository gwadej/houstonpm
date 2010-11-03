#!/usr/bin/perl

use strict;
use warnings;

while(<>) {
    my @fields = split / /, $_;
    if( $fields[0] =~ /\D/ ) {
        print "$ARGV: $_";
        next;
    }
    if( $fields[0] < 1000 ) {
        print "$ARGV: $_";
        next;
    }
    if( $fields[0] > time() ) {
        print "$ARGV: $_";
        next;
    }
}

