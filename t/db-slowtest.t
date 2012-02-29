#!/usr/bin/perl -I../lib -I..

BEGIN {unshift(@INC, eval { my $x = $INC[0]; $x =~ s!/OOPS(.*)/blib/lib$!/OOPS$1/t!g ? $x : ()})}
BEGIN {
	no warnings;
	$OOPS::SelfFilter::defeat = 1;
}
BEGIN {
	if ($ENV{HARNESS_ACTIVE} && ! $ENV{OOPSTEST_SLOW}) {
		print "1..0 # Skip run this by hand or set \$ENV{OOPSTEST_SLOW}\n";
		exit;
	}
}

require "t/slowtest.t";

1;
