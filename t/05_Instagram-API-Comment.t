# Before 'make install' is performed this script should be runnable with
# 'make test'. After 'make install' it should work as 'perl Instagram-API.t'

#########################

# change 'tests => 1' to 'tests => last_test_to_print';

use utf8;
use strict;
use warnings;

use Scalar::Util qw/blessed/;

use Test::More qw(no_plan);
BEGIN { use_ok('Instagram::API::Comment') };

my $comment = Instagram::API::Comment->new();

ok(blessed($comment) && $comment->isa('Instagram::API::Comment'));

ok(exists($comment->{id}));
ok(exists($comment->{user}));
ok(exists($comment->{text}));
ok(exists($comment->{createdAt}));

my $comment_from_api = Instagram::API::Comment->fromApi({
    id         => 1234567890,
    user       => {},
    text       => 'Timeo Danaos et dona ferentes',
    created_at => '2017-01-30 20:30:00'
});
is($comment_from_api->{id}, 1234567890);
ok($comment_from_api->{user} && blessed($comment_from_api->{user}) && $comment_from_api->{user}->isa('Instagram::API::Account'));
is($comment_from_api->{text}, 'Timeo Danaos et dona ferentes');
is($comment_from_api->{createdAt}, '2017-01-30 20:30:00');

#########################

# Insert your test code below, the Test::More module is use()ed here so read
# its man page ( perldoc Test::More ) for help writing this test script.
