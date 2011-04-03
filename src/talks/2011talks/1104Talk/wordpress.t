use strict;
use warnings;
use Time::HiRes qw(sleep);
use Test::WWW::Selenium;
use Test::More "no_plan";
use Test::Exception;

my $sel = Test::WWW::Selenium->new( host => $ENV{SELENIUM_SERVER},
                                    port => 4444, 
                                    browser => "*chrome", 
                                    browser_url => "https://en.wordpress.com/" );

$sel->open_ok("/signup/");
$sel->wait_for_element_present_ok("blogname");
$sel->type_ok("blogname", "thisisthecoolestblogintheworld");
$sel->fire_event_ok("blogname","blur");
$sel->wait_for_element_present_ok("user_name");
$sel->type_ok("user_name", "thisisatest");
$sel->fire_event_ok("user_name","blur");
$sel->type_ok("pass1", "helloworld");
$sel->fire_event_ok("pass1","blur");
$sel->wait_for_element_present_ok("css=#update-password > span");
$sel->text_is("css=#update-password > span", "Good");
$sel->type_ok("pass2", "helloworld");
$sel->fire_event_ok("pass2","blur");
$sel->type_ok("user_name", "testusergordonchild");
$sel->text_is("user_email-free", "✓");

done_testing;
