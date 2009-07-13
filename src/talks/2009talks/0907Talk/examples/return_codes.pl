#!/usr/bin/env perl

use strict;
use warnings;
use Commands;

while(<>)
{
    chomp;
    next unless /\S/;
    output( $data_out );
}

sub process_line
{
    my $line = shift;
    my $command = parse_command( $line );
    return exec_command( $command );
}

sub parse_command
{
    my $line = shift;
    return unless /(\w+))\s*[=:]\s*(\w+),\s*(\w+),\s*(\w+)/;
    return { name => $1, cmd => $2, args => [ $3, $4 ] };
}

sub exec_command
{
    my $command = shift;
    return unless Command::is_valid( $command->{cmd} );
    my $data = Command::do_cmd( $command->{cmd}, $command->{args} );
    return { %{$data}, name => $command->{name} };
}

sub output
{
    my $data = shift;
    open my $fh, '>>', 'output.log' or die "Unable to open log: $!\n";
    print $fh "$data->{name}:\n\t$data->{output}\n";
    close $fh;
}
