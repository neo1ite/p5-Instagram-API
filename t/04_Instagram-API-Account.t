# Before 'make install' is performed this script should be runnable with
# 'make test'. After 'make install' it should work as 'perl Instagram-API.t'

#########################

# change 'tests => 1' to 'tests => last_test_to_print';

use utf8;
use strict;
use warnings;

use Scalar::Util qw/blessed/;

use Test::More qw(no_plan);
BEGIN { use_ok('Instagram::API::Account') };

my $user = Instagram::API::Account->new();

ok(blessed($user) && $user->isa('Instagram::API::Account'));

ok(exists($user->{id}));
ok(exists($user->{username}));
ok(exists($user->{fullName}));
ok(exists($user->{profilePicUrl}));
ok(exists($user->{biography}));
ok(exists($user->{externalUrl}));
ok(exists($user->{followsCount}));
ok(exists($user->{followedByCount}));
ok(exists($user->{mediaCount}));
ok(exists($user->{isPrivate}));
ok(exists($user->{isVerified}));

my $user_from_account_page = Instagram::API::Account->fromAccountPage({
    id              => 1234567890,
    username        => 'ne01ite',
    full_name       => 'Neolite',
    profile_pic_url => 'https://scontent-mia1-1.cdninstagram.com/t51.2885-19/11906329_960233084022564_1448528159_a.jpg',
    biography       => undef,
    external_url     => 'http://www.neolite.ru/',
    follows         => { count => 4 },
    followed_by     => { count => 10 },
    media           => { count => 0 },
    is_private      => 0,
    is_verified     => 0,
});

is($user_from_account_page->{id}, 1234567890);
is($user_from_account_page->{username}, 'ne01ite');
is($user_from_account_page->{fullName}, 'Neolite');
is($user_from_account_page->{profilePicUrl}, 'https://scontent-mia1-1.cdninstagram.com/t51.2885-19/11906329_960233084022564_1448528159_a.jpg');
is($user_from_account_page->{biography}, undef);
is($user_from_account_page->{externalUrl}, 'http://www.neolite.ru/');
is($user_from_account_page->{followsCount}, 4);
is($user_from_account_page->{followedByCount}, 10);
is($user_from_account_page->{mediaCount}, 0);
is($user_from_account_page->{isPrivate}, 0);
is($user_from_account_page->{isVerified}, 0);

my $user_from_media_page = Instagram::API::Account->fromMediaPage({
    id              => 1234567890,
    username        => 'ne01ite',
    full_name       => 'Neolite',
    profile_pic_url => 'https://scontent-mia1-1.cdninstagram.com/t51.2885-19/11906329_960233084022564_1448528159_a.jpg',
    is_private      => 0,
});

is($user_from_media_page->{id}, 1234567890);
is($user_from_media_page->{username}, 'ne01ite');
is($user_from_media_page->{fullName}, 'Neolite');
is($user_from_media_page->{profilePicUrl}, 'https://scontent-mia1-1.cdninstagram.com/t51.2885-19/11906329_960233084022564_1448528159_a.jpg');
is($user_from_media_page->{isPrivate}, 0);

my $user_from_search_page = Instagram::API::Account->fromSearchPage({
    pk              => 1234567890,
    username        => 'ne01ite',
    full_name       => 'Neolite',
    profile_pic_url => 'https://scontent-mia1-1.cdninstagram.com/t51.2885-19/11906329_960233084022564_1448528159_a.jpg',
    follower_count  => 100,
    is_private      => 1,
    is_verified     => 1,
});

is($user_from_search_page->{id}, 1234567890);
is($user_from_search_page->{username}, 'ne01ite');
is($user_from_search_page->{fullName}, 'Neolite');
is($user_from_search_page->{profilePicUrl}, 'https://scontent-mia1-1.cdninstagram.com/t51.2885-19/11906329_960233084022564_1448528159_a.jpg');
is($user_from_search_page->{followedByCount}, 100);
is($user_from_search_page->{isPrivate}, 1);
is($user_from_search_page->{isVerified}, 1);

#########################

# Insert your test code below, the Test::More module is use()ed here so read
# its man page ( perldoc Test::More ) for help writing this test script.
