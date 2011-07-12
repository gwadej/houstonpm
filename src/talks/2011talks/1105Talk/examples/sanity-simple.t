#!/usr/bin/perl

use Test::Simple tests => 4;

use strict;
use warnings;

my $var = 1;
ok( $var == 1, 'Initial sanity verified' );
ok( $var =~ m/^\d+$/, 'Sanity still exists' );
ok( 2+2 == 5, 'Sanity has left the building' );
ok( 2+2 != 5, 'Sanity has been restored' );

