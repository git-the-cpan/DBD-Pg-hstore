# Before `make install' is performed this script should be runnable with
# `make test'. After `make install' it should work as `perl DBD-Pg-hstore.t'

#########################

use strict;
use warnings;
use utf8;
use Encode qw/is_utf8/;
use Data::Dumper;
use List::Util qw/shuffle/;

use Test::More tests=>18;
BEGIN { use_ok('DBD::Pg::hstore') };

#########################

# Insert your test code below, the Test::More module is use()ed here so read
# its man page ( perldoc Test::More ) for help writing this test script.

#utf8 flag workaround (to bypass wide char warning)
my $builder = Test::More->builder;
binmode $builder->output,         ":utf8";
binmode $builder->failure_output, ":utf8";
binmode $builder->todo_output,    ":utf8";


my ($t1, $t2);

#utf8 decode tests
my $u = "онотоле отакуэ";
my $s = '"test"=>"2834", "123"=>NULL, "\\\\abc"=>"de\\f", "$test"=>"@var", "russian" => "'.$u.'"';
is( Encode::is_utf8($s), 1, 'utf8 flag test');
$t1 = DBD::Pg::hstore::decode($s);
ok( ref($t1) eq 'HASH', "ret is hashref");
is($t1->{test}, '2834');
is($t1->{'123'}, undef);
is($t1->{'\\abc'}, 'def');
is($t1->{'$test'}, '@var');
is(Encode::is_utf8($t1->{'$test'}), 1, 'utf8 flag test');
is(Encode::is_utf8($t1->{russian}), 1, 'utf8 flag test');
ok($t1->{russian} eq $u);

#utf8 encode tests
my $h = {
	'a' => 'значение',
	'b' => 'опять значение',
	'онотоле' => 'откауэ'
};

is( Encode::is_utf8($h->{a}), 1, 'utf8 flag test');
$t1 = DBD::Pg::hstore::encode($h);
is( Encode::is_utf8($t1), 1, 'utf8 flag test');

#backencode tests
$t2 = DBD::Pg::hstore::decode($t1);
#is_deeply($t1, $h); #Not working with flagged things ?!
foreach my $k (keys %$h) {
	ok($t2->{$k} eq $h->{$k}, "test key '$k'");
}
foreach my $k (keys %$t2) {
	ok($t2->{$k} eq $h->{$k}, "test key '$k'");
}
