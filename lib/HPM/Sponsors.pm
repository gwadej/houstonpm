package HPM::Sponsors;

use warnings;
use strict;
use 5.010;

our $VERSION = '0.10';

my @SPONSORS = (
    {
        familiar => 'cPanel',
        full_name => 'cPanel, L.L.C',
        address => '2550 North Loop West, Suite 4006',
        map => 'https://www.google.com/maps/place/2550+N+Loop+W,+Houston,+TX+77092/@29.8081429,-95.4459714,17z/data=!3m1!4b1!4m2!3m1!1s0x8640c6fa4d91297b:0x988e2dedf77ce147',
    },
    {
        familiar => 'Hostgator',
        full_name => 'Hostgator, LLC',
        address => '5005 Mitchelldale St., Suite 100',
        map => 'https://maps.google.com/maps?q=Hostgator,+Houston&fb=1&gl=us&hq=HostGator,&hnear=0x8640b8b4488d8501:0xca0d02def365053b,Houston,+TX&cid=2141572779937723859&t=h&z=16&iwloc=A',
    },
);

sub list
{
    return map { $_->{familiar} } @SPONSORS;
}

sub lookup
{
    my ($key) = @_;
    my ($sp) = grep { $_->{familiar} eq $key } @SPONSORS;
    return unless $sp;
    return { %{$sp} };
}

sub by_month
{
    my ($mon) = @_;
    return if !defined $mon || $mon < 1 || 12 < $mon;
    return ($SPONSORS[($mon - 1) & 1]->{familiar});
}

1;
__END__

=head1 NAME

HPM::Sponsors - [One line description of module's purpose here]


=head1 VERSION

This document describes HPM::Sponsors version 0.10

=head1 SYNOPSIS

    use HPM::Sponsors;

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

HPM::Sponsors requires no configuration files or environment variables.

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

