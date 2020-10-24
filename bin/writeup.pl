#!/usr/bin/env perl

use strict;
use warnings;
use 5.018;

use autodie;
use lib 'lib';
use File::Path qw(mkpath);
use Template;
use IO::Prompter;
use DateTime;
use HPM::Atom;
use HPM::Sponsors;
use JSON::XS;
use File::Slurp;
use Text::MultiMarkdown;

my $talksdir = 'src/talks';

my $dt = DateTime->new( time_zone => 'local' );

my $mon = $dt->month();
$dt->set_month( 0+prompt( -integer => sub { 1 <= $_ && $_ <= 12 }, -def => $mon, "Month [$mon]:" ) );
my $year = $dt->year();
$dt->set_year( 0+prompt( -integer => sub { 2010 <= $_ && $_ <= $year }, -def => $year, "Year [$year]:" ) );
my $author = prompt( "Author:" );
my $title  = prompt( "Title:" );
my $attendees = prompt( -integer => sub { 0 < $_ }, "How many attendees? " );
my $abstract = prompt_long_text( 'Enter an abstract for the presentation (no <p/> needed):' );
my $write_up = prompt_long_text( 'Enter a review of the meeting (no <p/> needed):' );
my $sponsor  = prompt( "Sponsor:", -1, -menu => [ HPM::Sponsors::list() ] );
chomp( $abstract, $write_up );

die "Missing required parameter.\n"
    unless defined $mon && defined $year && $author && $title && $attendees && $abstract && $sponsor;

# Identity transforms below to remove IO::Prompter special objects.
my %vars = (
    mon => sprintf( '%02d', $mon ),
    monthname => $dt->month_name(),
    year => $dt->year(),
    yr => $dt->year() % 100,
    author => $author.'',
    title => $title.'',
    attendees => $attendees+0,
    abstract => $abstract.'',
    sponsor => HPM::Sponsors::lookup( $sponsor.'' ),
    writeup => $write_up,
);

#write_file( $savefile, encode_json \%vars );

add_talk_entry( \%vars );
make_talk_dir( \%vars );
add_feed_entry( \%vars );

say <<EOM;

Don't forget:

 * fill in the rest of $vars{indexfile}
 * add the presentation content
 * update "What's New" on the index page
 * remove entry from upcoming meetings page
EOM

#unlink $savefile;
remove_tempfiles();
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

    my %vars = (
        year => $year,
        yearlist => [ 2003..$year ],
    );
    mkpath( "$talksdir/${year}talks" );
    my $tt = Template->new( INCLUDE_PATH => 'templates' );
    $tt->process( 'Makefile.tt2', \%vars, 'Makefile' )
        or die "Unable to create Makefile: " . $tt->error() . "\n";
    return;
}

sub make_talk_dir
{
    my ($vars) = @_;

    new_year( $vars->{year} ) unless -d "$talksdir/$vars->{year}talks";

    my $dir = "$talksdir/$vars->{year}talks/$vars->{yr}$vars->{mon}Talk";
    die "Talk directory already exists.\n" if -e $dir;

    my $m = Text::MultiMarkdown->new(
        use_metadata => 1,
        document_format => '',
        use_wikilinks => 0,
    );

    mkpath( $dir );
    open my $fh, '>', "$dir/index.tt2" or die "Unable to create new talk writeup.\n";
    print {$fh} <<"EOF";
[% WRAPPER writeup_wrap.tt2
    title='Summary of $vars->{monthname} $vars->{year} Presentation'
    year=$vars->{year}
%]
      <h1>[% "$vars->{title}" | html %]</h1>
EOF

    print {$fh} $m->markdown( $vars->{writeup} );

    if($vars->{sponsor}->{full_name} ne 'Zoom')
    {
        print {$fh} <<"EOT";
      <p>We had $vars->{attendees} people attending this month. As always, we'd like to thank
        $vars->{sponsor}->{full_name} for providing the meeting space and food for the group.</p>
[% END -%]
EOT
    }
    else
    {
        print {$fh} <<"EOT";
      <p>We had $vars->{attendees} people attending the remote meeting this month.</p>
[% END -%]
EOT
    }

    close $fh or die "Unable to close index.tt2\n";

    $vars->{indexfile} = "$dir/index.tt2";
    return;
}

sub add_feed_entry
{
    my ($vars) = @_;
    my $atom = HPM::Atom->load_entries( 'atom_entries.json' );
    $atom->new_entry({
        title => qq[Notes for '$vars->{title}' posted.],
        link => qq[http://houston.pm.org/talks/$vars->{year}talks/$vars->{yr}$vars->{mon}Talk/index.html],
        id => qq[tag:houston.pm.org,2011-03:presentation:$vars->{yr}$vars->{mon}],
        content => { type => 'xhtml', content => qq[<p>$vars->{abstract}</p>] },
        categories => ['presentation', 'technical meeting'],
    });
    $atom->save_entries();
    $atom->write_atom( 'atom.xml' );
    return;
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
            write_file( $tmpfile, "<!-- $prompt -->" ) unless -f $tmpfile;
            system 'vim', '-i', 'NONE', $tmpfile;
            $output = read_file( $tmpfile ) if -s $tmpfile ne 2+length $prompt;
            $output =~ s{^<!--.*?-->\n}{}smg;
        } while( (0 == length $output) && prompt 'Content is empty, retry?', '-y' );

        return $output;
    }

    sub remove_tempfiles {
        unlink grep { -f $_ } map { get_tempfile_name( $_ ) } 0 .. $count-1;
        return;
    }
}
