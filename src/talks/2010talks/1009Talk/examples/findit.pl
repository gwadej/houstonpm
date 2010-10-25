#!/usr/bin/perl

# cpanel - ProgPath.pl                            Copyright(c) 2009 cPanel, Inc.
#                                                           All rights Reserved.
# copyright@cpanel.net                                         http://cpanel.net
# This code is subject to the cPanel license. Unauthorized copying is prohibited

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

