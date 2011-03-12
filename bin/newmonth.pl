#!/usr/bin/env perl

use strict;
use warnings;
use 5.010;

use File::Path qw(mkpath);
use autodie;
use Template;
use IO::Prompter;

my @months = ( '', 'January', 'February', 'March', 'April', 'May', 'June',
    'July', 'August', 'September', 'October', 'November', 'December' );
my $talksdir = 'src/talks';

my ($mon, $year) = (localtime)[4,5];
++$mon;
$year += 1900;

$mon = prompt( -integer => sub { 1 <= $_ && $_ <= 12 }, -def => $mon, "Month [$mon]:" );
$year = prompt( -integer => sub { 2010 <= $_ && $_ <= $year }, -def => $year, "Year [$year]:" );
my $author = prompt( "Author:" );
my $title  = prompt( "Title:" );
my $attendees = prompt( -integer => sub { 0 < $_ }, "How many attendees? " );

die "Missing required parameter.\n"
    unless defined $mon && defined $year && $author && $title && $attendees;

# Identity transforms below to remove IO::Prompter special objects.
my %vars = (
    mon => sprintf( '%02d', $mon ),
    monthname => $months[$mon],
    year => $year+0,
    yr => substr( $year, 2 ),
    author => $author.'',
    title => $title.'',
    attendees => $attendees+0,
);

add_talk_entry( \%vars );
make_talk_dir( \%vars );

say <<EOM;

Don't forget:

 * update the abstract in the talks.xml file.
 * fill in the rest of $vars{indexfile}.
 * update "What's New" on the index page.
 * remove entry from upcoming meetings page.
 * add to atom feed?
EOM

exit;

sub add_talk_entry
{
    my ($vars) = @_;
    close ARGV;  # Make IO::Prompter release the file handle
    local @ARGV = ('talks.xml');
    local $^I='';

    while(<>)
    {
        if ( m{</talklist>} )
        {
            my $output = '';
            my $tt = Template->new( INCLUDE_PATH => 'templates' );
            $tt->process( 'talk_entry.tt2', $vars, \$output )
                or die "Unable to build entry: " . $tt->error() . "\n";
            print $output;
        }
        print;
    }
    return;
}

sub new_year
{
    my ($year) = @_;

die "Should not get here yet.\n";
    # Create year directory.
    # Update Makefile
}

sub make_talk_dir
{
    my ($vars) = @_;

    new_year( $vars->{year} ) unless -d "$talksdir/$vars->{year}talks";

    my $dir = "$talksdir/$vars->{year}talks/$vars->{yr}$vars->{mon}Talk";
    die "Talk directory already exists.\n" if -e $dir;

    mkpath( $dir );
    my $tt = Template->new( INCLUDE_PATH => 'templates' );
    $tt->process( 'talk_index.tt2', $vars, "$dir/index.html" )
        or die "Unable to build index " . $tt->error() . "\n";

    $vars->{indexfile} = "$dir/index.html";
    return;
}

