#!/usr/bin/perl -I../lib -I..

BEGIN {unshift(@INC, eval { my $x = $INC[0]; $x =~ s!/OOPS(.*)/blib/lib$!/OOPS$1/t!g ? $x : ()})}
BEGIN {
	$OOPS::SelfFilter::defeat = 1
		unless defined $OOPS::SelfFilter::defeat;
}
#BEGIN {
#	if ($ENV{HARNESS_ACTIVE} && ! $ENV{OOPSTEST_SLOW}) {
#		print "1..0 # Skip run this by hand or set \$ENV{OOPSTEST_SLOW}\n";
#		exit;
#	}
#}
BEGIN {
	for my $m (qw(Data::Dumper Clone::PP)) {
		unless ( eval " require $m " ) {
			print "1..0 # Skip this test requires the $m module\n";
			exit;
		}
		$m->import();
	}
}

import Clone::PP qw(clone);

use OOPS;
use Carp qw(confess);
use Scalar::Util qw(reftype);
use strict;
use warnings;
use diagnostics;

use OOPS::TestCommon;

modern_data_compare();

print "1..489\n";


resetall; # --------------------------------------------------
{
	my $tests = <<'END';
		VIRTUAL
		$root->{x} = 'y';
		COMMIT
		COMPARE

		VIRTUAL
		%$root = ();
		COMMIT
		COMPARE

		CP_VIRTUAL
		%$root = ();
		COMPARE
		COMMIT
		COMPARE
		$root->{a} = betterkeys(%$root);
		COMPARE
		COMMIT
		COMPARE
		$root->{b} = betterkeys(%$root);
		COMPARE
		COMMIT
		COMPARE
		$root->{c} = betterkeys(%$root);
		COMPARE
		COMMIT
		COMPARE
		$root->{d} = betterkeys(%$root);
		COMPARE
		COMMIT
		COMPARE
		$root->{e} = betterkeys(%$root);
		COMPARE
		COMMIT
		COMPARE
		$root->{f} = betterkeys(%$root);
		COMPARE
		COMMIT
		COMPARE
		delete $root->{b};
		delete $root->{c};
		$root->{g} = betterkeys(%$root);
		CP_COMMIT
		CP_COMPARE
		delete $root->{d};
		$root->{h} = betterkeys(%$root);
		$root->{i} = betterkeys(%$root);
		$root->{x} = 1;
		$root->{y} = 1;
		$root->{z} = 1;
		COMPARE
		COMMIT
		COMPARE
		delete $root->{x};
		delete $root->{y};
		delete $root->{z};
		$root->{h} = betterkeys(%$root);
		$root->{i} = betterkeys(%$root);
		COMPARE

		CP_VIRTUAL
		$tcTODO = "Mysql columns are a bit narrow" if $r1->{dbo}{dbms} eq 'mysql';
		%$root = ();
		my $x = getref(%$root, 'FOO23' x 57);
		$root->{'FOO23' x 57} = \$x;
		CP_COMMIT
		CP_COMPARE
		delete $root->{'FOO23' x 57};
		CP_COMPARE
		CP_COMMIT
		COMPARE

		$size:1,75
		#
		# This failed in upgrade1003.t.... Something works
		# in 1.004 that didn't work in 1.003.
		#
		my $x = 'fooadla' x $size;
		%$root = (
			skey => 'sval' x $size,
			rkey => \$x,
			akey => [ 'hv1' x $size ],
			hkey => { skey2 => 'sval2' x $size },
		);
		CP_COMMIT
		$root->{xy} = \$root->{akey}[0]
		CP_COMPARE
		CP_COMMIT
		CP_COMPARE
		delete $root->{akey}
		CP_COMPARE
		CP_COMMIT
		COMPARE

		# reference to self
		my $x;
		$x = \$x;
		%$root = ( x => $x );
		COMMIT
		COMPARE

		%$root = ();
		$root->{hkey}{skey2} = getref(%{$root->{hkey}}, 'skey348');
		CP_COMMIT
		CP_COMPARE
		$root->{xkey} = $root->{hkey}{skey2};
		COMMIT
		$root->{ykey} = $root->{hkey}{skey2};
		COMMIT
		$root->{zkey} = $root->{hkey}{skey2};
		CP_COMMIT
		delete $root->{hkey};
		CP_COMMIT
		COMPARE

		$x:0,1
		CP_VIRTUAL
		%$root = (
			hdaslj4 => { aslx => 'slda4x'},
		);
		$root->{xz1} = \$root->{hdaslj4};
		$root->{xz2} = \$root->{hdaslj4};
		COMMIT
		COMPARE
		delete $root->{hdaslj4};
		CP_COMMIT 
		${$root->{xz1}} = 'asdl4j';
		COMMIT
		COMPARE
		delete $root->{xz1};
		COMMIT
		COMPARE
		$root->{xz3} = $root->{xz2};
		COMMIT
		COMPARE
		delete $root->{xz2};
		COMPARE
		COMMIT
		COMPARE

		CP_VIRTUAL
		COMMIT
		$root->{xyz3} = \$root->{a}[0];
		CP_COMMIT
		CP_COMPARE
		delete $root->{a};
		CP_COMMIT
		COMPARE

		my ($a, $b, $c);
		$a = \$b;
		$b = \$c;
		$c = \$a;
		%$root = (
			a => \$a,
			b => \$b,
			c => \$c,
		);
		COMMIT
		COMPARE
		
		push(@{$root->{a}}, "\0\1" x 90);
		COMMIT
		COMPARE
		unshift(@{$root->{a}}, "laskdjfs" x 50);
		COMMIT
		COMPARE
END
	my $root = {
		h	=> {
			k	=> 'v',
		},
		a	=> [ 'av' ],
		r	=> \'sr',
	};
	supercross7($tests, { baseroot => $root });
}

print "# ---------------------------- done ---------------------------\n" if $debug;
$okay--;
print "# tests: $okay\n" if $debug;

exit 0; # ----------------------------------------------------

1;
__END__
