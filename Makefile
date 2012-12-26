# Makefile for the Houston.pm website

OUTDIR=out
INSTALLDIR=/var/www-vhost/houstonpm/
PUBLISHDIR=/mnt/houstonpm/

TALKSUMMARIES=${OUTDIR}/talks/mostrecent.html \
              ${OUTDIR}/talks/index.html \
              ${OUTDIR}/talks/2003talks/index.html \
              ${OUTDIR}/talks/2004talks/index.html \
              ${OUTDIR}/talks/2005talks/index.html \
              ${OUTDIR}/talks/2006talks/index.html \
              ${OUTDIR}/talks/2007talks/index.html \
              ${OUTDIR}/talks/2008talks/index.html \
              ${OUTDIR}/talks/2009talks/index.html \
              ${OUTDIR}/talks/2010talks/index.html \
              ${OUTDIR}/talks/2011talks/index.html \
              ${OUTDIR}/talks/2012talks/index.html


site: base ${TALKSUMMARIES}

dirs:
	if [ ! -d ${OUTDIR} ]; then mkdir ${OUTDIR}; fi
	if [ ! -d ${OUTDIR}/talks ]; then mkdir ${OUTDIR}/talks; fi

base: dirs convert
	cp -r src/* ${OUTDIR}
	find out -type f -name '*.tt2' -exec rm -rf {} \; -prune
	cp atom.xml ${OUTDIR}

${OUTDIR}/talks/mostrecent.html: talks.xml mostrecent.xsl templates/mostrecent.tmpl
	bin/talks.pl --style=mostrecent.xsl --template=templates/mostrecent.tmpl talks.xml > $@

${OUTDIR}/talks/index.html: talks.xml recenttalks.xsl templates/recenttalks.tmpl
	bin/talks.pl --style=recenttalks.xsl --template=templates/recenttalks.tmpl talks.xml > $@

${OUTDIR}/talks/2003talks/index.html: talks.xml yeartalks.xsl templates/yeartalks.tmpl
	bin/talks.pl --style=yeartalks.xsl --template=templates/yeartalks.tmpl --define year2=03 talks.xml > $@

${OUTDIR}/talks/2004talks/index.html: talks.xml yeartalks.xsl templates/yeartalks.tmpl
	bin/talks.pl --style=yeartalks.xsl --template=templates/yeartalks.tmpl --define year2=04 talks.xml > $@

${OUTDIR}/talks/2005talks/index.html: talks.xml yeartalks.xsl templates/yeartalks.tmpl
	bin/talks.pl --style=yeartalks.xsl --template=templates/yeartalks.tmpl --define year2=05 talks.xml > $@

${OUTDIR}/talks/2006talks/index.html: talks.xml yeartalks.xsl templates/yeartalks.tmpl
	bin/talks.pl --style=yeartalks.xsl --template=templates/yeartalks.tmpl --define year2=06 talks.xml > $@

${OUTDIR}/talks/2007talks/index.html: talks.xml yeartalks.xsl templates/yeartalks.tmpl
	bin/talks.pl --style=yeartalks.xsl --template=templates/yeartalks.tmpl --define year2=07 talks.xml > $@

${OUTDIR}/talks/2008talks/index.html: talks.xml yeartalks.xsl templates/yeartalks.tmpl
	bin/talks.pl --style=yeartalks.xsl --template=templates/yeartalks.tmpl --define year2=08 talks.xml > $@

${OUTDIR}/talks/2009talks/index.html: talks.xml yeartalks.xsl templates/yeartalks.tmpl
	bin/talks.pl --style=yeartalks.xsl --template=templates/yeartalks.tmpl --define year2=09 talks.xml > $@

${OUTDIR}/talks/2010talks/index.html: talks.xml yeartalks.xsl templates/yeartalks.tmpl
	bin/talks.pl --style=yeartalks.xsl --template=templates/yeartalks.tmpl --define year2=10 talks.xml > $@

${OUTDIR}/talks/2011talks/index.html: talks.xml yeartalks.xsl templates/yeartalks.tmpl
	bin/talks.pl --style=yeartalks.xsl --template=templates/yeartalks.tmpl --define year2=11 talks.xml > $@

${OUTDIR}/talks/2012talks/index.html: talks.xml yeartalks.xsl templates/yeartalks.tmpl
	bin/talks.pl --style=yeartalks.xsl --template=templates/yeartalks.tmpl --define year2=12 talks.xml > $@

convert:
	ttree --define year=2012 -f _ttreerc about.tt2 faqs.tt2 index.tt2 meetings.tt2 remote_meetings.tt2

install:
	cp -R ${OUTDIR}/* ${INSTALLDIR}

publish:
	cp -R ${OUTDIR}/* ${PUBLISHDIR}

clean:
	find . -name '*.bck' -exec rm {} \;

clobber: clean
	rm -rf ${OUTDIR}/*

makefile: templates/Makefile.tt2
	tpage --define year=`perl -e"print 1900+((localtime)[5])"` templates/Makefile.tt2 > Makefile
