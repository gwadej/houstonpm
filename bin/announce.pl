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

my $now = strftime( '%Y-%m-%dT%H:%M:%SZ', gmtime );
my $new_entry = {
    title => ''.scalar prompt( 'Entry Title: '),
    id => 'tag:houston.pm.org.2011-03:'.scalar prompt( -def => sprintf('announce-%04d%02d%02d-%d',$yr,$mon,$day,$$), 'Sub-ID: [enter for default]', ),
    content => '<div>'.prompt_long_text( 'Enter msg in valid xhtml:' ).'</div>',
    published => $now,
    updated => $now,
    get_categories(),
};

unshift @{$entries}, $new_entry;

write_file( $savefile, encode_json $entries );

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
remove_tempfiles();
exit;


sub get_categories {
    return
        grep { /\S/ } map { s/\s*#.*//; s/^\s+//; s/\s+$//; }
        split /\n/, prompt_long_text( <<"EOM" );
Enter categories, one per line. Or uncomment ones you wish to use.
#meeting
#technical
#social
EOM
}

BEGIN {
    my $count = 0;
    sub get_tempfile_name {
        return '.textarea.' . shift() . '.tmp';
    }
    sub prompt_long_text
    {
        my ($prompt) = @_;
        my $output;
        do {
            my $tmpfile = get_tempfile_name( $count++ );
            write_file( $tmpfile, "# $prompt" ) unless -f $tmpfile;
            system 'vim', '-i', 'NONE', $tmpfile;
            $output = read_file( $tmpfile ) if -s $tmpfile ne 2+length $prompt;
            $output =~ s/^#.*?\n//smg;
        } while( 0 == length $output && prompt 'Content is empty, retry?', '-y' );

        return $output;
    }

    sub remove_tempfiles {
        unlink grep { -f $_ } map { get_tempfile_name( $_ ) } 0 .. $count-1;
    }
}

