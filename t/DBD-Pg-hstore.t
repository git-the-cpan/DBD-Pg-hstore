# Before `make install' is performed this script should be runnable with
# `make test'. After `make install' it should work as `perl DBD-Pg-hstore.t'

#########################

use strict;
use warnings;
use Data::Dumper;
use List::Util qw/shuffle/;

use Test::More tests=>67;
BEGIN { use_ok('DBD::Pg::hstore') };

#########################

# Insert your test code below, the Test::More module is use()ed here so read
# its man page ( perldoc Test::More ) for help writing this test script.

my ($t1, $t2);

#Simple working
$t1 = DBD::Pg::hstore::decode('"test"=>"2834", "123"=>NULL, "\\\\abc"=>"de\\f", "$test"=>"@var", "russian" => "онотоле отакуэ"');
ok( ref($t1) eq 'HASH', "ret is hashref");
is($t1->{test}, '2834');
is($t1->{'123'}, undef);
is($t1->{'\\abc'}, 'def');
is($t1->{'$test'}, '@var');
is($t1->{russian}, 'онотоле отакуэ');

#Empty encode
$t1 = DBD::Pg::hstore::encode({});
is($t1, '', 'empty hash test fail');

#Empty decode
$t1 = DBD::Pg::hstore::decode('');
is_deeply($t1, {});

#Full diff check
my $struct = {
	ba => 123,
	'123' => '321',
	none => undef,
	'-test' => '$dunno',
	'/whoot' => '\\thing',
	'russian' => 'Из Раши виз лав',
	'ключ' => 'значение'
};
$t1 = DBD::Pg::hstore::encode( $struct );
$t2 = DBD::Pg::hstore::decode($t1);
is_deeply($t2, $struct);

#Alone tests
foreach my $k (keys %$struct) {
	my $h = {$k => $struct->{$k}};
	$t1 = DBD::Pg::hstore::encode($h);
	$t2 = DBD::Pg::hstore::decode($t1);
	is_deeply($t2, $h);
}

#Random tests
my @chars = qw!a 7 \ / ' "!;
for(1..50) {
	my $h = {};
	for(1..5) {
		my $key = join("", map{$chars[rand @chars]}(1..5) );
		my $val = join("", map{$chars[rand @chars]}(0..int(rand(2))) );
		$h->{ $key } = $val;
	}
	$t1 = DBD::Pg::hstore::encode($h);
	$t2 = DBD::Pg::hstore::decode($t1);
	is_deeply($t2, $h);
}
