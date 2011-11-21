# Before `make install' is performed this script should be runnable with
# `make test'. After `make install' it should work as `perl DBD-Pg-hstore.t'

#########################

use strict;
use warnings;
use Data::Dumper;

use Test::More tests=>22;
BEGIN { use_ok('DBD::Pg::hstore') };

#########################

while( my $row = <DATA> ) {
	my $t1 = DBD::Pg::hstore::decode($row);

	my $srcrow=$row;
	$row  =~ s/\=\>\s*NULL/\=\>undef/gs;
	$row  =~ s/([\@\$\%])/\\$1/gs;
	my $t2 = eval "{$row}";
	is_deeply($t1, $t2, "Test string $srcrow");
}

my @addtests=(
	"\"win1251\" => \"\xc4\xee\xea\xee\xeb\xe5\x3f\"",
	"\"binary\" => \"\x07\x03\xdb\xdb\x7a\xa7\xda\xad\x49\x94\xa0\x0a\"",
	"\"tab\" =>\"\t\"",
	"\"\t\"=>\"tab\""
);
foreach my $row (@addtests) {
	my $t1 = DBD::Pg::hstore::decode($row);

	my $srcrow=$row;
	$row  =~ s/\=\>\s*NULL/\=\>undef/gs;
	$row  =~ s/([\@\$\%])/\\$1/gs;
	my $t2 = eval "{$row}";
	is_deeply($t1, $t2, "Test string $srcrow");
}


__DATA__
"test"=>"1"
"slash"=>"\\"
"doubleslash"=>"\\\\"
"quote"=>"\"",
"a" => "1" , "b"=>"2", "c" =>NULL,
"spec" => "~!@#$%^&*()_+|-=\\/';\",.[]{}:<>?`"
"russian" => "Доколе?",
"empty"=> "", "NULL"=>NULL

"1"=>"test"
"\\"	=>"slash"
"\\\\"=>"doubleslash"
"\""=>	"quote"
"~!@#$%^&*()_+|-=\\/';\",.[]{}:<>?`"=>"spec"
"Доколе?"=>"russian"

	"all"=> "2gether", "test"=>"1" , "empty"=> "","slash"=>"\\","doubleslash"=>"\\\\","quote"=>"\""   ,"a" => "1" , "b"=>"2", "c" =>NULL,"spec" => "~!@#$%^&*()_+|-=\\/';\",.[]{}:<>?`","russian" => "Доколе?","1"=>"test", "\\"=>"slash" , "\\\\"=>"doubleslash"  ,"\""=>"quote",    "~!@#$%^&*()_+|-=\\/';\",.[]{}:<>?`"=>"spec","Доколе?"=>"russian",