# Before `make install' is performed this script should be runnable with
# `make test'. After `make install' it should work as `perl test.pl'

######################### We start with some black magic to print on failure.

# Change 1..1 below to 1..last_test_to_print .
# (It may become useful if the test is moved to ./t subdirectory.)

use Test::More tests => 4;

BEGIN { $| = 1; }
use_ok(CRC);

######################### End of black magic.

# Insert your test code below (better if it prints "ok 13"
# (correspondingly "not ok 13") depending on the success of chunk 13
# of the test code):

my $input = "123456789";
my ($crc32,$crc16,$crcccitt) = (CRC::crc32($input),CRC::crc16($input),CRC::crcccitt($input));

ok($crc32 == 3421780262); 
ok($crcccitt == 10673); 
ok($crc16 == 47933); 

