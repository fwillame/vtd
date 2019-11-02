#!/usr/bin/perl
#
# Script that expands generic templates
#
# Jeremy Lainé <jeremy.laine@m4x.org>
#
# $Id: templex.pl,v 1.10 2004/07/13 11:38:11 sharky Exp $

use strict;
use Getopt::Std;
use File::Basename;

my $prog = basename($0);
my $revision = '$Revision: 1.10 $';
my %opts;
my $prefix;

# perform substitution on some lines
sub subst {
  my ($vars,@lines) = @_;
  my @olines;

  foreach my $line (@lines) {
    my @tokens = split(/({[^{]*})/,$line);
    my $oline;
    while (defined(my $token = shift @tokens)) {
      if ($token =~ /^{\$(\w+)(\[([0-9]+)\])?}$/) {
        my $key = lc($1);
	defined($vars->{$key}) or 
	  die("undefined variable '$key' on line :\n$line");
	
	# replace the token by its value
        my $val = $vars->{$key};

	# if we were given an index, try to read it
	if ($2) {
	  (ref($val) eq 'ARRAY') or 
	    die("variable '$key' is not an array on line :\n$line");
	  defined($val->[$3]) or
	    die("variable '$key' does not have an element '$3' on line :\n$line");
	  $val = $val->[$3];
	}

	# if needed, switch to uppercase
	($1 eq uc($1)) and $val = uc($val);

	$oline .= $val;
      } else {
        $oline .= $token;
      }
    }
    push @olines,$oline;
  }
 
  return (scalar(@olines) > 1) ? @olines : @olines[0];
}


# expand one template
sub expand {
  my $TEMPLATE = shift;
  my (@TARGETS,@slines);

  # read template
  open(TPL,$TEMPLATE);
  my @lines = <TPL>;
  close TPL;

  # extract variables from template
  my ($output,@combis);
  foreach my $line(@lines) {
    if ($line =~ /^$prefix\s*output\s+([^\s]+)\s*$/) {
      # this line defines the name of the output file
      $output = $1;
    } elsif ($line =~ /^$prefix\s*([a-zA-Z]+)\s*=(.*)$/) {
      # this line defines a variable
      my ($var,@vals) = ($1,eval($2));
      my @ncombis;
      foreach my $val(@vals) {
        if (scalar(@combis) == 0) {
          push @ncombis, { $var => $val };
	} else {
          for (my $i = 0; $i < scalar(@combis); $i++) {
            push @ncombis, { %{$combis[$i]}, $var=>$val };
	  }
	}
      }
      @combis = @ncombis;
    } else {
      push @slines,$line;
    }
  }
  $output or die("Did not find an output file!\n");


  # loop over the combinations
  foreach my $combi(@combis)
  {
    my $out = &subst($combi,$output);
    push @TARGETS,$out;

    if (!$opts{'d'}) {
      my @olines = &subst($combi,@slines);
      open(OUT,">$out");
      print OUT @olines;
      close OUT;
    }
  }

  return @TARGETS;
}


# display program usage
sub syntax {
  $revision =~ s/(\$)Revision: (.*) \$$/v\2/;
  print "[ This is $prog ($revision), a template expander ]\n\n",
        "Syntax:\n",
	"  $prog <options> <templates>\n\n",
	" Arguments:\n",
        "  templates    - the templates to process\n\n",
	" Options:\n",
        "  -h           - this help message\n",
        "  -d           - print out dependencies in Makefile format\n",
	"  -p <prefix>  - use <prefix> as the delimiter for templex commands\n",
	"                 default : ##\n",
	"\n";
}


# the main routine
sub main {
  if ( not getopts('dhp:', \%opts) )
  {
    print("invalid syntax, try $prog -h!\n");
    exit;
  }
  
  # display program usage and exit
  if ($opts{'h'}) {
    &syntax;
    exit;
  }

  # set prefix
  $prefix = $opts{'p'} ? $opts{'p'} : '##';

  # process templates
  my @all_TARGETS;
  foreach my $TEMPLATE(@ARGV) {
    my @TARGETS = &expand($TEMPLATE);
    push @all_TARGETS,@TARGETS;

    # if we are in dep mode, print out dependencies
    if ($opts{'d'}) {
      print join(" ",@TARGETS),": $TEMPLATE\n";
      print "\t$0 $TEMPLATE\n\n";
    }
  }

  # if we are in dep mode, print a list of generated files
  if ($opts{'d'}) {
    my $all = join " ",@all_TARGETS;
    print "templex_OUT = $all\n\n";
  }
}

&main;
