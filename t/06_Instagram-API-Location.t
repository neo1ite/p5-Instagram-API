# Before 'make install' is performed this script should be runnable with
# 'make test'. After 'make install' it should work as 'perl Instagram-API.t'

#########################

# change 'tests => 1' to 'tests => last_test_to_print';

use utf8;
use strict;
use warnings;

use Scalar::Util qw/blessed/;

use Test::More qw(no_plan);
BEGIN { use_ok('Instagram::API::Location') };

my $location = Instagram::API::Location->new();

ok(blessed($location) && $location->isa('Instagram::API::Location'));

ok(exists($location->{id}));
ok(exists($location->{name}));
ok(exists($location->{lat}));
ok(exists($location->{lng}));

my $maked_location = Instagram::API::Location->makeLocation({ id => 1, name => 'test_tag', lat => 45.4081687, lng => -123.0079566 });
is($maked_location->{id}, 1);
is($maked_location->{name}, 'test_tag');
is($maked_location->{lat}, 45.4081687);
is($maked_location->{lng}, -123.0079566);

#########################

# Insert your test code below, the Test::More module is use()ed here so read
# its man page ( perldoc Test::More ) for help writing this test script.
