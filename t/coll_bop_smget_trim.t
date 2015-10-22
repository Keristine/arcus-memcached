#!/usr/bin/perl

use strict;
use Test::More tests => 69;
use FindBin qw($Bin);
use lib "$Bin/lib";
use MemcachedTest;

my $server = new_memcached();
my $sock = $server->sock;

my $cmd;
my $val;
my $rst;

=head
bop insert bkey1 90 6 create 11 0 0
datum9
bop insert bkey1 70 6
datum7
bop insert bkey1 50 6
datum5
bop insert bkey1 30 6
datum3
bop insert bkey1 10 6
datum1
bop insert bkey2 100 7 create 11 0 0
datum10
bop insert bkey2 80 6
datum8
bop insert bkey2 60 6
datum6
bop insert bkey2 40 6
datum4
bop insert bkey2 20 6
datum2
bop get bkey1 0..100
bop get bkey2 0..100
bop smget 11 2 0..100 5
bkey1,bkey2
bop smget 23 4 0..100 2 6
bkey2,bkey3,bkey1,bkey4
bop smget 23 4 90..30 2 9
bkey2,bkey3,bkey1,bkey4
bop smget 23 4 200..300 2 6
bkey2,bkey3,bkey1,bkey4
set keyx 0 0 6
datumx
bop smget 28 5 0..100 2 6
bkey2,bkey3,bkey1,bkey4,keyx
bop smget 29 5 0..100 2 6
bkey2,bkey3,bkey1,bkey4,bkey1
bop smget 29 5 0..100 2 6
bkey2,bkey3,bkey1,bkey4,bkey3
bop smget 23 2 0..100 2 6
bkey2,bkey3,bkey1,bkey4

delete bkey1
delete bkey2
=cut


# testBOPSMGetSimple
$cmd = "get bkey1"; $rst = "END";
print $sock "$cmd\r\n"; is(scalar <$sock>, "$rst\r\n", "$cmd: $rst");
$cmd = "get bkey2"; $rst = "END";
print $sock "$cmd\r\n"; is(scalar <$sock>, "$rst\r\n", "$cmd: $rst");
$cmd = "bop create bkey1 11 0 0"; $rst = "CREATED";
print $sock "$cmd\r\n"; is(scalar <$sock>, "$rst\r\n", "$cmd: $rst");
$cmd = "setattr bkey1 maxcount=5"; $rst = "OK";
print $sock "$cmd\r\n"; is(scalar <$sock>, "$rst\r\n", "$cmd: $rst");
$cmd = "bop insert bkey1 10 6"; $val = "datum1"; $rst = "STORED";
print $sock "$cmd\r\n$val\r\n"; is(scalar <$sock>, "$rst\r\n", "$cmd $val: $rst");
$cmd = "bop insert bkey1 20 6"; $val = "datum2"; $rst = "STORED";
print $sock "$cmd\r\n$val\r\n"; is(scalar <$sock>, "$rst\r\n", "$cmd $val: $rst");
$cmd = "bop insert bkey1 30 6"; $val = "datum3"; $rst = "STORED";
print $sock "$cmd\r\n$val\r\n"; is(scalar <$sock>, "$rst\r\n", "$cmd $val: $rst");
$cmd = "bop insert bkey1 40 6"; $val = "datum4"; $rst = "STORED";
print $sock "$cmd\r\n$val\r\n"; is(scalar <$sock>, "$rst\r\n", "$cmd $val: $rst");
$cmd = "bop insert bkey1 50 6"; $val = "datum5"; $rst = "STORED";
print $sock "$cmd\r\n$val\r\n"; is(scalar <$sock>, "$rst\r\n", "$cmd $val: $rst");
$cmd = "bop insert bkey1 70 6"; $val = "datum7"; $rst = "STORED";
print $sock "$cmd\r\n$val\r\n"; is(scalar <$sock>, "$rst\r\n", "$cmd $val: $rst");
$cmd = "bop insert bkey1 90 6"; $val = "datum9"; $rst = "STORED";
print $sock "$cmd\r\n$val\r\n"; is(scalar <$sock>, "$rst\r\n", "$cmd $val: $rst");
bop_get_is($sock, "bkey1 0..100", 11, 5, "30,40,50,70,90",
                  "datum3,datum4,datum5,datum7,datum9", "TRIMMED");
bop_get_is($sock, "bkey1 100..0", 11, 5, "90,70,50,40,30",
                  "datum9,datum7,datum5,datum4,datum3", "TRIMMED");
bop_get_is($sock, "bkey1 30..100", 11, 5, "30,40,50,70,90",
                  "datum3,datum4,datum5,datum7,datum9", "END");
$cmd = "bop create bkey2 12 0 0"; $rst = "CREATED";
print $sock "$cmd\r\n"; is(scalar <$sock>, "$rst\r\n", "$cmd: $rst");
$cmd = "setattr bkey2 maxcount=5"; $rst = "OK";
print $sock "$cmd\r\n"; is(scalar <$sock>, "$rst\r\n", "$cmd: $rst");
$cmd = "bop insert bkey2 20 6"; $val = "datum2"; $rst = "STORED";
print $sock "$cmd\r\n$val\r\n"; is(scalar <$sock>, "$rst\r\n", "$cmd $val: $rst");
$cmd = "bop insert bkey2 40 6"; $val = "datum4"; $rst = "STORED";
print $sock "$cmd\r\n$val\r\n"; is(scalar <$sock>, "$rst\r\n", "$cmd $val: $rst");
$cmd = "bop insert bkey2 60 6"; $val = "datum6"; $rst = "STORED";
print $sock "$cmd\r\n$val\r\n"; is(scalar <$sock>, "$rst\r\n", "$cmd $val: $rst");
$cmd = "bop insert bkey2 80 6"; $val = "datum8"; $rst = "STORED";
print $sock "$cmd\r\n$val\r\n"; is(scalar <$sock>, "$rst\r\n", "$cmd $val: $rst");
$cmd = "bop insert bkey2 100 7"; $val = "datum10"; $rst = "STORED";
print $sock "$cmd\r\n$val\r\n"; is(scalar <$sock>, "$rst\r\n", "$cmd $val: $rst");
bop_get_is($sock, "bkey2 0..100", 12, 5, "20,40,60,80,100", "datum2,datum4,datum6,datum8,datum10", "END");
bop_new_smget_is($sock, "11 2 0..100 5", "bkey1,bkey2",
5,
"bkey2 12 20 6 datum2
,bkey2 12 40 6 datum4
,bkey2 12 60 6 datum6
,bkey2 12 80 6 datum8
,bkey2 12 100 7 datum10",
1,
"bkey1 OUT_OF_RANGE",
0, "",
"END");
bop_new_smget_is($sock, "11 2 100..0 10", "bkey1,bkey2",
10,
"bkey2 12 100 7 datum10
,bkey1 11 90 6 datum9
,bkey2 12 80 6 datum8
,bkey1 11 70 6 datum7
,bkey2 12 60 6 datum6
,bkey1 11 50 6 datum5
,bkey2 12 40 6 datum4
,bkey1 11 40 6 datum4
,bkey1 11 30 6 datum3
,bkey2 12 20 6 datum2",
0, "",
1,
"bkey1 30",
"DUPLICATED");
bop_new_smget_is($sock, "23 4 0..100 2 6", "bkey2,bkey3,bkey1,bkey4",
3,
"bkey2 12 60 6 datum6
,bkey2 12 80 6 datum8
,bkey2 12 100 7 datum10",
3,
"bkey3 NOT_FOUND
,bkey1 OUT_OF_RANGE
,bkey4 NOT_FOUND",
0, "",
"END");
bop_new_smget_is($sock, "23 4 90..30 2 9", "bkey2,bkey3,bkey1,bkey4",
6,
"bkey1 11 70 6 datum7
,bkey2 12 60 6 datum6
,bkey1 11 50 6 datum5
,bkey2 12 40 6 datum4
,bkey1 11 40 6 datum4
,bkey1 11 30 6 datum3",
2,
"bkey3 NOT_FOUND
,bkey4 NOT_FOUND",
0, "",
"DUPLICATED");
bop_new_smget_is($sock, "23 4 30..90 2 9", "bkey2,bkey3,bkey1,bkey4",
6,
"bkey2 12 40 6 datum4
,bkey1 11 50 6 datum5
,bkey2 12 60 6 datum6
,bkey1 11 70 6 datum7
,bkey2 12 80 6 datum8
,bkey1 11 90 6 datum9",
2,
"bkey3 NOT_FOUND
,bkey4 NOT_FOUND",
0, "",
"DUPLICATED");
bop_new_smget_is($sock, "23 4 100..0 2 9", "bkey2,bkey3,bkey1,bkey4",
8,
"bkey2 12 80 6 datum8
,bkey1 11 70 6 datum7
,bkey2 12 60 6 datum6
,bkey1 11 50 6 datum5
,bkey2 12 40 6 datum4
,bkey1 11 40 6 datum4
,bkey1 11 30 6 datum3
,bkey2 12 20 6 datum2",
2,
"bkey3 NOT_FOUND
,bkey4 NOT_FOUND",
1,
"bkey1 30",
"DUPLICATED");
bop_new_smget_is($sock, "23 4 200..300 2 6", "bkey2,bkey3,bkey1,bkey4",
0, "",
2,
"bkey3 NOT_FOUND
,bkey4 NOT_FOUND",
0, "",
"END");
bop_new_smget_is($sock, "11 2 40..0 4 10", "bkey1,bkey2",
0, "",
0, "",
1,
"bkey1 30",
"DUPLICATED");
=head
$cmd = "bop smget 11 2 40..0 4 10"; $val = "bkey1,bkey2"; $rst = "OUT_OF_RANGE";
print $sock "$cmd\r\n$val\r\n"; is(scalar <$sock>, "$rst\r\n", "$cmd $val: $rst");
=cut


$cmd = "set keyx 19 5 10"; $val = "some value"; $rst = "STORED";
print $sock "$cmd\r\n$val\r\n"; is(scalar <$sock>, "$rst\r\n", "$cmd $val: $rst");
$cmd = "bop smget 23 2 0..100 2 6"; $val = "bkey2,bkey3,bkey1,bkey4"; $rst = "CLIENT_ERROR bad data chunk";
print $sock "$cmd\r\n$val\r\n"; is(scalar <$sock>, "$rst\r\n", "$cmd $val: $rst");
$cmd = "bop smget 28 5 0..100 2 6"; $val = "bkey2,bkey3,bkey1,bkey4,keyx"; $rst = "TYPE_MISMATCH";
print $sock "$cmd\r\n$val\r\n"; is(scalar <$sock>, "$rst\r\n", "$cmd $val: $rst");
$cmd = "bop smget 29 5 0..100 2 6"; $val = "bkey2,bkey3,bkey2,bkey4,bkey1"; $rst = "CLIENT_ERROR bad data chunk";
print $sock "$cmd\r\n$val\r\n"; is(scalar <$sock>, "$rst\r\n", "$cmd $val: $rst");
bop_new_smget_is($sock, "29 5 0..100 2 6", "bkey2,bkey3,bkey1,bkey4,bkey1",
3,
"bkey2 12 60 6 datum6
,bkey2 12 80 6 datum8
,bkey2 12 100 7 datum10",
4,
"bkey3 NOT_FOUND
,bkey1 OUT_OF_RANGE
,bkey4 NOT_FOUND
,bkey1 OUT_OF_RANGE",
0, "",
"END");
bop_new_smget_is($sock, "29 5 0..100 2 6", "bkey2,bkey3,bkey1,bkey4,bkey3",
3,
"bkey2 12 60 6 datum6
,bkey2 12 80 6 datum8
,bkey2 12 100 7 datum10",
4,
"bkey3 NOT_FOUND
,bkey1 OUT_OF_RANGE
,bkey4 NOT_FOUND
,bkey3 NOT_FOUND",
0, "",
"END");

$cmd = "delete keyx"; $rst = "DELETED";
print $sock "$cmd\r\n"; is(scalar <$sock>, "$rst\r\n", "$cmd: $rst");
$cmd = "delete bkey1"; $rst = "DELETED";
print $sock "$cmd\r\n"; is(scalar <$sock>, "$rst\r\n", "$cmd: $rst");
$cmd = "delete bkey2"; $rst = "DELETED";
print $sock "$cmd\r\n"; is(scalar <$sock>, "$rst\r\n", "$cmd: $rst");

$cmd = "bop create bkey1 0 0 2"; $rst = "CREATED";
print $sock "$cmd\r\n"; is(scalar <$sock>, "$rst\r\n", "$cmd: $rst");
$cmd = "bop create bkey2 0 0 2"; $rst = "CREATED";
print $sock "$cmd\r\n"; is(scalar <$sock>, "$rst\r\n", "$cmd: $rst");
$cmd = "bop create bkey3 0 0 2"; $rst = "CREATED";
print $sock "$cmd\r\n"; is(scalar <$sock>, "$rst\r\n", "$cmd: $rst");
$cmd = "bop create bkey4 0 0 2"; $rst = "CREATED";
print $sock "$cmd\r\n"; is(scalar <$sock>, "$rst\r\n", "$cmd: $rst");
$cmd = "bop create bkey5 0 0 2"; $rst = "CREATED";
print $sock "$cmd\r\n"; is(scalar <$sock>, "$rst\r\n", "$cmd: $rst");
$cmd = "bop insert bkey1 11 7"; $val = "datum11"; $rst = "STORED";
print $sock "$cmd\r\n$val\r\n"; is(scalar <$sock>, "$rst\r\n", "$cmd $val: $rst");
$cmd = "bop insert bkey2 12 7"; $val = "datum12"; $rst = "STORED";
print $sock "$cmd\r\n$val\r\n"; is(scalar <$sock>, "$rst\r\n", "$cmd $val: $rst");
$cmd = "bop insert bkey3 13 7"; $val = "datum13"; $rst = "STORED";
print $sock "$cmd\r\n$val\r\n"; is(scalar <$sock>, "$rst\r\n", "$cmd $val: $rst");
$cmd = "bop insert bkey4 14 7"; $val = "datum14"; $rst = "STORED";
print $sock "$cmd\r\n$val\r\n"; is(scalar <$sock>, "$rst\r\n", "$cmd $val: $rst");
$cmd = "bop insert bkey5 15 7"; $val = "datum15"; $rst = "STORED";
print $sock "$cmd\r\n$val\r\n"; is(scalar <$sock>, "$rst\r\n", "$cmd $val: $rst");
$cmd = "bop insert bkey1 16 7"; $val = "datum16"; $rst = "STORED";
print $sock "$cmd\r\n$val\r\n"; is(scalar <$sock>, "$rst\r\n", "$cmd $val: $rst");
$cmd = "bop insert bkey2 17 7"; $val = "datum17"; $rst = "STORED";
print $sock "$cmd\r\n$val\r\n"; is(scalar <$sock>, "$rst\r\n", "$cmd $val: $rst");
$cmd = "bop insert bkey3 18 7"; $val = "datum18"; $rst = "STORED";
print $sock "$cmd\r\n$val\r\n"; is(scalar <$sock>, "$rst\r\n", "$cmd $val: $rst");
$cmd = "bop insert bkey4 19 7"; $val = "datum19"; $rst = "STORED";
print $sock "$cmd\r\n$val\r\n"; is(scalar <$sock>, "$rst\r\n", "$cmd $val: $rst");
$cmd = "bop insert bkey5 20 7"; $val = "datum20"; $rst = "STORED";
print $sock "$cmd\r\n$val\r\n"; is(scalar <$sock>, "$rst\r\n", "$cmd $val: $rst");
$cmd = "bop insert bkey1 21 7"; $val = "datum21"; $rst = "STORED";
print $sock "$cmd\r\n$val\r\n"; is(scalar <$sock>, "$rst\r\n", "$cmd $val: $rst");
$cmd = "bop insert bkey2 22 7"; $val = "datum22"; $rst = "STORED";
print $sock "$cmd\r\n$val\r\n"; is(scalar <$sock>, "$rst\r\n", "$cmd $val: $rst");
$cmd = "bop insert bkey3 23 7"; $val = "datum23"; $rst = "STORED";
print $sock "$cmd\r\n$val\r\n"; is(scalar <$sock>, "$rst\r\n", "$cmd $val: $rst");
$cmd = "bop insert bkey4 24 7"; $val = "datum24"; $rst = "STORED";
print $sock "$cmd\r\n$val\r\n"; is(scalar <$sock>, "$rst\r\n", "$cmd $val: $rst");
bop_new_smget_is($sock, "29 5 24..11 14", "bkey1,bkey2,bkey3,bkey4,bkey5",
10,
"bkey4 0 24 7 datum24
,bkey3 0 23 7 datum23
,bkey2 0 22 7 datum22
,bkey1 0 21 7 datum21
,bkey5 0 20 7 datum20
,bkey4 0 19 7 datum19
,bkey3 0 18 7 datum18
,bkey2 0 17 7 datum17
,bkey1 0 16 7 datum16
,bkey5 0 15 7 datum15",
0, "",
4,
"bkey4 19
,bkey3 18
,bkey2 17
,bkey1 16",
"END");
bop_new_smget_is($sock, "29 5 11..24 14", "bkey1,bkey2,bkey3,bkey4,bkey5",
2,
"bkey5 0 15 7 datum15
,bkey5 0 20 7 datum20",
4,
"bkey1 OUT_OF_RANGE
,bkey2 OUT_OF_RANGE
,bkey3 OUT_OF_RANGE
,bkey4 OUT_OF_RANGE",
0, "",
"END");
$cmd = "bop insert bkey1 23 7"; $val = "datum23"; $rst = "STORED";
print $sock "$cmd\r\n$val\r\n"; is(scalar <$sock>, "$rst\r\n", "$cmd $val: $rst");
$cmd = "bop insert bkey2 23 7"; $val = "datum23"; $rst = "STORED";
print $sock "$cmd\r\n$val\r\n"; is(scalar <$sock>, "$rst\r\n", "$cmd $val: $rst");
bop_new_smget_is($sock, "29 5 24..11 14", "bkey1,bkey2,bkey3,bkey4,bkey5",
10,
"bkey4 0 24 7 datum24
,bkey3 0 23 7 datum23
,bkey2 0 23 7 datum23
,bkey1 0 23 7 datum23
,bkey2 0 22 7 datum22
,bkey1 0 21 7 datum21
,bkey5 0 20 7 datum20
,bkey4 0 19 7 datum19
,bkey3 0 18 7 datum18
,bkey5 0 15 7 datum15",
0, "",
4,
"bkey2 22
,bkey1 21
,bkey4 19
,bkey3 18",
"DUPLICATED");
bop_new_smget_is($sock, "29 5 11..24 14", "bkey1,bkey2,bkey3,bkey4,bkey5",
2,
"bkey5 0 15 7 datum15
,bkey5 0 20 7 datum20",
4,
"bkey1 OUT_OF_RANGE
,bkey2 OUT_OF_RANGE
,bkey3 OUT_OF_RANGE
,bkey4 OUT_OF_RANGE",
0, "",
"END");
$cmd = "delete bkey1"; $rst = "DELETED";
print $sock "$cmd\r\n"; is(scalar <$sock>, "$rst\r\n", "$cmd: $rst");
$cmd = "delete bkey2"; $rst = "DELETED";
print $sock "$cmd\r\n"; is(scalar <$sock>, "$rst\r\n", "$cmd: $rst");
$cmd = "delete bkey3"; $rst = "DELETED";
print $sock "$cmd\r\n"; is(scalar <$sock>, "$rst\r\n", "$cmd: $rst");
$cmd = "delete bkey4"; $rst = "DELETED";
print $sock "$cmd\r\n"; is(scalar <$sock>, "$rst\r\n", "$cmd: $rst");
$cmd = "delete bkey5"; $rst = "DELETED";
print $sock "$cmd\r\n"; is(scalar <$sock>, "$rst\r\n", "$cmd: $rst");
