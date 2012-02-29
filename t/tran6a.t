#!/usr/bin/perl -I../lib -I.. -I../Test-MultiFork/blib/lib

BEGIN {unshift(@INC, eval { my $x = $INC[0]; $x =~ s!/OOPS(.*)/blib/lib$!/OOPS$1/t!g ? $x : ()})}
BEGIN {
	$OOPS::SelfFilter::defeat = 1
		unless defined $OOPS::SelfFilter::defeat;
}

use OOPS;
use Carp qw(confess);
use Scalar::Util qw(reftype);
use strict;
use warnings;
use diagnostics;

use OOPS::TestCommon;
use Clone::PP qw(clone);

modern_data_compare();
BEGIN {
	unless (eval { require Test::MultiFork }) {
		print "1..0 # Skip this test requires Test::MultiFork\n";
		exit;
	}

	$Test::MultiFork::inactivity = 60; 
	import Test::MultiFork qw(stderr bail_on_bad_plan);
}

my $itarations = 200;
$itarations /= 10 unless $ENV{OOPSTEST_SLOW};
if ($ENV{OOPSTEST_DSN} && $ENV{OOPSTEST_DSN} =~ /^dbi:mysql/i) {
	printf STDERR "# mysql is very slow at this test, reducing iterations from %d to %d\n",
		$itarations, $itarations / 20;
	$itarations = int($itarations/20);
}

my $common;
$debug = 1;

# 
# simple test of transaction()
#

FORK_ab:

ab:
my $pn = (procname())[1];

a:
lockcommon;
setcommon({ values => {} });
unlockcommon;

ab:

# --------------------------------------------------
for my $x (1..$itarations) {
a:
	print "# #############################################################################################\n" if $debug;
	printf "# at %d\n", __LINE__ if $debug;
	resetall; 
	$r1->{named_objects}{root} = {
		a => 1,
		b => 2,
		c => 4,
		d => 8,
		e => 16,
		f => 32,
	};
	$r1->commit;
	nocon;
	printf "# at %d\n", __LINE__ if $debug;
ab:
	printf "# at %d\n", __LINE__ if $debug;
	my $sum = 0;
	for(;;) {
		my $done;
		my $did = 0;
		transaction(sub {
			$did = 0;
			rcon;
			my $todo = $r1->{named_objects}{root};
			my $x = %$todo;
			print "# Remaining: $x\n";
			if ($x) {
				my ($k, $v) = each(%$todo);
				$r1->lock(\$todo->{$k});
				delete $todo->{$k};
				$did += $v;
				$r1->commit();
			} else {
				$done = 1;
			}
		});
		last if $done;
		$sum += $did;
		print "# $pn did $did\n";
		nocon;
	}
	nocon;
	printf "# at %d\n", __LINE__ if $debug;
ab:
	printf "# at %d\n", __LINE__ if $debug;
	lockcommon();
	$common = getcommon;
	$common->{values}{$pn} = $sum;
	print "# my total: $sum\n" if $debug;
	setcommon($common);
	unlockcommon();
	printf "# at %d\n", __LINE__ if $debug;
a:
	printf "# at %d\n", __LINE__ if $debug;
	lockcommon();
	$common = getcommon;
	my $total = 0;
	for my $n (keys %{$common->{values}}) {
		print "# total from $n: $common->{values}{$n}\n";
		$total += $common->{values}{$n};
	}
	test($total == 63, "Each item handled once");
	unlockcommon();
	printf "# at %d\n", __LINE__ if $debug;
ab:
}

print "# ---------------------------- done ---------------------------\n" if $debug;
$okay--;
print "1..$okay\n";

exit 0; # ----------------------------------------------------

1;
