#!/usr/bin/perl

use Test::More tests => 4;

use strict;
use warnings;

my $var = 1;
is( $var, 1, 'Initial sanity verified' );
like( $var, qr/^\d+$/, 'Sanity still exists' );
is( 2+2, 5, 'Sanity has left the building' );
isnt( 2+2, 5, 'Sanity has been restored' );

