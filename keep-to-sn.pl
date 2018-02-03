use Date::Parse;
use HTML::Entities;
use POSIX 'strftime';
use strict;
use warnings;
require "./sn.pl";
my $text="";
my $title="";
my $date="";
my $intitle=0;
my $inbody=0;
my $inheader=0;
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
    $inbody=0;
    $text="";
    $title="";
    $date="";
    $archived=0;
}

sn_begin();
while (<>) {
    chomp;
    if (/<body><div class="note DEFAULT"><div class="heading"><div class="meta-icons">/) {
	$inheader=1;
	$intitle=0;
	$inbody=0;
    }
    if ($inheader && /<div class="title">/) {
	$intitle=1;
	$inheader=0;
	$inbody=0;
    }
    if (/<div class="content">/) {
	$inbody=1;
	$inheader=0;
	$intitle=0;
    }
    if (/<span class="archived" title="Note archived">/) {
	$archived=1;
    }
    if ($inheader && /............<\/div>$/) {
	$date = str2time(cleanup_html($_));
	$date = strftime("%Y-%m-%dT%H:%M:%S", localtime($date));
	$inheader=0;
    } elsif ($intitle) {
	$title .= "$_\n";
    } elsif ($inbody) {
	$text .= "$_";
    }
    if (/<\/div>$/ && $inbody && ($text ne "")) {
	#while ($text =~ /(.*)&#(\d+);(.*)/) {
	#    $text="$1" . hex($2) . "$3";
	#}
	if ($archived) {
	    $text .= " #archived";
	}
	sn_addnote($date,cleanup_html("$title\n$text"));
	$nnotes++;
	reset_note();
    }
}
sn_end();
print "# report.keep-to-sn  nnotes:$nnotes\n";
