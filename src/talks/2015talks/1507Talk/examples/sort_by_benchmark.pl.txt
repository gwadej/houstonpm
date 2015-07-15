#!/usr/bin/env perl

use strict;
use warnings;
use 5.010;
use Benchmark qw/cmpthese/;
use List::MoreUtils;

{
    package Person;
    use Moo;
    use namespace::autoclean;
    has name => ( is => 'ro' );
    has age  => ( is => 'ro' );
    sub exp_name
    {
        my ($self) = @_;
        my $dummy = -e '/homedir/' . $self->name;
        return $self->name;
    }
}

my $n = shift || 1024;
my @names = qw/david mark kirsten connie aramis bryan fred bianca/;
my @people =  map { Person->new( name => $_, age => 21 ) }
              map { (@names[rand @names] . int(rand $n) ) } 1..$n;

print "List length: $n\n";

cmpthese( -2, {
        naive => \&naive_sort,
        schwartzian => \&st_sort,
        sort_by => \&sb_sort,
    });

sub naive_sort
{
    my @peeps = sort { $a->exp_name cmp $b->exp_name } @people;
    return @peeps;
}

sub st_sort
{
    my @peeps = map { $_->[1] }
                sort { $a->[0] cmp $a->[0] }
                map { [ $_->exp_name, $_ ] }
                @people;
    return @peeps;
}

sub sb_sort
{
    my @peeps = List::MoreUtils::sort_by { $_->exp_name } @people;
    return @peeps;
}
