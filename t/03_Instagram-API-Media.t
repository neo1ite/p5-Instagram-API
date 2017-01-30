# Before 'make install' is performed this script should be runnable with
# 'make test'. After 'make install' it should work as 'perl Instagram-API.t'

#########################

# change 'tests => 1' to 'tests => last_test_to_print';

use utf8;
use strict;
use warnings;

use Test::More qw(no_plan);
BEGIN { use_ok('Instagram::API::Media') };

#########################

# Insert your test code below, the Test::More module is use()ed here so read
# its man page ( perldoc Test::More ) for help writing this test script.
