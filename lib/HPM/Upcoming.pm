package HPM::Upcoming;

use warnings;
use strict;
use 5.018;

our $VERSION = '0.10';

use DateTime;
use File::Slurp;
use HPM::Date;
use HPM::Sponsors;
use JSON::XS;

my @ALLOWED = qw/date title presenter abstract location/;
my $COUNT_ENTRIES = 4;
my $LAST_ENTRY = $COUNT_ENTRIES - 1;

sub load
{
    my ($class, $file) = @_;
    $file //= 'upcoming_talks.json';

    my $entries = -f $file
        ? JSON::XS->new->decode( scalar read_file $file )
        : _init_entries();

    return bless {
        filename => $file,
        entries => $entries,
    }, $class;
}

sub save
{
    my ($self) = @_;
    write_file(
        $self->{filename},
        JSON::XS->new->pretty(1)->canonical(1)->encode( $self->{entries} )
    );
    return;
}

sub normalize
{
    my ($self) = @_;
    my $today = HPM::Date::today();
    if(grep { $today <= $_->{date} && $_->{title} } @{$self->{entries}})
    {
        $self->{entries} = [ grep { $today <= $_->{date} } @{$self->{entries}} ];
        $self->_fill_entries();
    }
}

sub update
{
    my ($self, %vars) = @_;
    my $entry = _create_entry( %vars );
    my $date = $entry->{date};

    my @entries = grep { $_->{date} ne $date } @{$self->{entries}};
    @entries = sort { $a->{date} <=> $b->{date} } @entries, $entry;
    $self->{entries} = [ @entries[0..$LAST_ENTRY] ];

    return;
}

sub by_date
{
    my ($self, $date) = @_;
    my ($entry) = grep { $_->{date} eq $date } @{$self->{entries}};
    # clone
    return { %{$entry} };
}

sub _last_entry
{
    my ($self) = @_;
    return $self->{entries}->[-1];
}

sub _fill_entries
{
    my ($self) = @_;
    while( @{$self->{entries}} < $COUNT_ENTRIES )
    {
        my $date = $self->_last_entry->{date};
        $self->update( date => HPM::Date::next_meeting( $date ) );
    }
    return;
}

sub remove
{
    my ($self) = @_;
    shift @{$self->{entries}};
    $self->_fill_entries();
    return;
}

sub _init_entries
{
    my $meeting = HPM::Date::dt_meeting_day( DateTime->today( time_zone => 'local' ) );
    $meeting = $meeting > DateTime->today( time_zone => 'local' )
                ? $meeting
                : HPM::Date::next_meeting_dt( $meeting );
    my @events;
    foreach (0..$LAST_ENTRY)
    {
        push @events, _create_entry( date => $meeting->ymd( '' ) );
        $meeting = HPM::Date::next_meeting_dt( $meeting );
    }
    return \@events;
}

sub _create_entry
{
    my (%vars) = @_;
    foreach my $f (keys %vars)
    {
        die "Unexpected field '$f'\n" unless grep { $f eq $_ } @ALLOWED;
    }
    die "Missing required date field\n" unless defined $vars{date};
    die "Must have both a title and a presenter or neither\n"
        if($vars{title} xor $vars{presenter});
    die "Abstract only allowed if title is supplied\n"
        if($vars{abstract} and !$vars{title});

    my $mon = substr($vars{date}, 4, 2);
    return {
        date => $vars{date},
        title => $vars{title},
        presenter => $vars{presenter},
        abstract => $vars{abstract},
        location => $vars{location} // HPM::Sponsors::by_month($mon),
    };
}

sub for_template
{
    my ($self) = @_;
    return [ map { _entry_for_template( $_ ) } @{$self->{entries}}[0..3] ];
}

sub _entry_for_template
{
    my ($entry) = @_;
    my $meeting = HPM::Date::datetime_from( $entry->{date} );
    return {
        date => $entry->{date},
        human_date => $meeting->strftime('%B %e, %Y'),
        human_day => $meeting->strftime('%B %e'),
        datetime => $meeting->ymd(),
        month => $meeting->month_name(),
        title => $entry->{title},
        presenter => $entry->{presenter},
        abstract => $entry->{abstract},
        location => $entry->{location},
        is_remote => ($entry->{location} eq 'Remote'),
    };
}

1;
__END__

=head1 NAME

HPM::Upcoming - [One line description of module's purpose here]


=head1 VERSION

This document describes HPM::Upcoming version 0.10

=head1 SYNOPSIS

    use HPM::Upcoming;

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

HPM::Upcoming requires no configuration files or environment variables.

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

