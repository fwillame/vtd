# $Id$

include Makefile.defs

PACKAGE      = package
VERSION      = ` date "+%Y.%m.%d" `
RELEASE_DIR  = ..
RELEASE_FILE = $(PACKAGE)-$(VERSION)
GDRIVE       = /usr/local/bin/gdrive

bkpname := $(shell basename $(CURDIR)).$(shell date +%F).tar.gz
tempdir := $(shell mktemp -d)

SUBDIRS		= vtd #fse607 # fse613
file		= data/FSE613.list

.DEFAULT_GOAL := all
.PHONY: clean

# target: help - Display callable targets.
help:
	egrep "^# target:" [Mm]akefile

IFS=$' \t\n\r'

retrieve:
	dos2unix -iso ${file} ;
	while  read f1 f2; do \
		echo $${f2}; \
		echo "$${f2}"; \
		echo $$f2; \
		echo "$$f2"; \
		echo $${f1}; \
		curl -o "data/$${f2}" "https://docs.google.com/spreadsheets/d/e/"$${f1}"/pub?output=tsv" ; \
	done < "${file}"



extract:
	cp data/FSE613-restrictions.tsv data/restrictions.tsv
	bin/process-timeline.awk < data/FSE613-contract.tsv > data/timeline.tsv
	bin/process-blasting.awk < data/FSE613-blasting.tsv > data/blasting.tsv
	bin/process-grouting.awk < data/FSE613-grouting.tsv > data/grouting.tsv
	bin/convert-igp.awk < data/FSE613-IGP-utfall.tsv > data/FSE613-IGP-outcome.tsv

#AnID	x	y	xlow	xhigh	ylow	yhigh	bergklass	Längd 2D

dist-publish-gpg: clean
	tar -cvz $(RELEASE_DIR)/$(shell basename $(CURDIR)) | gpg -er $(keyID) -o $(tempdir)/$(bkpname).gpg
	scp -Cp $(tempdir)/$(bkpname).gpg $(USER)@$(HOST):$(PUBDIR)
	rm -R $(tempdir)

dist-publish-bkp: clean
	tar -cvzf $(tempdir)/$(bkpname) .
	scp $(tempdir)/$(bkpname) $(USER)@$(HOST):$(PUBDIR)
	rm -R $(tempdir)

all: retrieve extract
	list='$(SUBDIRS)'; for subdir in $$list; do \
	  $(MAKE) -C $$subdir all; \
	done

clean:
	list='$(SUBDIRS)'; for subdir in $$list; do \
	  $(MAKE) -C $$subdir clean; \
	done
	cd data/ && rm  -f *.tsv && cd ../	; \

publish: all
	list='$(SUBDIRS)'; for subdir in $$list; do \
	  $(MAKE) -C $$subdir publish USER=$(USER) HOST=$(HOST) PUBDIR=$(PUBDIR)/$$subdir; \
	done

view: retrieve
	list='$(SUBDIRS)'; for subdir in $$list; do \
		$(MAKE) -C $$subdir view; \
	done

retrieveX:
	for fileID in $(GDOCS); do \
		cd data/ && $(GDRIVE) export -f --mime $(tsv) $$fileID && cd ../	; \
		wait 5	; \
	done

retrieve1:
	while readarray  myArray; do \
		echo "field 0 : ${myArray[0]}"; \
		echo "field 1" ${myArray[1]}; \
		echo "filed 2: ${myArray[2]}"; \
	done < `cat "${file}"`


retrieve2:
	dos2unix ${file} ;
	while read line || [ -n "$${line}" ]; do \
		echo $${line} ;\
		f1=`echo $${line} | awk '{ print $$1 }'` ; \
		f2=`echo $${line} | awk '{ print $$2 }'` ; \
		echo "f1 : $${f1}" ; \
		echo "f2 : $${f2}" ; \
		curl -o "data/$${f2}" "https://docs.google.com/spreadsheets/d/e/"$${f1}"/pub?output=tsv" ; \
		done < "${file}"


# declare -a myarray

retrieve3:
	readarray myarray < "${file}"
	while read myarray; do \
		echo "field 0 : ${myArray[0]}"; \
		echo "field 1" ${myArray[1]}; \
		echo "filed 2: ${myArray[2]}"; \
	done


VARIABLE = $(file < ${file})



