#!/usr/bin/perl
#
# module to convert google keep takeouts to "standard notes" json format.
# alexei lebedev, feb 2018
#
use Date::Parse;
use Encoding;
use HTML::Entities qw(decode_entities);
use POSIX 'strftime';
use strict;
use warnings;
require "./sn.pl";

my $text="";
my $title="";
my $date="";
my $in=-1; # header=0, title=1, body=2
my $archived=0;
my $nnotes=0;

sub cleanup_html($) {
    my $text=$_[0];
    $text =~ s/<div class="title">//g;
    $text =~ s/<div class="content">//g; # crap
    $text =~ s/<\/div>//g; # leftover divs
    $text =~ s/<br>/\n/g; # html breaks
    $text =~ s/^\n//g;  # leading newlines
    return $text;
}
sub reset_note() {
    $in=-1;
    $text="";
    $title="";
    $date="";
    $archived=0;
}

sn_begin();
# we are looking for the following:
# <body><div class="note DEFAULT"><div class="heading"><div class="meta-icons">
# </div>
# Sep 23, 2016, 5:41:43 PM</div>    <---------- date extracted from here, $in=0
# <div class="title">title</div>   <----- title here, $in=1
# <div class="content">text         <--- content here, $in=2
# </div>                           <--- </div> when $in=2 ends the body
# </div></body></html>   
while (<>) {
    chomp;
    # google keep dumps in UTF-8, but with errors, so must use loose 
    # standards, e.g. utf8 + no error monitoring
    $_ = decode('utf8', $_); 
    # some wide characterws are encoded as html entities 
    # instead of utf8 chars. why didn't you convert them to UTF-8, google?
    $_ = decode_entities($_);
    $in=0 if (/<body><div class="note DEFAULT"><div class="heading"><div class="meta-icons">/);
    $in=1 if ($in==0 && /<div class="title">/);
    $in=2 if (/<div class="content">/);
    $archived=1 if (/<span class="archived" title="Note archived">/);
    if ($in==0 && /............<\/div>$/) {
	$date = str2time(cleanup_html($_));
	$date = strftime("%Y-%m-%dT%H:%M:%S", localtime($date));
	$in=1; # assume title
    } elsif ($in==1) {
	$title .= "$_\n"; # accumulate title string
    } elsif ($in==2) {
	$text .= "$_"; # accumulate body string
    }
    if (/<\/div>$/ && $in==2 && ($text ne "")) {
	$text .= " #archived" if ($archived);  # append #archived hashtag
	# combine them -- there is no separate title...
	$text = cleanup_html("$title\n$text");
	sn_addnote($date,$text);
	$nnotes++;
	reset_note();
    }
}
sn_end();
print STDERR "report.keep-to-sn  nnotes:$nnotes\n";
