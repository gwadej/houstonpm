#!/usr/bin/env perl

use strict;
use warnings;
use 5.010;
use Benchmark qw/cmpthese/;
use List::Util qw/any all/;

my @required = qw/command arg option dir length width speed thickness fan perimeter infill/;
my %valid_args   = map { $_ => 1 } @required;
my %invalid_args = %valid_args;
delete @invalid_args{qw/perimeter infill/};

cmpthese( -2, {
        foreach_miss   => sub { my $dummy = foreach_missing( \%invalid_args ); },
        foreach_nomiss => sub { my $dummy = foreach_missing( \%valid_args ); },
        grep_miss      => sub { my $dummy = grep_missing( \%invalid_args ); },
        grep_nomiss    => sub { my $dummy = grep_missing( \%valid_args ); },
        any_miss       => sub { my $dummy = any_missing( \%invalid_args ); },
        any_nomiss     => sub { my $dummy = any_missing( \%valid_args ); },
        all_miss       => sub { my $dummy = all_missing( \%invalid_args ); },
        all_nomiss     => sub { my $dummy = all_missing( \%valid_args ); },
    });

sub foreach_missing
{
    my ($args) = @_;
    foreach my $f ( @required )
    {
        return 0 unless exists $args->{$f}
    }
    return 1;
}

sub grep_missing
{
    my ($args) = @_;
    return 0 != grep { !exists $args->{$_} } @required;
}

sub any_missing
{
    my ($args) = @_;
    return any { !exists $args->{$_} } @required;
}

sub all_missing
{
    my ($args) = @_;
    return !all { exists $args->{$_} } @required;
}
