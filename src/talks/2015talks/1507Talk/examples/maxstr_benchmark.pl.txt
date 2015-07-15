#!/usr/bin/env perl

use strict;
use warnings;
use 5.010;
use Benchmark qw/cmpthese/;
use List::Util qw/maxstr shuffle/;


my @strings = shuffle(
    qw/david mark kirsten connie aramis bryan fred bianca/,
    ('a' .. 'z'),
    ('aaa' .. 'zzz')
);

cmpthese( -2, {
        foreach => \&maxstr_foreach,
        maxstr  => \&maxstr_lu,
    });

sub maxstr_foreach
{
    my $big = $strings[0];
    foreach (@strings)
    {
        $big = $_ if $_ gt $big;
    }
    return $big;
}

sub maxstr_lu
{
    my $big = maxstr @strings;
    return $big;
}
