#!/usr/bin/env perl

use Test::More;

use strict;
use warnings;

use DomainName::Validator;

my @valid_domains = (
    [ 'google.com',    'well-known domain' ],
    [ 'Google.com',    'contains an uppercase letter' ],
    [ 'GOOGLE.COM',    'all upper case' ],
    [ 'this-is.it',    'internal hyphens' ],
    [ '37signals.com', 'digits allowed' ],
    [ 'localhost',     'special domain' ],
    [ 'a.com',         'minimal .com domain' ],
    [ 'b.a.com',       'domain with subdomain' ],
    [
        ( 'abcdefghijklmnopqrstuvwxyz' x 9 ) . ( '01234567890123456789a' ) . '.com',
        'max single segment domain'
    ],
    [ 'a.b.c.d.e.f.g.h.i.j.k.l.m.n.o.p.q.r.s.t.u.v.w.x.y.z.com', 'deep FQDN' ],
    [ 'a.us',                                                    'minimal .us domain' ],
    [ 'a.co.uk',                                                 'other country domain' ],
    [ 'bcher-kvaa.com',                                          'punycode supported' ],
);

my @invalid_domains = (
    [ 'com',             'only top-level' ],
    [ '.com',            'only top-level with dot' ],
    [ '.google.com',     'starts with dot' ],
    [ 'google-.com',     'segment ends in hyphen' ],
    [ 'google3.com',     'segment ends in digit' ],
    [ 'www..google.com', 'contains double dot' ],
    [ 'www-google-com',  'contains no dots' ],
    [ 'www_google.com',  'invalid character' ],
    [ 'www+google.com',  'invalid character' ],
    [ 'www=google.com',  'invalid character' ],
    [ 'www*google.com',  'invalid character' ],
    [ 'www(google.com',  'invalid character' ],
    [ 'www~google.com',  'invalid character' ],
    [ 'www`google.com',  'invalid character' ],
    [ 'www@google.com',  'invalid character' ],
    [ 'www#google.com',  'invalid character' ],
    [ 'www$google.com',  'invalid character' ],
    [ 'www%google.com',  'invalid character' ],
    [ 'www^google.com',  'invalid character' ],
    [ 'www&google.com',  'invalid character' ],
    [ 'www:google.com',  'invalid character' ],
    [ 'www;google.com',  'invalid character' ],
    [ 'www"google.com',  'invalid character' ],
    [ 'www\'google.com', 'invalid character' ],
    [ 'www<google.com',  'invalid character' ],
    [ 'www,google.com',  'invalid character' ],
    [ 'www>google.com',  'invalid character' ],
    [ 'www/google.com',  'invalid character' ],
    [ 'www?google.com',  'invalid character' ],
    [ 'www{google.com',  'invalid character' ],
    [ 'www}google.com',  'invalid character' ],
    [ 'www[google.com',  'invalid character' ],
    [ 'www]google.com',  'invalid character' ],
    [ 'www|google.com',  'invalid character' ],
    [ 'www\\google.com', 'invalid character' ],
    [ 'www google.com',  'invalid character' ],
);

plan( @valid_domains + @invalid_domains );

for my $domain ( @valid_domains )
{
    ok( is_valid_domain( $domain->[0] ), "Domain is valid: $domain->[1] ($domain->[0])" );
}

for my $domain ( @invalid_domains )
{
    ok( !is_valid_domain( $domain->[0] ), "Domain invalid: $domain->[1] ($domain->[0])" );
}
