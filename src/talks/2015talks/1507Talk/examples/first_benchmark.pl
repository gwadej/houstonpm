#!/usr/bin/env perl

use strict;
use warnings;
use 5.010;
use Benchmark qw/cmpthese/;
use List::MoreUtils qw/firstval/;


my @strings = (
    qw/david mark kirsten connie aramis bryan fred bianca/,
    ('a' .. 'z'),
    ('aaa' .. 'zzz')
);

my $switch = shift || '';
my $val = $switch eq 'first' ? $strings[0] :
          $switch eq 'mid'   ? $strings[@strings/2] :
          $switch eq 'last'  ? $strings[-1] :
                               'xyzzy';

cmpthese( -2, {
        foreach  => sub { return first_foreach( $val ); },
        grep     => sub { return first_foreach( $val ); },
        first    => sub { return first_foreach( $val ); },
    });

sub first_foreach
{
    my ($val) = @_;
    foreach (@strings)
    {
        return $_ if $_ eq $val;
    }
    return;
}

sub first_grep
{
    my ($val) = @_;
    return (grep { $val eq $_ } @strings)[0];
}

sub first_lu
{
    my ($val) = @_;
    return firstval { $val eq $_ } @strings;
}
