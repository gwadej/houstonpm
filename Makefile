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
              ${OUTDIR}/talks/2012talks/index.html \
              ${OUTDIR}/talks/2013talks/index.html


site: base ${TALKSUMMARIES}

dirs:
	if [ ! -d ${OUTDIR} ]; then mkdir ${OUTDIR}; fi
	if [ ! -d ${OUTDIR}/talks ]; then mkdir ${OUTDIR}/talks; fi

base: dirs convert
	cp -r src/* ${OUTDIR}
	find out -type f -name '*.tt2' -exec rm -rf {} \; -prune
	cp atom.xml ${OUTDIR}

${OUTDIR}/talks/mostrecent.html: talks.xml mostrecent.xsl templates/mostrecent.tt2
	bin/talks.pl --style=mostrecent.xsl --template=mostrecent.tt2 talks.xml > $@

${OUTDIR}/talks/index.html: talks.xml recenttalks.xsl templates/recenttalks.tt2
	bin/talks.pl --style=recenttalks.xsl --template=recenttalks.tt2 talks.xml > $@

${OUTDIR}/talks/2003talks/index.html: talks.xml yeartalks.xsl templates/yeartalks.tt2
	bin/talks.pl --style=yeartalks.xsl --template=yeartalks.tt2 --define year=2003 talks.xml > $@

${OUTDIR}/talks/2004talks/index.html: talks.xml yeartalks.xsl templates/yeartalks.tt2
	bin/talks.pl --style=yeartalks.xsl --template=yeartalks.tt2 --define year=2004 talks.xml > $@

${OUTDIR}/talks/2005talks/index.html: talks.xml yeartalks.xsl templates/yeartalks.tt2
	bin/talks.pl --style=yeartalks.xsl --template=yeartalks.tt2 --define year=2005 talks.xml > $@

${OUTDIR}/talks/2006talks/index.html: talks.xml yeartalks.xsl templates/yeartalks.tt2
	bin/talks.pl --style=yeartalks.xsl --template=yeartalks.tt2 --define year=2006 talks.xml > $@

${OUTDIR}/talks/2007talks/index.html: talks.xml yeartalks.xsl templates/yeartalks.tt2
	bin/talks.pl --style=yeartalks.xsl --template=yeartalks.tt2 --define year=2007 talks.xml > $@

${OUTDIR}/talks/2008talks/index.html: talks.xml yeartalks.xsl templates/yeartalks.tt2
	bin/talks.pl --style=yeartalks.xsl --template=yeartalks.tt2 --define year=2008 talks.xml > $@

${OUTDIR}/talks/2009talks/index.html: talks.xml yeartalks.xsl templates/yeartalks.tt2
	bin/talks.pl --style=yeartalks.xsl --template=yeartalks.tt2 --define year=2009 talks.xml > $@

${OUTDIR}/talks/2010talks/index.html: talks.xml yeartalks.xsl templates/yeartalks.tt2
	bin/talks.pl --style=yeartalks.xsl --template=yeartalks.tt2 --define year=2010 talks.xml > $@

${OUTDIR}/talks/2011talks/index.html: talks.xml yeartalks.xsl templates/yeartalks.tt2
	bin/talks.pl --style=yeartalks.xsl --template=yeartalks.tt2 --define year=2011 talks.xml > $@

${OUTDIR}/talks/2012talks/index.html: talks.xml yeartalks.xsl templates/yeartalks.tt2
	bin/talks.pl --style=yeartalks.xsl --template=yeartalks.tt2 --define year=2012 talks.xml > $@

${OUTDIR}/talks/2013talks/index.html: talks.xml yeartalks.xsl templates/yeartalks.tt2
	bin/talks.pl --style=yeartalks.xsl --template=yeartalks.tt2 --define year=2013 talks.xml > $@

convert:
	ttree --define end_year=2013 -f _ttreerc

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
