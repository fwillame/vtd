#!/usr/bin/gawk -f

BEGIN{	FS = OFS="\t"; }

function get_date (timestamp) {
	t = mktime(gensub(/[\/.-]/," ","g",timestamp))
	return strftime("%F", t)
	}

($3==1)&&($4=="berg"){print $2, $4, $6$7$8, $9, get_date($12), $10, get_date($13)}
