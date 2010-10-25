#!/usr/bin/perl -i.copy

# cpanel - ProgPath.pl                            Copyright(c) 2010 cPanel, Inc.
#                                                           All rights Reserved.
# copyright@cpanel.net                                         http://cpanel.net
# This code is subject to the cPanel license. Unauthorized copying is prohibited

use strict;
use warnings;

while(<>) {
    if( !/^<!-- Copyright/i ) {
        print;
    }
}

