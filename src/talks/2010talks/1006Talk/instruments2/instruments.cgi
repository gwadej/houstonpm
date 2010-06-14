#!/usr/bin/env perl

use strict;
use warnings;
use CGI;

use JSON::Syck;

my @gauges = (
    { name => 'bargauge1', code => sub { return gauge( 0, 100 ); }, },
    { name => 'bargauge2', code => sub { return gauge( 0, 100 ); }, },
    { name => 'bargauge3', code => sub { return over_gauge( 0, 100 ); }, },
    { name => 'bargauge4', code => sub { return gauge( 0, 100 ); }, },
    { name => 'bargauge5', code => sub { return gauge( 0, 100 ); }, },
    { name => 'dial1',     code => sub { return gauge( 0, 100 ); }, },
    { name => 'dial2',     code => sub { return gauge( 0, 100 ); }, },
    { name => 'dial3',     code => sub { return gauge( 0, 100 ); }, },
    { name => 'dial4',     code => sub { return gauge( 0, 100 ); }, },
    { name => 'dial5',     code => sub { return sprintf '%.04f', rand() * 100; }, },
    { name => 'lamp1',     code => sub { return gauge( 0, 2 ); }, },
    { name => 'lamp2',     code => sub { return gauge( 0, 2 ); }, },
    { name => 'lamp3',     code => sub { return gauge( 0, 2 ); }, },
    { name => 'lamp4',     code => sub { return gauge( 0, 2 ); }, },
    { name => 'lamp5',     code => sub { return gauge( 0, 2 ); }, },
    { name => 'readout1',  code => sub { return gauge( 0, 9999 ); }, },
    { name => 'readout2',  code => sub { return gauge( -999, 1999 ); }, },
    { name => 'readout3',  code => sub { return gauge( -999, 1999 ); }, },
	{ name => 'chart1',    code => sub { return gauge( -20, 40 ); }, },
    { name => 'chart2',    code => sub { return gauge( 0, 100 ); }, },
    { name => 'chart3',    code => sub { return gauge( 0, 40 ); }, },
    { name => 'chart4',    code => sub { return gauge( 0, 40 ); }, },
    { name => 'chart5',    code => sub { return gauge( -50, 100 ); }, },
);

my $q = CGI->new;

print $q->header( 'application/json' ),
      JSON::Syck::Dump( make_response() );


sub make_response {
    my %response;

    foreach my $e ( @gauges )
    {
        next if rand > 0.8;
        $response{$e->{name}} = $e->{code}->();
    }

    return \%response;
}

sub over_gauge {
    my ($min, $range) = @_;
    return sprintf '%.04f', $min + $range * rand() * 1.1;
}
sub gauge {
    my ($min, $range) = @_;
    return sprintf '%.04f', $min + $range * rand;
}

