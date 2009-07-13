#!/usr/bin/env perl

use strict;
use warnings;
use Commands;

while(<>)
{
    chomp;
    next unless /\S/;
    my ($data_out,$msg) = process_line( $_ );
    die "$msg: line $.\n" unless $data_out;
    output( $data_out );
}

sub process_line
{
    my $line = shift;
    my $command = parse_command( $line );
    return ( undef, 'Line not in valid format' ) unless defined $command;

    my $data_out = exec_command( $command );
    return ( undef, "'$command->{cmd}' is not a recognized command" )
        unless defined $data_out;

    return $data_out;
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
    return unless 'HASH' eq ref $command;
    return unless Command::is_valid( $command->{cmd} );
    my $data = Command::do_cmd( $command->{cmd}, $command->{args} );
    return { %{$data}, name => $command->{name} };
}

sub output
{
    my $data = shift;
    open my $fh, '>>', 'output.log' or die "Unable to open log: $!\n";
    print $fh "$data->{name}:\n\t$data->{output}\n"
        or die "Unable to write to log: $!\n";
    close $fh or die "Unable to close log: $!\n";
}
