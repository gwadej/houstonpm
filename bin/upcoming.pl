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
$upc->normalize();

my $tt = Template->new( INCLUDE_PATH => 'generated:templates' )
    or die Template->error(), "\n";

if($command eq 'template')
{
    generate_upcoming_list( $tt, $upc );
    generate_next_meeting( $tt, $upc );
    generate_announce( $tt, $upc );
}
else
{
    say "Invalid command: Only template supported";
    exit
}
$upc->save();

sub generate_upcoming_list
{
    my ($tt, $upc) = @_;
    my $template = <<"EOT";
    <dl>
[%- FOREACH entry IN entries %]
        <dt><time datetime="[% entry.datetime %]">[% entry.human_date %]</time></dt>
    [%- IF entry.title %]
        <dd><em>[% entry.title %]</em> with [% entry.presenter %] [% IF entry.is_remote %] on Zoom [% ELSE %] at [% entry.location %] [% END %]</dd>
    [%- ELSE %]
        <dd>TBD [% IF entry.is_remote %] on Zoom [% ELSE %] at [% entry.location %] [% END %]</dd>
    [%- END %]
[% END %]
    </dl>
EOT
    my $entries = $upc->for_template();
    $tt->process( \$template, { entries => $entries }, 'generated/upcoming.tt2' )
        or die $tt->error(), "\n";
    return;
}

sub generate_next_meeting
{
    my ($tt, $upc) = @_;
    my $template = <<"EOT";
      <dl>
[% entry = entries.0 -%]
        <dt><time datetime="[% entry.datetime %]">[% entry.human_date %]</time></dt>
[%- IF entry.abstract %]
        <dd><a href="announce_meeting.html" target="_blank" rel="noopener"><em>[% entry.title %]</em></a> with [% entry.presenter %] [% IF entry.is_remote %]on Zoom[% ELSE %]at [% entry.location %][% END %]</dd>
[%- ELSIF entry.title %]
        <dd><em>[% entry.title %]</em> with [% entry.presenter %] [% IF entry.is_remote %]on Zoom[% ELSE %]at [% entry.location %][% END %]</dd>
[%- ELSE %]
        <dd>TBD at [% entry.location %]</dd>
[%- END %]
      </dl>
EOT
    my $entries = $upc->for_template();
    $tt->process( \$template, { entries => $entries }, 'generated/next_meeting.tt2' )
        or die $tt->error(), "\n";
    return;
}

sub generate_announce
{
    my ($tt, $upc) = @_;
    my $template = <<"EOT";
[%- entry = entries.0 -%]
[% "[" _ "% INCLUDE " %][% entry.location %] month="[%entry.month%]" date="[%entry.human_day%]" datetime="[%entry.datetime%]" [% "%" _ "]" %]
    <p>This month, [% entry.presenter %] will present <em>[% entry.title %]</em>.</p>

[% entry.abstract -%]
EOT
    my $entries = $upc->for_template();
    $tt->process( \$template, { entries => $entries }, 'generated/announce.tt2' )
        or die $tt->error(), "\n";
    return;
}
