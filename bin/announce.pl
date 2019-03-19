#!/usr/bin/env perl

use strict;
use warnings;
use 5.010;

use autodie;
use lib 'lib';
use Template;
use IO::Prompter;
use HPM::Atom;
use HPM::Date;
use HPM::Sponsors;
use File::Slurp;

my $tt = Template->new( INCLUDE_PATH => 'templates', TRIM => 1 )
    or die Template->error(), "\n";

my $atom = HPM::Atom->load_entries(  'atom_entries.json' );

my $vars = query_user();

my $details;
$tt->process( 'atom_details.tt2', $vars, \$details )
    or die $tt->error(), "\n";

$details = prompt_long_text( 'Update the meeting details in valid xhtml:', $details );
my $abstract = prompt_long_text( 'Enter meeting abstract in valid xhtml:' );
$atom->new_entry({
    title      => $vars->{title},
    id         => "tag:houston.pm.org.2011-03:$vars->{subid}",
    content    => join( "\n", grep { $_ } $details, $abstract ),
    categories => $vars->{categories},
});

$atom->save_entries();
$atom->write_atom( 'atom.xml' );

twitter_announce( $vars );

remove_tempfiles();
exit;

sub twitter_announce
{
    my ($vars) = @_;

    my $tweet;
    $tt->process( 'tweet.tt2', $vars, \$tweet )
        or die $tt->error(), "\n";
    $tweet = prompt_long_text( 'Modify tweet:', $tweet );
    if(length $tweet == 0)
    {
        print "Not sending empty tweet\n";
        return;
    }
    $tweet =~ tr/\n/ /s;
    send_tweet( $tweet );

    return;
}

sub send_tweet
{
    my ($tweet) = @_;

    my $err = system 'twurl', '-d', "status=$tweet", '/1.1/statuses/update.json';
    return unless $err;
    die "failed to execute 'twurl': $!\n" if $? == -1;
    if ($? & 127)
    {
        die sprintf "'twurl' died with signal %d, %s coredump\n",
            ($? & 127),  ($? & 128) ? 'with' : 'without';
    }
    die sprintf "'twurl' exited with value %d\n", $? >> 8;
}

sub get_categories
{
    return
        grep { /\S/ } map { s/\s*#.*//; s/^\s+//; s/\s+$//; $_ }
        split /\n/, prompt_long_text( <<"EOM" );
Enter categories, one per line. Or uncomment ones you wish to use.
#technical
#social
meeting
EOM
}

sub process_to_str
{
    my ($tt, $template, $vars) = @_;

}

sub query_user
{
    my ($yr, $mon, $day) = HPM::Date::today_parts();

    # Identity transforms below to remove IO::Prompter special objects.
    my $subid = prompt( -def => sprintf('announce-%04d%02d%02d-%d',$yr,$mon,$day,$$), 'Sub-ID: [enter for default]', );
    my $title = prompt( 'Entry Title: ');
    my $presenter = prompt( 'Presenter: ' );
    $mon = prompt( -integer => sub { 1 <= $_ && $_ <= 12 }, -def => $mon, "Month [$mon]:" );
    $day = HPM::Date::meeting_day( $mon );
    $day = prompt( -integer => sub { 1 <= $_ && $_ <= 31 }, -def => $day, "Day [$day]:" );
    my $sponsor = prompt( "Sponsor:", -1, -menu => [ HPM::Sponsors::list() ] );

    my $month = HPM::Date::month_name( $mon );
    return {
        subid => '' . $subid,
        title => '' . $title,
        presenter => '' . $presenter,
        mon => 0 + $mon,
        month => $month,
        date => "$month $day",
        sponsor => HPM::Sponsors::lookup( '' . $sponsor ),
        categories => [get_categories()],
    };
}

BEGIN {
    my $count = 0;
    sub get_tempfile_name {
        return '.textarea.' . shift() . '.tmp';
    }
    sub prompt_long_text
    {
        my ($prompt, $default) = @_;
        $default = $default ? "\n$default" : '';
        my $output;
        do {
            my $tmpfile = get_tempfile_name( $count++ );
            write_file( $tmpfile, "# $prompt$default" ) unless -f $tmpfile;
            system 'vim', '-i', 'NONE', $tmpfile;
            $output = read_file( $tmpfile );
            $output =~ s/^#.*?\n//sg;
        } while( 0 == length $output && prompt 'Content is empty, retry?', '-y' );

        return $output;
    }

    sub remove_tempfiles {
        return unlink grep { -f $_ } map { get_tempfile_name( $_ ) } 0 .. $count-1;
    }
}

