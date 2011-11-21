# Before `make install' is performed this script should be runnable with
# `make test'. After `make install' it should work as `perl DBD-Pg-hstore.t'

#########################

use strict;
use warnings;
use Data::Dumper;

use Test::More tests=>5;
BEGIN { use_ok('DBD::Pg::hstore') };

#########################

my @tests = (
	{
		win1251 => "\xc4\xee\xea\xee\xeb\xe5\x3f",
		binary  => "\x07\x03\xdb\xdb\x7a\xa7\xda\xad\x49\x94\xa0\x0a",
		tab     => "\t",
		"\t"    => "tab"
	},
	{
		null    => undef,
		russian => "Доколе?",
		"Доколе?"=>"russian",
		"spec" => "~!@#$%^&*()_+|-=\\/';\",.[]{}:<>?`"
	},
	{
		null    => undef
	},
	{
		"~!@#$%^&*()_+|-=\\/';\",.[]{}:<>?`" => "\x07\x03\xdb\xdb\x7a\xa7\xda\xad\x49\x94\xa0\x0a"
	}
);

foreach my $test (@tests) {
	my $t1 = DBD::Pg::hstore::encode($test);
	my $t2 = DBD::Pg::hstore::decode($t1);
	is_deeply($t2, $test, "Test struct $t1");
}
