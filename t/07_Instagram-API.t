# Before 'make install' is performed this script should be runnable with
# 'make test'. After 'make install' it should work as 'perl Instagram-API.t'

#########################

# change 'tests => 1' to 'tests => last_test_to_print';

use utf8;
use strict;
use warnings;
use Data::Dumper;

use Scalar::Util qw/blessed/;

use Test::More qw(no_plan);
BEGIN { use_ok('Instagram::API') };

my $instagram = Instagram::API->new();

ok(blessed($instagram) && $instagram->isa('Instagram::API'), 'Instagram::API object creation');
ok(blessed($instagram->{browser}) && $instagram->{browser}->isa('LWP::UserAgent'), 'LWP::UserAgent object creation');

my $r = $instagram->{browser}->get('https://www.instagram.com/');

SKIP: {
    skip 'No connection with Instragram.com', 6 unless ($r && $r->code == 200);

    my $user_by_name = $instagram->getAccount('ne01ite');
    ok(blessed($user_by_name) && $user_by_name->isa('Instagram::API::Account'), 'Getting account by name #1');
    is($user_by_name->{username}, 'ne01ite',    'Getting account by name #2');
    is($user_by_name->{id},       '1838386734', 'Getting account by name #3');

    my $user_by_id = $instagram->getAccountById(1838386734);

    ok(blessed($user_by_id) && $user_by_id->isa('Instagram::API::Account'), 'Getting account by ID');
    is($user_by_id->{id},       '1838386734', 'Getting account by name #2');
    is($user_by_id->{username}, 'ne01ite',    'Getting account by name #3');
};

#########################

# Insert your test code below, the Test::More module is use()ed here so read
# its man page ( perldoc Test::More ) for help writing this test script.

