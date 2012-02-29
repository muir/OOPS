#!/usr/bin/perl -I../lib -I..

BEGIN {unshift(@INC, eval { my $x = $INC[0]; $x =~ s!/OOPS(.*)/blib/lib$!/OOPS$1/t!g ? $x : ()})}
BEGIN {
	no warnings;
	$OOPS::SelfFilter::defeat = 0;
}

$ENV{OOPSTEST_SLOW} = 1; 

require "t/integrety.t";

1;
