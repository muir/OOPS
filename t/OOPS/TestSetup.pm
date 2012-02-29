
package OOPS::TestSetup;

use strict;
use warnings;

sub import
{
	my ($pkg, @args) = @_;

	for my $a (@args) {
		if ($a eq ':filter') {
			$OOPS::SelfFilter::defeat = 1
				unless defined $OOPS::SelfFilter::defeat;
		} elsif ($a eq ':slow') {
			if ($ENV{HARNESS_ACTIVE} && ! $ENV{OOPSTEST_SLOW}) {
				print "1..0 # Skip run this by hand or set \$ENV{OOPSTEST_SLOW}\n";
				exit;
			}
		} elsif ($a =~ /^:/) {
			die "Bad import spec: $a";
		} else {
			unless ( eval " require $a " ) {
				print "1..0 # Skip this test requires the $a module\n";
				exit;
			}
		}
	}
}

1;
