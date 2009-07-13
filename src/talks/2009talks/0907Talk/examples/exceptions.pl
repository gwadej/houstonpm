#!/usr/bin/env perl

use strict;
use warnings;
use Commands;

eval {
    while(<>)
    {
        chomp;
        next unless /\S/;
        my $data_out = process_line( $_ );
        output( $data_out );
    }
};
if($@)
{
    my $ex = $@;
    if($ex =~ /^Command: (.*)/)
    {
        print "Command processing error on line $.: $1\n";
    }
    else
    {
        print "Error on line $.: $@";
    }
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
    die "Command: invalid string\n"
        unless /(\w+))\s*[=:]\s*(\w+),\s*(\w+),\s*(\w+)/;
    return { name => $1, cmd => $2, args => [ $3, $4 ] };
}

sub exec_command
{
    my $command = shift;
    die 'Missing command hash' unless 'HASH' eq ref $command;
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
