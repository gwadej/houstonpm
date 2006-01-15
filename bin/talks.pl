#!/usr/bin/perl

use XML::LibXML;
use XML::LibXSLT;
use Getopt::Long;

use strict;
use warnings;

use constant START_YEAR => 2003;
use constant END_YEAR => ((localtime)[5]+1900);

my $StyleSheet;
my $TemplateFile;

my %params = ( 'year2' => (END_YEAR % 100) );

GetOptions( 'stylesheet=s' => \$StyleSheet,
            'template=s' => \$TemplateFile,
            'define=s' => \%params
	  )
  or die "Invalid option\n";

my $TalksFile = shift;
die "Missing talks data file\n" unless $TalksFile;
die "Missing stylesheet\n" unless $StyleSheet;

# parameter fixup
$params{year} = "20$params{year2}" unless !exists $params{year2};
$params{year2} = "'$params{year2}'"
    unless !exists $params{year2} or $params{year2} =~ /'/;

my $template = $TemplateFile ? loadTemplate( $TemplateFile ) : undef;

my $parser = XML::LibXML->new();
my $xslt = XML::LibXSLT->new();

my $source = $parser->parse_file( $TalksFile );
my $style_doc = $parser->parse_file( $StyleSheet );

my $stylesheet = $xslt->parse_stylesheet( $style_doc );

my $results = $stylesheet->transform( $source, %params );
$results = $stylesheet->output_string( $results );

if($template)
{
    $template =~ s/\{\{content\}\}/$results/ms;
    $template =~ s/\{\{year\}\}/$params{year}/gms;
    $template =~ s/\{\{yearmenucurr\}\}/makeYearLinks( $params{year} )/gems;
    $template =~ s/\{\{yearmenu\}\}/makeYearLinks( 0 )/gems;
}
else
{
    $template = $results;
}

print $template;


#
#  Load the template file contents from disk.
sub  loadTemplate
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
    my $output = "";

    foreach my $year (reverse START_YEAR .. END_YEAR)
    {
        # start with the indent.
        $output .= "     ";

	# open list item
	$output .= $curryear == $year ? q{<li class="curr">} : q{<li>};

        # finish the link
	$output .= qq{<a href="/talks/$year}
	          . qq{talks/index.html">$year</a></li>\n};
    }

    $output;
}
