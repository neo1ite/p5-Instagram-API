# Before 'make install' is performed this script should be runnable with
# 'make test'. After 'make install' it should work as 'perl Instagram-API.t'

#########################

# change 'tests => 1' to 'tests => last_test_to_print';

use utf8;
use strict;
use warnings;

use Test::More qw(no_plan);
BEGIN { use_ok('Instagram::API::Endpoints') };

is(Instagram::API::Endpoints::getAccountPageLink('test_name'), 'https://www.instagram.com/test_name');
is(Instagram::API::Endpoints::getAccountPageLink('тестовое_имя'), 'https://www.instagram.com/%D1%82%D0%B5%D1%81%D1%82%D0%BE%D0%B2%D0%BE%D0%B5_%D0%B8%D0%BC%D1%8F');

is(Instagram::API::Endpoints::getAccountJsonLink('test_user'), 'https://www.instagram.com/test_user/?__a=1');
is(Instagram::API::Endpoints::getAccountJsonLink('тестовый_пользователь'), 'https://www.instagram.com/%D1%82%D0%B5%D1%81%D1%82%D0%BE%D0%B2%D1%8B%D0%B9_%D0%BF%D0%BE%D0%BB%D1%8C%D0%B7%D0%BE%D0%B2%D0%B0%D1%82%D0%B5%D0%BB%D1%8C/?__a=1');

is(Instagram::API::Endpoints::getAccountJsonInfoLinkByAccountId('1234567890_0987654321'), 'ig_user(1234567890_0987654321){id,username,external_url,full_name,profile_pic_url,biography,followed_by{count},follows{count},media{count},is_private,is_verified}');

#########################

# Insert your test code below, the Test::More module is use()ed here so read
# its man page ( perldoc Test::More ) for help writing this test script.
