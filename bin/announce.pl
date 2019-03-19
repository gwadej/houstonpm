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
use File::Slurp;

my $atom = HPM::Atom->load_entries(  'atom_entries.json' );

my ($yr, $mon, $day) = HPM::Date::today_parts();

# Identity transforms below to remove IO::Prompter special objects.
my $subid = ''. prompt( -def => sprintf('announce-%04d%02d%02d-%d',$yr,$mon,$day,$$), 'Sub-ID: [enter for default]', );
my $title = ''. prompt( 'Entry Title: ');
my $presenter = ''. prompt( 'Presenter: ' );
$mon = prompt( -integer => sub { 1 <= $_ && $_ <= 12 }, -def => $mon, "Month [$mon]:" );
$day = HPM::Date::meeting_day( $mon );
$day = prompt( -integer => sub { 1 <= $_ && $_ <= 31 }, -def => $day, "Day [$day]:" );
my $sponsor  = prompt( "Sponsor:", -1, -menu => [ 'cPanel, L.L.C.', 'HostGator, LLC' ] );

my $month = HPM::Date::month_name( $mon );
my $date = "$month $day";
my $content = <<"EOM";
<p>For the $month Houston.pm meeting, $presenter will present <em>$title</em>.
The meeting will start at 6pm on $date at the $sponsor offices.
We begin collecting in the lobby 30 minutes before.</p>
EOM

$content = ''. prompt_long_text( 'Enter msg in valid xhtml:', $content );
$atom->new_entry({
    title      => $title,
    id         => "tag:houston.pm.org.2011-03:$subid",
    content    => $content,
    categories => [get_categories()],
});

$atom->save_entries();
$atom->write_atom( 'atom.xml' );

twitter_announce(
    month => $month,
    date => $date,
    title => $title,
    presenter => $presenter,
    sponsor => $sponsor,
);

remove_tempfiles();
exit;

sub twitter_announce
{
    my %vars = @_;

    my $tweet = <<"EOT";
For the $vars{month} #Houston.pm meeting, $vars{presenter} will present '$vars{title}'.
The meeting will start at 6pm on $vars{date} at the #$vars{sponsor} offices.
We begin collecting in the lobby 30 minutes before.
Check http://houston.pm.org/ for more details.
EOT
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

sub get_categories {
    return
        grep { /\S/ } map { s/\s*#.*//; s/^\s+//; s/\s+$//; $_ }
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

