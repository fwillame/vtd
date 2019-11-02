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
file		= data/data-list.tsx

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

#FSE613-blastreport.tsv         ${line%$'\r'}
#2PACX-1vSQLhLA65XpIFrmoznaLIRxlWdsKpd7eZPNO2daYzO_yrBRZUzhjesotCAOipvllWFQTssIh2tP080y
#

extract:

	awk -F "\t| " '{ if(($$1 == "HT601N") && (($$2 == "salva") || ($$2 == "stross")))	{ print $$4"\t"$$15 } }'	data/report-2018-10-09.tsv | sort > data/HT601N.tsv
	awk -F "\t| " '{ if(($$1 == "HT602S") && (($$2 == "salva") || ($$2 == "stross")))	{ print $$4"\t"$$15 } }'	data/report-2018-10-09.tsv | sort > data/HT602S.tsv
	awk -F "\t| " '{ if(($$1 == "HT602N") && (($$2 == "salva") || ($$2 == "stross")))	{ print $$4"\t"$$15 } }'	data/report-2018-10-09.tsv | sort > data/HT602N.tsv
	awk -F "\t| " '{ if(($$1 == "AT691" ) && ($$2 == "salva"))	{ print $$4"\t"$$13 } }'		data/report-2018-10-09.tsv | sort > data/AT691.tsv
	awk -F "\t| " '{ if(($$1 == "69M"   ) && ($$2 == "salva"))	{ print $$4"\t"$$13 } }'		data/report-2018-10-09.tsv | sort > data/69M.tsv
	awk -F "\t" '{ if(($$4 == "601")	&& ($$20  ~ /omgång 1/))	{ print substr($$7,1,10)"\t"$$11-100000"\t0\t"$$12-$$11 } }'	data/FSE613-grouting.tsv > data/HT601-inject-omg1.tsv
	awk -F "\t" '{ if(($$4 == "601")	&& ($$20 !~ /omgång 1/))	{ print substr($$7,1,10)"\t"$$11-100000"\t0\t"$$12-$$11 } }'	data/FSE613-grouting.tsv > data/HT601-inject-omgx.tsv
	awk -F "\t" '{ if(($$4 == "602")	&& ($$20  ~ /omgång 1/))	{ print substr($$7,1,10)"\t"$$11-200000"\t0\t"$$12-$$11 } }'	data/FSE613-grouting.tsv > data/HT602-inject-omg1.tsv
	awk -F "\t" '{ if(($$4 == "602")	&& ($$20 !~ /omgång 1/))	{ print substr($$7,1,10)"\t"$$11-200000"\t0\t"$$12-$$11 } }'	data/FSE613-grouting.tsv > data/HT602-inject-omgx.tsv
	awk -F "\t" '{ if(($$4 == "691")	&& ($$20  ~ /omgång 1/))	{ print substr($$7,1,10)"\t28526\t0\t"$$12-$$11 } }'			data/FSE613-grouting.tsv > data/AT691-inject-omg1.tsv
	awk -F "\t" '{ if(($$4 == "691")	&& ($$20 !~ /omgång 1/))	{ print substr($$7,1,10)"\t28526\t0\t"$$12-$$11 } }'			data/FSE613-grouting.tsv > data/AT691-inject-omgx.tsv
	awk -F "\t" '{ if(($$4 == "69M")	&& ($$20  ~ /omgång 1/))	{ print substr($$7,1,10)"\t28520\t0\t"$$12-$$11 } }'			data/FSE613-grouting.tsv > data/UT69M-inject-omg1.tsv
	awk -F "\t" '{ if(($$4 == "69M")	&& ($$20 !~ /omgång 1/))	{ print substr($$7,1,10)"\t28520\t0\t"$$12-$$11 } }'			data/FSE613-grouting.tsv > data/UT69M-inject-omgx.tsv
	awk -F "\t" '{ if(($$4 == "6AB")	&& ($$20  ~ /omgång 1/))	{ print substr($$7,1,10)"\t28552\t0\t"$$12-$$11 } }'			data/FSE613-grouting.tsv > data/UT6AB-inject-omg1.tsv
	awk -F "\t" '{ if(($$4 == "6AB")	&& ($$20  ~ /omgång 1/))	{ print substr($$7,1,10)"\t28552\t0\t"$$12-$$11 } }'			data/FSE613-grouting.tsv > data/UT6AB-inject-omgx.tsv
	data/convert-igp.awk < data/FSE613-IGP-utfall.tsv > data/FSE613-IGP-outcome.tsv

#awk -F '\t' '($3==1)&&($4=="berg")&&($7=="601"){print $2, $4, $6$7, $8, $9, $10, $12, $13}' data/blabla1.tsv


#	awk -F "\t" '{ if($$1 == "601") {print $$1, $$2, $$3-100000, $$4, $$5, $$6-100000, $$7-100000, $$8, $$9} elseif ($$1 =="602") {print $$1, $$2, $$3-200000, $$4, $$5, $$6-200000, $$7-200000, $$8, $$9}
#	else {print $$0}' data/FSE613-IGP-utfall.tsv > data/FSE613-IGP-outcome.tsv

#AnID	x	y	xlow	xhigh	ylow	yhigh	bergklass	Längd 2D

#	awk -F "\t" '{ if($$1 == "601")	{ print substr($$7,1,10)"\t"$$11-100000"\t0\t"$$12-$$11 } }' data/FSE613-grouting.tsv > data/HT601-inject.tsv
#	awk -F "\t" '{ if($$4 == "602")	{ print substr($$7,1,10)"\t"$$11-200000"\t0\t"$$12-$$11 } }' data/FSE613-grouting.tsv > data/HT602-inject.tsv
#	awk -F "\t" '{ if(($$1 == "602") && ($$ == "salva"))  { print $$4"\t"$$13 } }' data/report-2018-10-09.tsv | sort > data/HT601N.tsv
#	awk -F "\t" '{ if(($$1 == "HT602S") && ($$2 == "salva"))  { print $$4"\t"$$13 } }' data/report-2018-10-09.tsv | sort > data/HT602S.tsv
#	awk -F "\t" '{ if(($$1 == "HT602N") && ($$2 == "salva"))  { print $$4"\t"$$13 } }' data/report-2018-10-09.tsv | sort > data/HT602N.tsv
#	awk -F "\t" '{ if(($$1 == "AT691" ) && ($$2 == "salva"))  { print $$4"\t"$$13 } }' data/report-2018-10-09.tsv | sort > data/AT691.tsv
#	awk -F "\t" '{ if(($$1 == "69M"   ) && ($$2 == "salva"))  { print $$4"\t"$$13 } }' data/report-2018-10-09.tsv | sort > data/69M.tsv


#	awk -F "\t" '{ if(($$10 == "601: Negativ") && ($$2 >= "2018-01-01 00:00:00") )  { print substr($$2,1,10)"\t"substr($$11,1,5) } }' data/FSE613-bergsaker.tsv | sort > data/HT601S.tsv
#	awk -F "\t" '{ if(($$10 == "601: Positiv") && ($$2 >= "2018-01-01 00:00:00"))  { print substr($$2,1,10)"\t"substr($$11,1,5) } }' data/FSE613-bergsaker.tsv | sort > data/HT601N.tsv
#	awk -F "\t" '{ if(($$10 == "602: Negativ") && ($$2 >= "2018-01-01 00:00:00"))  { print substr($$2,1,10)"\t"substr($$11,1,5) } }' data/FSE613-bergsaker.tsv | sort > data/HT602S.tsv
#	awk -F "\t" '{ if(($$10 == "602: Positiv") && ($$2 >= "2018-01-01 00:00:00"))  { print substr($$2,1,10)"\t"substr($$11,1,5) } }' data/FSE613-bergsaker.tsv | sort > data/HT602N.tsv


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



# ods2tsv



# https://stackoverflow.com/questions/6564561/gnuplot-conditional-plotting-plot-col-acol-b-if-col-c-x
#






# declare -a array1

# array1=( `cat "$filename"`)

# retrieve2:
# 	lista=



# http://tldp.org/LDP/abs/html/arrays.html

# https://docs.google.com/spreadsheets/d/e/2PACX-1vSQLhLA65XpIFrmoznaLIRxlWdsKpd7eZPNO2daYzO_yrBRZUzhjesotCAOipvllWFQTssIh2tP080y/pub?gid=0&single=true&output=tsv
# https://stackoverflow.com/questions/13614275/reading-a-file-inside-makefile

# $Id$


# input="/path/to/your/input/file.cvs"
