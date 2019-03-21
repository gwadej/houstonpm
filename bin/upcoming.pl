#!/usr/bin/env perl

use strict;
use warnings;
use 5.018;

use autodie;
use FindBin;
use lib "$FindBin::Bin/../lib";

use DateTime;
use Template;
use IO::Prompter;
use HPM::Date;
use HPM::Sponsors;
use HPM::Upcoming;
use File::Slurp;

my $command = shift;

my $file = 'upcoming_talks.json';
my $upc = HPM::Upcoming->load( $file );

if($command eq 'template')
{
    generate_upcoming_list( $upc );
}
else
{
    say "Invalid command: Only template supported";
    exit
}
$upc->save();

sub generate_upcoming_list
{
    my ($upc) = @_;
    my $tt = Template->new( INCLUDE_PATH => 'templates' )
        or die Template->error(), "\n";
    my $template = <<"EOT";
    <dl>
[%- FOREACH entry IN entries %]
        <dt><time datetime="[% entry.datetime %]">[% entry.human_date %]</time></dt>
    [%- IF entry.title %]
        <dd><em>[% entry.title %]</em> with [% entry.presenter %] at [% entry.location %]</dd>
    [%- ELSE %]
        <dd>TBD at [% entry.location %]</dd>
    [%- END %]
[% END %]
    </dl>
EOT
    my $entries = $upc->for_template();
    $tt->process( \$template, { entries => $entries }, 'templates/upcoming.tt2' )
        or die $tt->error(), "\n";
    return;
}
