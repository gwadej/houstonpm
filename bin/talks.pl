#!/usr/bin/env perl

use XML::LibXML;
use XML::LibXSLT;
use Getopt::Long;
use Template;

use strict;
use warnings;

use constant START_YEAR => 2003;
use constant END_YEAR => ( ( localtime )[5] + 1900 );

my $StyleSheet;
my $template;

my %params;

GetOptions(
    'stylesheet=s' => \$StyleSheet,
    'template=s'   => \$template,
    'define=s'     => \%params
) or die "Invalid option\n";

my $TalksFile = shift;
die "Missing talks data file\n" unless $TalksFile;
die "Missing stylesheet\n"      unless $StyleSheet;
die "Missing template\n"        unless $template;

$params{year2} = $params{year} % 100 if $params{year};

my $parser = XML::LibXML->new();
my $xslt   = XML::LibXSLT->new();

my $source    = $parser->parse_file( $TalksFile );
my $style_doc = $parser->parse_file( $StyleSheet );

my $stylesheet = $xslt->parse_stylesheet( $style_doc );

my $results = $stylesheet->transform( $source, %params );
$results = $stylesheet->output_string( $results );

my $tt = Template->new(
    {
        INCLUDE_PATH => './templates',
        INTERPOLATE  => 0,
        POST_CHOMP   => 0,
        EVAL_PERL    => 0
    }
);
my $vars = {
    content => $results,
    %params,
    end_year => END_YEAR,
};
$tt->process( $template, $vars ) or die $tt->error(), "\n";
#if( $template )
#{
#    $template =~ s/\{\{content\}\}/$results/ms;
#    $template =~ s/\{\{year\}\}/$params{year}/gms;
#    $template =~ s/\{\{yearmenucurr\}\}/makeYearLinks( $params{year} )/gems;
#    $template =~ s/\{\{yearmenu\}\}/makeYearLinks( 0 )/gems;
#}
#else
#{
#    $template = $results;
#}
#
#print $template;

#
#  Load the template file contents from disk.
sub loadTemplate
{
    my $file = shift;
    local $/ = undef;

    open( my $fh, $file ) or die "Unable to open '$file': $!";
    my $content = <$fh>;
    close( $fh ) or die "Unable to close '$file': $!";

    $content;
}

sub makeYearLinks
{
    my $curryear = shift;
    my $output   = "";

    foreach my $year ( reverse START_YEAR .. END_YEAR )
    {
        next unless -d "src/talks/${year}talks";

        # start with the indent.
        $output .= "     ";

        # open list item
        $output .= $curryear == $year ? q{<li class="curr">} : q{<li>};

        # finish the link
        $output .= qq{<a href="/talks/$year} . qq{talks/index.html">$year</a></li>\n};
    }

    $output;
}
