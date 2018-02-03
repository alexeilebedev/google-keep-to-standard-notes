Instructions to convert "Google Keep" notes to "Standard Notes"

Conversion instructions:
1. go to takeout.google.com
  select "keep", download a zip archive with all your notes. might take a while.
  I only had ~10k notes but google keep was already crawling (4 seconds to open a note for editing)
2. unzip archive. this creates a directory Takeout/Keep with lots of html files in it.
  The files follow a standard layout, which is parsed by this module.
  The module supports title, content, creation date and the archived flag. 
3. run perl keep-to-sn.pl Takeout/Keep/* > archive.json
4. in Standard Notes (desktop version), select "import data from archive", import the json file

Caveats:
- images are not supported
- still working on Russian support.

You will need the Perl JSON module. If this is not found,
do "cpan install JSON" first.
