#!/usr/bin/gawk -f

function get_date (timestamp) {
	t = mktime(gensub(/[-:]/," ","g",timestamp))
	return strftime("%F", t)
	}

BEGIN{	FS = OFS="\t"; }

$4 == "601" { LM = $11%100000 }
$4 == "602" { LM = $11%100000 }
$4 == "691" { LM = 28526 }
$4 == "69K" { LM = 28020 }
$4 == "69M" { LM = 28525 }
$4 == "69N" { LM = 28920 }
$4 == "66R" { LM = 28339 }
$4 == "66G" { LM = 28303 }
$4 == "683" { LM = 28332 }
$4 == "6A6" { LM = 28052 }
$4 == "6A7" { LM = 28152 }
$4 == "6A8" { LM = 28252 }
$4 == "6A9" { LM = 28352 }
$4 == "6AA" { LM = 28452 }
$4 == "6AB" { LM = 28552 }
$4 == "6AC" { LM = 28652 }
$4 == "6AD" { LM = 28752 }
$4 == "6AE" { LM = 28852 }
$4 == "6AF" { LM = 28952 }
$4 == "6GA" { LM = 28345 }

$20 ~ /klass A/ { class = "A" }
$20 ~ /klass B/ { class = "B" }
$20 ~ /klass C/ { class = "C" }
$20 ~ /omgång 1/ { omgg = "1" }
$20 ~ /omgång 2/ { omgg = "2" }
$20 ~ /kompletterande omgång/ { omgg = "X" }

((NR>1) && (($4 == "601") || ($4 == "602"))){print $4, get_date($7":00") , LM, 0, $12-$11, class, omgg }
