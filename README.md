# Source for Houston.pm website

**UPDATE**: As of the middle of December 2020, the houston.pm.org website is no
longer built from this code.

Up through that date, this project was the source for the
http://houston.pm.org/ website.

It consists of the presentations done by various people over the years and
the templates and code needed to create the site around those presentations.

## Main Directory

The main directory of the project contains several files that drive the creation
of the site.

* Makefile: The creation of the site is handled by the default make rule. Use
`make help` for more info.
* talks.xml: This XML file serves as a simple database of all of the talks. It
is used to define the overall directory structure and layout of the navigation.
* mostrecent.xsl: Builds the file that redirects to the most recent talk link.
* recenttalks.xsl: Builds the navigation page listing the most recent talks.
* talks2html.xsl: Library of template snippets that help building HTML out of the
talks.xml file.
* yeartalks.xsl: Builds the pages listing the talks for a given year.
* atom\_entries.json: JSON store holding the most recent atom entries for use in
building the atom feed.
* atom.xml: Generated Atom feed file.

## Directories

* bin: Contains scripts used to update the site.
    * announce.pl: Update the atom feed to announce a new meeting.
    * talks.pl: Main program for creating the site.
    * update\_atom.pl: Rebuild the atom.xml file from the entries file.
    * writeup.pl: Generate a writeup of a meeting for the website.
* images: Icon files for the site
* src: the Actual source for the site
* templates: TT templates used in creation of the site.
