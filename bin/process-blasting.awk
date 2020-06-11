#!/usr/bin/gawk -f


function get_date (timestamp) {
	t = mktime(gensub(/[-T :]/," ","g",timestamp))
	return strftime("%F", t)
	}


BEGIN{	FS = OFS="\t"; }

(($2=="salva")||($2=="stross")){print "FSE613", "berg", $1, $2, get_date($4), $13, $11, $15, $17}

