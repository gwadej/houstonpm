#!/usr/bin/env perl

use strict;
use warnings;
use 5.010;

use autodie;
use Template;
use IO::Prompter;
use JSON::XS;
use XML::Atom::SimpleFeed;
use File::Slurp;
use POSIX qw(strftime);

my $savefile = 'atom_entries.json';
my ($day, $mon, $yr) = (localtime)[3,4,5];
++$mon;
$yr += 1900;

my $entries = [];
$entries = decode_json scalar read_file $savefile if -f $savefile;

my $feed = XML::Atom::SimpleFeed->new(
    id => qq[tag:houston.pm.org,2011-03:news],
    title => qq[Houston.pm: What's New],
    link => 'http://houston.pm.org/',
    link => { rel => 'self', href => 'http://houston.pm.org/atom.xml' },
    updated => strftime( '%Y-%m-%dT%H:%M:%SZ', gmtime ),
    author => 'G. Wade Johnson',
    category => 'news',
);

foreach my $entry ( @{$entries} )
{
    $feed->add_entry( %{ $entry } );
}

write_file( 'atom.xml', $feed->as_string );
exit;

