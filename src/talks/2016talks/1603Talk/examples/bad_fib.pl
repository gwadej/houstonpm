#!/usr/bin/env perl

use strict;
use warnings;
use 5.010;

my ($steps,$good) = (0,0);
sub bad_fib
{
    my ($num) = @_;
    ++$steps;
    return 1 if $num < 2;
    return bad_fib($num-2) + bad_fib($num-1);
}

sub good_fib
{
    my ($num) = @_;
    ++$good;
    return 1 if $num < 2;
    my ($prev, $curr) = (1,1);

    for ( 2 .. $num)
    {
        ++$good;
        ($prev, $curr) = ($curr, $prev+$curr);
    }
    return $curr;
}

sub print_fib
{
    my ($num) = @_;
    print "$num ";
    print bad_fib($num), ", ", good_fib($num), " ($steps) ($good)\n";
    return;
}

print_fib( shift );
