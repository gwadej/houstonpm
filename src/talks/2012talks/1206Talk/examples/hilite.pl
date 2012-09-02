#!/usr/bin/env perl

use strict;
use warnings;
use autodie;
use 5.010;

use Syntax::Highlight::Engine::Kate::Perl;

my $hl = new Syntax::Highlight::Engine::Kate::Perl(
   substitutions => {
      "<" => "&lt;",
      ">" => "&gt;",
      "&" => "&amp;",
      " " => "&nbsp;",
      "\t" => "&nbsp;&nbsp;&nbsp;",
      "\n" => "<br />\n",
   },
   format_table => {
       map { $_ => [ qq{<span class="$_">}, "</span>" ] }
            qw/Alert BaseN BString Char Comment DataType DecVal Error Float 
            Function IString Keyword Normal Operator Others RegionMarker 
            Reserved String Variable Warning/
   },
);
 
my $filename = $ARGV[0];
my $output = "$filename.html";

open my $fh, '>', $output;

print {$fh} <<EOH;
<html>
<head>
  <title>$filename</title>
  <style type="text/css">
      .Alert { color:#0000ff; }
      .BaseN { color:#007f00; }
      .BString { color:#c9a7ff; }
      .Char { color:#ff00ff; }
      .Comment { color:#7f7f7f; font-style: italic; }
      .DataType { color:darkcyan; }
      .DecVal { color:#00007f; }
      .Error { color:#ff0000; font-style: italic; font-weight: bold; }
      .Float { color:#00007f; }
      .Function { color:#007f00; }
      .IString { color:#ff0000; }
      .Keyword { color: brown; font-weight: bold; }
      .Operator { color:#ffa500; }
      .Others { color:#b03060; }
      .RegionMarker { color:#96b9ff; font-style: italic; }
      .Reserved { color:#9b30ff; font-weight: bold; }
      .String { color:magenta; }
      .Variable { color:#0000ff; font-weight: bold; }
      .Warning { color:#0000ff; font-style: italic; font-weight: bold; }
  </style>
</head>
<body>
EOH

while (my $in = <>) {
   print {$fh} $hl->highlightText($in);
}

print {$fh} "</body>\n</html>\n";
