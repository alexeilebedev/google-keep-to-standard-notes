#
# module for outputing "standard notes" json files
# that can be later imported with "import data from archive"
# alexei lebedev, feb 2018
# 
use strict;
use warnings;
use JSON;
my $noteid=0;

# call to begin
sub sn_begin() {
    print qq!{\n!;
    print qq!  "items": [\n!;
}

# call this once per note
sub sn_addnote($$) {
    my($date,$text)=@_;
    if ($noteid>0) {
	print(",");
    }
    my $archived = ($text =~ /#archived/ ? 1:0);
    my $obj={
	uuid => "12d76962-cffb-4001-ac16-15a1c9" . sprintf("%06x",$noteid),
	content_type => "Note",
	created_at => "$date",
	content => {
	    text => $text,
	    references => [],
	    appData => {
		"org.standardnotes.sn"=> {
		    "archived"=> $archived
		}
	    }
	},
	updated_at => "$date"
    };
    print encode_json($obj);
    $noteid++;
}

# call at the end
sub sn_end() {
    print qq!  ]\n!;
    print qq!}\n!;
}

1;
