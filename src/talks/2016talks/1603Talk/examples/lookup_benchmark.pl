#!/usr/bin/env perl

use strict;
use warnings;
use 5.010;
use Benchmark qw/cmpthese/;

my @names = qw/david connie kirsten mark/;

sub is_member_h
{
    my ($try) = @_;
    my %names = map { $_ => 1 } @names;
    return $names{$try};
}

sub is_member_g
{
    my ($try) = @_;
    return !!grep { $try eq $_ } @names;
}

cmpthese( -2, {
        find_h => sub {
            my $out;
            $out = is_member_h( 'david' ) foreach 0..1000;
        },
        find_g => sub {
            my $out;
            $out = is_member_g( 'david' ) foreach 0..1000;
        },
        miss_h => sub {
            my $out;
            $out = is_member_h( 'wade' ) foreach 0..1000;
        },
        miss_g => sub {
            my $out;
            $out = is_member_g( 'wade' ) foreach 0..1000;
        },
    });
