# Before 'make install' is performed this script should be runnable with
# 'make test'. After 'make install' it should work as 'perl Instagram-API.t'

#########################

# change 'tests => 1' to 'tests => last_test_to_print';

use utf8;
use strict;
use warnings;
use autouse 'Data::Dumper';

use Scalar::Util qw/blessed/;

use Test::More qw(no_plan);
BEGIN { use_ok('Instagram::API::Tag') };

my $tag = Instagram::API::Tag->new();

ok(blessed($tag) && $tag->isa('Instagram::API::Tag'));

ok(exists($tag->{mediaCount}));
ok(exists($tag->{name}));
ok(exists($tag->{id}));

my $tag_from_search_page = Instagram::API::Tag->fromSearchPage({ media_count => 1, name => 'test_tag', id => 1234567890 });
is($tag_from_search_page->{mediaCount}, 1);
is($tag_from_search_page->{name}, 'test_tag');
is($tag_from_search_page->{id}, 1234567890);

#########################

# Insert your test code below, the Test::More module is use()ed here so read
# its man page ( perldoc Test::More ) for help writing this test script.
