package HPM::Atom;

use warnings;
use strict;
use 5.010;

use autodie;
use File::Slurp;
use JSON::XS;
use POSIX qw(strftime);
use XML::Atom::SimpleFeed;
use XML::LibXML;

our $VERSION = '0.10';

my @RECOGNIZED = qw/title id content link category categories/;
my @REQUIRED = qw/title id content/;

sub load_entries
{
    my ($class, $file) = @_;
    $file ||= 'atom_entries.json';

    my $entries =
        -f $file ? JSON::XS->new->decode( scalar read_file $file )
                 : [];

    return bless {
        filename => $file,
        entries => $entries,
    }, $class;
}

sub save_entries
{
    my ($self) = @_;
    write_file(
        $self->{filename},
        JSON::XS->new->pretty(1)->encode( $self->{entries} )
    );
    return;
}

sub new_entry
{
    my ($self, $entry) = @_;
    foreach my $field (keys %{$entry})
    {
        die "'$field' is not a recognized field\n" unless grep { $_ eq $field } @RECOGNIZED;
    }
    foreach my $field (@REQUIRED)
    {
        die "Missing required '$field' field\n" unless defined $entry->{$field};
    }

    my $now = strftime( '%Y-%m-%dT%H:%M:%SZ', gmtime );
    unshift @{$self->{entries}}, {
        %{$entry},
        published => $now,
        updated => $now,
    };
    $self->{entries} = [ @{$self->{entries}}[0..19] ];
    return;
}

sub write_atom
{
    my ($self, $file) = @_;
    $file ||= 'atom.xml';

    my $feed = XML::Atom::SimpleFeed->new(
        id => qq[tag:houston.pm.org,2011-03:news],
        title => qq[Houston.pm: What's New],
        link => 'http://houston.pm.org/',
        link => { rel => 'self', href => 'http://houston.pm.org/atom.xml' },
        updated => strftime( '%Y-%m-%dT%H:%M:%SZ', gmtime ),
        author => 'G. Wade Johnson',
        category => 'news',
    );

    foreach my $entry ( @{$self->{entries}} )
    {
        $feed->add_entry( _entry_to_atom( $entry ) );
    }

    write_file( $file, pretty_xml( $feed->as_string ));
    return;
}

sub pretty_xml
{
    my ($xml) = @_;
    return XML::LibXML->load_xml( string => $xml )->toString(1);
}

sub _entry_to_atom
{
    my ($entry) = @_;

    my @atom_entry = map { $_ => $entry->{$_} } @REQUIRED;
    push @atom_entry, category => $entry->{category} if defined $entry->{category};
    push @atom_entry, link => $entry->{link} if defined $entry->{link};
    push @atom_entry, (map { (category => $_) } @{$entry->{categories} || []});
    return @atom_entry;
}

1;
__END__

=head1 NAME

HPM::Atom - [One line description of module's purpose here]


=head1 VERSION

This document describes HPM::Atom version 0.10

=head1 SYNOPSIS

    use HPM::Atom;

=for author to fill in:
    Brief code example(s) here showing commonest usage(s).
    This section will be as far as many users bother reading
    so make it as educational and exeplary as possible.

=head1 DESCRIPTION

=for author to fill in:
    Write a full description of the module and its features here.
    Use subsections (=head2, =head3) as appropriate.

=head1 INTERFACE

=for author to fill in:
    Write a separate section listing the public components of the modules
    interface. These normally consist of either subroutines that may be
    exported, or methods that may be called on objects belonging to the
    classes provided by the module.

=head1 CONFIGURATION AND ENVIRONMENT

HPM::Atom requires no configuration files or environment variables.

=head1 DEPENDENCIES

None.

=head1 INCOMPATIBILITIES

None reported.

=head1 BUGS AND LIMITATIONS

No bugs have been reported.

Please report any bugs or feature requests to
C<bug-<RT NAME>@rt.cpan.org>, or through the web interface at
L<http://rt.cpan.org>.

=head1 AUTHOR

G. Wade Johnson  C<< gwadej@cpan.org >>

=head1 LICENCE AND COPYRIGHT

Copyright (c) <YEAR>, G. Wade Johnson C<< gwadej@cpan.org >>. All rights reserved.

This module is free software; you can redistribute it and/or
modify it under the same terms as Perl itself. See L<perlartistic>.

=head1 DISCLAIMER OF WARRANTY

BECAUSE THIS SOFTWARE IS LICENSED FREE OF CHARGE, THERE IS NO WARRANTY
FOR THE SOFTWARE, TO THE EXTENT PERMITTED BY APPLICABLE LAW. EXCEPT WHEN
OTHERWISE STATED IN WRITING THE COPYRIGHT HOLDERS AND/OR OTHER PARTIES
PROVIDE THE SOFTWARE "AS IS" WITHOUT WARRANTY OF ANY KIND, EITHER
EXPRESSED OR IMPLIED, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE. THE
ENTIRE RISK AS TO THE QUALITY AND PERFORMANCE OF THE SOFTWARE IS WITH
YOU. SHOULD THE SOFTWARE PROVE DEFECTIVE, YOU ASSUME THE COST OF ALL
NECESSARY SERVICING, REPAIR, OR CORRECTION.

IN NO EVENT UNLESS REQUIRED BY APPLICABLE LAW OR AGREED TO IN WRITING
WILL ANY COPYRIGHT HOLDER, OR ANY OTHER PARTY WHO MAY MODIFY AND/OR
REDISTRIBUTE THE SOFTWARE AS PERMITTED BY THE ABOVE LICENCE, BE
LIABLE TO YOU FOR DAMAGES, INCLUDING ANY GENERAL, SPECIAL, INCIDENTAL,
OR CONSEQUENTIAL DAMAGES ARISING OUT OF THE USE OR INABILITY TO USE
THE SOFTWARE (INCLUDING BUT NOT LIMITED TO LOSS OF DATA OR DATA BEING
RENDERED INACCURATE OR LOSSES SUSTAINED BY YOU OR THIRD PARTIES OR A
FAILURE OF THE SOFTWARE TO OPERATE WITH ANY OTHER SOFTWARE), EVEN IF
SUCH HOLDER OR OTHER PARTY HAS BEEN ADVISED OF THE POSSIBILITY OF
SUCH DAMAGES.

