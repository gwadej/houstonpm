#!/usr/bin/perl
use strict;
use warnings;
use Time::HiRes qw(sleep);
use Test::WWW::Selenium;
use Test::More;
#use Test::Exception;

my $sel = Test::WWW::Selenium->new( host => "10.1.1.36",
                                    port => 4444, 
                                    browser => "*chrome", 
                                    browser_url => "http://maps.google.com/" );

$sel->open_ok("/");
$sel->window_maximize();
$sel->type_ok("q_d", "Houston, Tx");
$sel->click_ok("q-sub");
$sel->wait_for_element_present_ok("mtgt_A.1000");
$sel->click_ok("mtgt_A.1000");
$sel->wait_for_element_present_ok("css=span > div > span");
$sel->do_command("waitForText","css=span > div > span","Houston, TX");
$sel->text_is("css=span > div > span", "Houston, TX");
$sel->click_ok("css=span.actbar-text");
$sel->wait_for_element_present_ok("d_d");
$sel->type_ok("d_d", "Dallas, Tx");
$sel->click_ok("d_sub");
$sel->wait_for_element_present_ok("css=div.altroute-rcol.altroute-info");
$sel->text_is("css=div.altroute-rcol.altroute-info", "4 hours 7 mins");

done_testing;
