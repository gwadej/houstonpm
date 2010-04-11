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
              ${OUTDIR}/talks/2010talks/index.html

site: base ${TALKSUMMARIES}

dirs:
	if [ ! -d ${OUTDIR} ]; then mkdir ${OUTDIR}; fi
	if [ ! -d ${OUTDIR}/talks ]; then mkdir ${OUTDIR}/talks; fi

base: dirs
	cp -r src/* ${OUTDIR}
	find out -type d -name '.svn' -exec rm -rf {} \; -prune

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

install:
	cp -R ${OUTDIR}/* ${INSTALLDIR}

publish:
	cp -R ${OUTDIR}/* ${PUBLISHDIR}

clean:
	find . -name '*.bck' -exec rm {} \;

clobber: clean
	rm -rf ${OUTDIR}/*
