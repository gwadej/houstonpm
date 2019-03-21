#!/usr/bin/env perl

use Test::More 'no_plan'; #tests => 1;

use strict;
use warnings;

use lib '../lib';
use HPM::Date;

subtest 'meeting_day' => sub {
    is( HPM::Date::meeting_day( 1, 2019 ), 10, 'January' );
    is( HPM::Date::meeting_day( 2, 2019 ), 14, 'February' );
    is( HPM::Date::meeting_day( 3, 2019 ), 14, 'March' );
    is( HPM::Date::meeting_day( 4, 2019 ), 11, 'April' );
    is( HPM::Date::meeting_day( 5, 2019 ),  9, 'May' );
    is( HPM::Date::meeting_day( 6, 2019 ), 13, 'June' );
    is( HPM::Date::meeting_day( 7, 2019 ), 11, 'July' );
};

subtest 'next_meeting' => sub {
    is( HPM::Date::next_meeting( '20181215' ), '20190110', 'January' );
    is( HPM::Date::next_meeting( '20190111' ), '20190214', 'February' );
    is( HPM::Date::next_meeting( '20190220' ), '20190314', 'March' );
    is( HPM::Date::next_meeting( '20190320' ), '20190411', 'April' );
    is( HPM::Date::next_meeting( '20190420' ), '20190509', 'May' );
    is( HPM::Date::next_meeting( '20190520' ), '20190613', 'June' );
    is( HPM::Date::next_meeting( '20190620' ), '20190711', 'July' );
};

subtest 'next_meeting_dt' => sub {
    is( HPM::Date::next_meeting_dt( HPM::Date::datetime_from('20181215') ), HPM::Date::datetime_from('20190110'), 'January' );
    is( HPM::Date::next_meeting_dt( HPM::Date::datetime_from('20190111') ), HPM::Date::datetime_from('20190214'), 'February' );
    is( HPM::Date::next_meeting_dt( HPM::Date::datetime_from('20190220') ), HPM::Date::datetime_from('20190314'), 'March' );
    is( HPM::Date::next_meeting_dt( HPM::Date::datetime_from('20190320') ), HPM::Date::datetime_from('20190411'), 'April' );
    is( HPM::Date::next_meeting_dt( HPM::Date::datetime_from('20190420') ), HPM::Date::datetime_from('20190509'), 'May' );
    is( HPM::Date::next_meeting_dt( HPM::Date::datetime_from('20190520') ), HPM::Date::datetime_from('20190613'), 'June' );
    is( HPM::Date::next_meeting_dt( HPM::Date::datetime_from('20190620') ), HPM::Date::datetime_from('20190711'), 'July' );
};

