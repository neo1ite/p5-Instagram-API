# Before 'make install' is performed this script should be runnable with
# 'make test'. After 'make install' it should work as 'perl Instagram-API.t'

#########################

# change 'tests => 1' to 'tests => last_test_to_print';

use utf8;
use strict;
use warnings;
use autouse 'Data::Dumper';

use URI::Escape;

use Test::More qw(no_plan);
BEGIN { use_ok('Instagram::API::Endpoints') };

is(Instagram::API::Endpoints::getAccountPageLink('test_name'),    'https://www.instagram.com/test_name');
is(Instagram::API::Endpoints::getAccountPageLink('тестовое_имя'), 'https://www.instagram.com/' . uri_escape_utf8('тестовое_имя'));

is(Instagram::API::Endpoints::getAccountJsonLink('test_user'),             'https://www.instagram.com/test_user/?__a=1');
is(Instagram::API::Endpoints::getAccountJsonLink('тестовый_пользователь'), 'https://www.instagram.com/' . uri_escape_utf8('тестовый_пользователь') . '/?__a=1');

is(Instagram::API::Endpoints::getAccountJsonInfoLinkByAccountId('1234567890_0987654321'), 'ig_user(1234567890_0987654321){id,username,external_url,full_name,profile_pic_url,biography,followed_by{count},follows{count},media{count},is_private,is_verified}');

is(Instagram::API::Endpoints::getAccountMediasJsonLink('user_test'),                     'https://www.instagram.com/user_test/media?max_id=');
is(Instagram::API::Endpoints::getAccountMediasJsonLink('пользователь_тест'),             'https://www.instagram.com/' . uri_escape_utf8('пользователь_тест') . '/media?max_id=');
is(Instagram::API::Endpoints::getAccountMediasJsonLink('user_test',         1234567890), 'https://www.instagram.com/user_test/media?max_id=1234567890');
is(Instagram::API::Endpoints::getAccountMediasJsonLink('пользователь_тест', 1234567890), 'https://www.instagram.com/' . uri_escape_utf8('пользователь_тест') . '/media?max_id=1234567890');

is(Instagram::API::Endpoints::getMediaPageLink('BOlShOeBlUE'), 'https://www.instagram.com/p/BOlShOeBlUE');

is(Instagram::API::Endpoints::getMediaJsonLink('BOlShOeBlUE'), 'https://www.instagram.com/p/BOlShOeBlUE/?__a=1');

is(Instagram::API::Endpoints::getMediasJsonByLocationIdLink(60969779),           'https://www.instagram.com/explore/locations/60969779/?__a=1&max_id=');
is(Instagram::API::Endpoints::getMediasJsonByLocationIdLink(60969779, 12345678), 'https://www.instagram.com/explore/locations/60969779/?__a=1&max_id=12345678');

is(Instagram::API::Endpoints::getMediasJsonByTagLink('perl'),              'https://www.instagram.com/explore/tags/perl/?__a=1&max_id=');
is(Instagram::API::Endpoints::getMediasJsonByTagLink('перл'),              'https://www.instagram.com/explore/tags/' . uri_escape_utf8('перл') . '/?__a=1&max_id=');
is(Instagram::API::Endpoints::getMediasJsonByTagLink('camel',   12345678), 'https://www.instagram.com/explore/tags/camel/?__a=1&max_id=12345678');
is(Instagram::API::Endpoints::getMediasJsonByTagLink('верблюд', 12345678), 'https://www.instagram.com/explore/tags/' . uri_escape_utf8('верблюд') . '/?__a=1&max_id=12345678');

is(Instagram::API::Endpoints::getGeneralSearchJsonLink('selfie'),  'https://www.instagram.com/web/search/topsearch/?query=selfie');
is(Instagram::API::Endpoints::getGeneralSearchJsonLink('себяшка'), 'https://www.instagram.com/web/search/topsearch/?query=' . uri_escape_utf8('себяшка'));

is(Instagram::API::Endpoints::getLastCommentsByCodeLink('CHuzHeStrAN', 20), 'ig_shortcode(CHuzHeStrAN){comments.last(20){count,nodes{id,created_at,text,user{id,profile_pic_url,username,follows{count},followed_by{count},biography,full_name,media{count},is_private,external_url,is_verified}},page_info}}');

is(Instagram::API::Endpoints::getCommentsBeforeCommentIdByCode('IgrIVaYAloS', 45, 1234567890), 'ig_shortcode(IgrIVaYAloS){comments.before(1234567890,45){count,nodes{id,created_at,text,user{id,profile_pic_url,username,follows{count},followed_by{count},biography,full_name,media{count},is_private,external_url,is_verified}},page_info}}');

is(Instagram::API::Endpoints::getLastLikesByCodeLink('MOarElIKeSS'), 'ig_shortcode(MOarElIKeSS){likes{nodes{id,user{id,profile_pic_url,username,follows{count},followed_by{count},biography,full_name,media{count},is_private,external_url,is_verified}},page_info}}');

#########################

# Insert your test code below, the Test::More module is use()ed here so read
# its man page ( perldoc Test::More ) for help writing this test script.
