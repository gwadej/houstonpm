#!/usr/bin/perl -i.bak

use strict;
use warnings;

while(<>) {
    print;
    if( /^<html/i ) {
        print "<!-- Copyright 2010 - FooBarCo. -->\n";
    }
}

