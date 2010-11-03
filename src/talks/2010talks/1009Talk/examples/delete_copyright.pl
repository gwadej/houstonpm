#!/usr/bin/perl -i.copy

use strict;
use warnings;

while(<>) {
    if( !/^<!-- Copyright/i ) {
        print;
    }
}

