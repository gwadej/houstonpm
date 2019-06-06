package HPM::Date;

use warnings;
use strict;
use 5.010;

use Time::Local qw/timelocal/;
use DateTime;

our $VERSION = '0.10';

sub today
{
    return DateTime->today( time_zone => 'local' )->ymd( '' );
}

# Find the second Thursday of the specified month
sub meeting_day
{
    my ($mon, $year) = @_;
    my $dt = DateTime->new( year => $year, month => $mon, day => 8, time_zone => 'local' );
    return dt_meeting_day( $dt )->day();
}

sub dt_meeting_day
{
    my ($dt) = @_;
    $dt->set_day( 8 );
    my $wday = $dt->day_of_week();
    $wday = (11 - $wday) % 7;  # Find offset to Thursday after the 8th
    return $dt->add( days => $wday );
}

sub next_meeting
{
    my ($date) = @_;
    die "Missing required date field\n" unless defined $date;
    my $dt = datetime_from( $date );
    return next_meeting_dt( $dt )->ymd( '' );
}

sub next_meeting_dt
{
    my ($dt) = @_;
    return $dt->add( months => 1 )->set_day( meeting_day( $dt->month(), $dt->year() ) );
}

sub datetime_from
{
    my ($date) = @_;
    my ($y, $m, $d) = $date =~ /\A(\d\d\d\d)(\d\d)(\d\d)\z/;
    return DateTime->new( year => $y, month => $m, day => $d, time_zone => 'local' );
}

1;
__END__

=head1 NAME

HPM::Date - [One line description of module's purpose here]


=head1 VERSION

This document describes HPM::Date version 0.10

=head1 SYNOPSIS

    use HPM::Date;

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

HPM::Date requires no configuration files or environment variables.

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

