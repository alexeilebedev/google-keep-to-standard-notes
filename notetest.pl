#
# module to test performance of "standard notes" loading 50,000 notes. 
# use this to create a json file that can be imported into "standard notes".
# perl notetest.pl > notes.json
#
# the performance is terrible. try not to get to 50,000 notes.
#
print qq!{\n!;
print qq!  "items": [\n!;
for ($i=0; $i<50000; $i++) {
    if ($i>0) {
	print(",");
    }
    print qq!{\n!;
    print qq!  "uuid": "12d76962-cffb-4001-ac16-15a1c9! . sprintf("%06x",$i) . qq!",\n!;
    print qq!  "content_type": "Note",\n!;
    print qq!  "created_at": "2018-02-03T16:30:38.517Z",\n!;
    print qq!  "content": {\n!;
    print qq!    "text": "number:$i expect nothing, only then can you be prepared for anything\\n #quote #tag$i",\n!;
    print qq!    "references": [],\n!;
    print qq!    "appData": {}\n!;
    print qq!  },\n!;
    print qq!  "updated_at": "2018-02-03T16:31:46.013Z"\n!;
    print qq!}\n!;
}
print qq!  ]\n!;
print qq!}\n!;
