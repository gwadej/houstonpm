#!/usr/bin/env perl

use strict;
use warnings;
use 5.018;

use autodie;
use FindBin;
use lib "$FindBin::Bin/../lib";
use Template;
use IO::Prompter;
use HPM::Atom;
use HPM::Date;
use HPM::Sponsors;
use HPM::Upcoming;
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

$vars = { %{$vars}, abstract => $abstract };
update_upcoming( $vars );
display_email( $vars );

remove_tempfiles();
exit;

sub display_email
{
    my ($vars) = @_;

    my $email;
    $tt->process( 'email.tt2', $vars, \$email )
        or die $tt->error(), "\n";
    say $email;

    return;
}

sub update_upcoming
{
    my ($vars) = @_;
    my $file = 'upcoming_talks.json';
    my $upc = HPM::Upcoming->load( $file );
    $upc->normalize();

    my %entry = (
        date      => $vars->{datestamp},
        title     => $vars->{title},
        presenter => $vars->{presenter},
        abstract  => $vars->{abstract},
    );

    $upc->update( %entry );
    $upc->save();
    return;
}

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
    send_tweet( $tweet ) if prompt( 'Send the tweet?: ', -yes );

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
#technical meeting
#social meeting
EOM
}

sub query_user
{
    my $dt = DateTime->today( time_zone => 'local' );

    # Identity transforms below to remove IO::Prompter special objects.
    my $subid = prompt( -def => sprintf('announce-%is-%d', $dt->ymd( '' ), $$), 'Sub-ID: [enter for default]', );
    my $title = prompt( 'Entry Title: ');
    my $presenter = prompt( 'Presenter: ' );

    my $mon = $dt->month();
    $dt->set_month( 0+prompt( -integer => sub { 1 <= $_ && $_ <= 12 }, -def => $mon, "Month [$mon]:" ) );
    $dt = HPM::Date::dt_meeting_day( $dt );
    my $day = $dt->day();
    $dt->set_day( 0+prompt( -integer => sub { 1 <= $_ && $_ <= 31 }, -def => $day, "Day [$day]:" ) );
    my $sponsor = prompt( "Sponsor:", -1, -menu => [ HPM::Sponsors::list() ] );

    my $month = $dt->month_name();
    return {
        subid => '' . $subid,
        title => '' . $title,
        presenter => '' . $presenter,
        mon => $dt->month(),
        month => $month,
        date => $month . ' ' . $dt->day(),
        datestamp => $dt->ymd( '' ),
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

