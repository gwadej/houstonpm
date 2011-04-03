#!/usr/bin/perl
use strict;
use warnings;

use Test::WWW::Selenium;
use Test::More;
use YAML::XS;
use MIME::Base64;

my $sel = Test::WWW::Selenium->new(
  host        => $ENV{SELENIUM_SERVER},
  port        => 4444,
  browser     => '*firefox',
  browser_url => "http://facebook.com",
);

my $email = "facebook_email\@domain.com";
my $friend = "Firstname Lastname";
my $album = "Album Name";

$sel->start;
$sel->open_ok("http://facebook.com");
$sel->window_maximize_ok;
$sel->wait_for_element_present_ok("email");
$sel->type_ok("email", $email);
$sel->wait_for_element_present_ok("q");
$sel->click_ok("q");
$sel->type_ok("q", $friend);
$sel->click_ok("css=button[type=submit]");
$sel->wait_for_element_present_ok("link=$friend");
$sel->click_ok("link=$friend");
$sel->wait_for_element_present_ok("css=#navItem_photos > a.item > span.linkWrap");
$sel->click_ok("css=#navItem_photos > a.item > span.linkWrap");
$sel->wait_for_element_present_ok("link=Photos");
$sel->click_ok("link=Photos");
$sel->wait_for_element_present_ok("link=$album");
$sel->click_ok("link=$album");
#$sel->wait_for_element_present_ok("css=a[name=502351408622] > span.uiMediaThumbWrap > i");
#$sel->click_ok("css=a[name=502351408622] > span.uiMediaThumbWrap > i");
$sel->wait_for_element_present_ok("css=div.tagWrapper > i");
$sel->click_ok("css=div.tagWrapper > i");
my $image_xpath = q{//div[@id='fbPhotoTheater']/div/div[3]/div/img};
$sel->wait_for_element_present_ok($image_xpath);
$sel->wait_for_condition_ok(qq{selenium.browserbot.findElement("$image_xpath").complete;},10000);
my $original_image_src = $sel->get_eval(qq{selenium.browserbot.findElement("$image_xpath").getAttribute('src')});
my $previous_img_src = '';
my $get_img_script = q{var img=selenium.browserbot.findElement("}.$image_xpath.q{");var canvas=window.document.createElement("canvas");canvas.width=img.width;canvas.height=img.height;var ctx=canvas.getContext("2d");ctx.drawImage(img,0,0);var dataURL=canvas.toDataURL("image/png");dataURL.replace(/^data:image\/(png|jpg);base64,/,"");};

my $counter = 0;
mkdir "images" if !-d "images";
do {
  $previous_img_src = $sel->get_eval(qq{selenium.browserbot.findElement("$image_xpath").getAttribute('src');}) if $counter;
  my $encoded_image = $sel->get_eval($get_img_script);
  save_image($encoded_image,"images/img$counter.png");
  $sel->click_ok("//div[\@id='fbPhotoTheaterStageActions']/a[2]");
  $sel->wait_for_condition_ok(
    qq{selenium.browserbot.findElement("$image_xpath").complete && selenium.browserbot.findElement("$image_xpath").getAttribute('src') != "$previous_img_src"},
    10000
  );
  $counter++;
} while($previous_img_src ne $original_image_src);

# img /html/body/div[5]/div/div[3]/div/img
# img //div[\@id='fbPhotoTheatre']/div/div[3]/div/img

sub save_image {
  my ($img_base64,$path) = @_;
  my $image_decoded = decode_base64($img_base64);
  open IMG,'>',$path or die "Couldn't open $path for writing: $!";
  binmode IMG;
  print IMG $image_decoded;
  close IMG;
}

sub wait_for_any_elements_present {
  my ($sel,$elements,$timeout) = @_;
  my $script = '';
  my $i=0;
  for my $element(@{$elements}) {
    $script .= " || " if $i++;
    $script .= qq{selenium.isElementPresent("$element")};
  }
  $sel->wait_for_condition($script,$timeout);
}

done_testing;
0;
