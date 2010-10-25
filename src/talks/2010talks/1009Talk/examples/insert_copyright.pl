#!/usr/bin/perl -i.bak

# cpanel - ProgPath.pl                            Copyright(c) 2010 cPanel, Inc.
#                                                           All rights Reserved.
# copyright@cpanel.net                                         http://cpanel.net
# This code is subject to the cPanel license. Unauthorized copying is prohibited

use strict;
use warnings;

while(<>) {
    print;
    if( /^<html/i ) {
        print "<!-- Copyright 2010 - FooBarCo. -->\n";
    }
}

