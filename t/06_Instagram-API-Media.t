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
BEGIN { use_ok('Instagram::API::Media') };

my $media = Instagram::API::Media->new();

ok(blessed($media) && $media->isa('Instagram::API::Media'));

ok(exists($media->{id}));
ok(exists($media->{createdTime}));
ok(exists($media->{type}));
ok(exists($media->{link}));
ok(exists($media->{imageLowResolutionUrl}));
ok(exists($media->{imageThumbnailUrl}));
ok(exists($media->{imageStandardResolutionUrl}));
ok(exists($media->{imageHighResolutionUrl}));
ok(exists($media->{caption}));
ok(exists($media->{captionIsEdited}));
ok(exists($media->{isAd}));
ok(exists($media->{videoLowResolutionUrl}));
ok(exists($media->{videoStandardResolutionUrl}));
ok(exists($media->{videoLowBandwidthUrl}));
ok(exists($media->{videoViews}));
ok(exists($media->{code}));
ok(exists($media->{owner}));
ok(exists($media->{ownerId}));
ok(exists($media->{likesCount}));
ok(exists($media->{locationId}));
ok(exists($media->{locationName}));
ok(exists($media->{commentsCount}));

is(Instagram::API::Media->getCodeFromId('1433618228001511344'), 'BPlPC7Hjhew');
is(Instagram::API::Media->getIdFromCode('BPdFHeHDpCE'),         '1431322760173228164');
is(Instagram::API::Media->getLinkFromId('1435150233625339371'), 'https://www.instagram.com/p/BPqrYiijqXr');

my $images = Instagram::API::Media->_getImageUrls('https://scontent-arn2-1.cdninstagram.com/t51.2885-15/e35/16228758_258640784568996_8361304772640243712_n.jpg?ig_cache_key=MTQzOTMyOTcxNjYyMzQ2NzQwOA%3D%3D.2');
is($images->{thumbnail}, 'https://scontent.cdninstagram.com/t/s150x150/16228758_258640784568996_8361304772640243712_n.jpg');
is($images->{low},       'https://scontent.cdninstagram.com/t/s320x320/16228758_258640784568996_8361304772640243712_n.jpg');
is($images->{standard},  'https://scontent.cdninstagram.com/t/s640x640/16228758_258640784568996_8361304772640243712_n.jpg');
is($images->{high},      'https://scontent.cdninstagram.com/t/16228758_258640784568996_8361304772640243712_n.jpg');

my $media_from_tag_page = Instagram::API::Media->fromTagPage({
    id          => '1439329716623467408',
    code        => 'BP5hsBaAWOQ',
    comments    => { count => 0 },
    likes       => { count => 0 },
    owner       => { id => '298994603' },
    caption     => 'Dinner) #PortoMaltese #NevskyProspect #SaintP #SaintPetersburg #Piter #Russia',
    date        => 1485801494,
    display_src => 'https://scontent-arn2-1.cdninstagram.com/t51.2885-15/e35/16228758_258640784568996_8361304772640243712_n.jpg?ig_cache_key=MTQzOTMyOTcxNjYyMzQ2NzQwOA%3D%3D.2',
    is_video    => 0,
});

ok(blessed($media_from_tag_page) && $media_from_tag_page->isa('Instagram::API::Media'));
is($media_from_tag_page->{id},                         '1439329716623467408');
is($media_from_tag_page->{code},                       'BP5hsBaAWOQ');
is($media_from_tag_page->{commentsCount},              0);
is($media_from_tag_page->{likesCount},                 0);
is($media_from_tag_page->{ownerId},                    '298994603');
is($media_from_tag_page->{caption},                    'Dinner) #PortoMaltese #NevskyProspect #SaintP #SaintPetersburg #Piter #Russia');
is($media_from_tag_page->{createdTime},                1485801494);
is($media_from_tag_page->{imageThumbnailUrl},          'https://scontent.cdninstagram.com/t/s150x150/16228758_258640784568996_8361304772640243712_n.jpg');
is($media_from_tag_page->{imageLowResolutionUrl},      'https://scontent.cdninstagram.com/t/s320x320/16228758_258640784568996_8361304772640243712_n.jpg');
is($media_from_tag_page->{imageStandardResolutionUrl}, 'https://scontent.cdninstagram.com/t/s640x640/16228758_258640784568996_8361304772640243712_n.jpg');
is($media_from_tag_page->{imageHighResolutionUrl},     'https://scontent.cdninstagram.com/t/16228758_258640784568996_8361304772640243712_n.jpg');
is($media_from_tag_page->{type},                       'image');

my $media_from_media_page = Instagram::API::Media->fromMediaPage({
    id                => '1439284924426511505',
    code              => 'BP5XgNbBGSR',
    is_video          => 1,
    video_views       => 39694,
    video_url         => 'https://scontent-arn2-1.cdninstagram.com/t50.2886-16/16405412_707643799417427_1363430646491381760_n.mp4',
    caption_is_edited => 0,
    is_ad             => 0,
    date              => 1485796155,
    comments          => { count => 102 },
    likes             => { count => 6386 },
    display_src       => 'https://scontent-arn2-1.cdninstagram.com/t51.2885-15/e15/16230160_207444976393553_3158159954636963840_n.jpg?ig_cache_key=MTQzOTI4NDkyNDQyNjUxMTUwNQ%3D%3D.2',
    caption           => 'Красота😍😍😍
Отметь тех с кем хочешь так же прокатиться🏂🎿⛷',
    location          => undef,
    owner => {
        id              => '1948257780',
        username        => 'instavideo_kz',
        full_name       => 'МЫ ЖДЕМ ТВОИ ВИДЕО👌',
        profile_pic_url => 'https =>//scontent-arn2-1.cdninstagram.com/t51.2885-19/s150x150/14309841_1813823755513859_126130394_a.jpg',
        is_private      => 0,
    },
});

ok(blessed($media_from_media_page) && $media_from_media_page->isa('Instagram::API::Media'));
is($media_from_media_page->{id},                         '1439284924426511505');
is($media_from_media_page->{code},                       'BP5XgNbBGSR');
is($media_from_media_page->{commentsCount},              102);
is($media_from_media_page->{likesCount},                 6386);
ok($media_from_media_page->{owner} && blessed($media_from_media_page->{owner}) && $media_from_media_page->{owner}->isa('Instagram::API::Account'));
is($media_from_media_page->{caption},                    'Красота😍😍😍
Отметь тех с кем хочешь так же прокатиться🏂🎿⛷');
is($media_from_media_page->{createdTime},                1485796155);
is($media_from_media_page->{isAd},                       0);
is($media_from_media_page->{captionIsEdited},            0);
is($media_from_media_page->{imageThumbnailUrl},          'https://scontent.cdninstagram.com/t/s150x150/16230160_207444976393553_3158159954636963840_n.jpg');
is($media_from_media_page->{imageLowResolutionUrl},      'https://scontent.cdninstagram.com/t/s320x320/16230160_207444976393553_3158159954636963840_n.jpg');
is($media_from_media_page->{imageStandardResolutionUrl}, 'https://scontent.cdninstagram.com/t/s640x640/16230160_207444976393553_3158159954636963840_n.jpg');
is($media_from_media_page->{imageHighResolutionUrl},     'https://scontent.cdninstagram.com/t/16230160_207444976393553_3158159954636963840_n.jpg');
is($media_from_media_page->{type},                       'video');
is($media_from_media_page->{videoStandardResolutionUrl}, 'https://scontent-arn2-1.cdninstagram.com/t50.2886-16/16405412_707643799417427_1363430646491381760_n.mp4');
is($media_from_media_page->{videoViews},                 39694);

my $media_from_api = Instagram::API::Media->fromApi({
    id                => '1418403761009124612',
    code              => 'BOvLrSjBuUE',
    type              => 'image',
    link              => 'https://www.instagram.com/p/BOvLrSjBuUE/',
    created_time      => 1483306926,
    comments          => { count => 4 },
    likes             => { count => 48 },
    images            => { standard_resolution => { url => 'https://scontent-arn2-1.cdninstagram.com/t51.2885-15/s480x480/e35/15876235_217213092021117_7909162982590906368_n.jpg?ig_cache_key=MTQxODQwMzc2MTAwOTEyNDYxMg%3D%3D.2' } },
    caption           => { text => 'Никак не могла я предположить в прошлую новогоднюю ночь, что следующий новый год встречу так... Посреди заснеженной реки на турбазе под Мурманском под северным сиянием 😍 🌌 ребята даже трансляцию курантов запустили.
Вы представляете какое это везение? Во-первых, что вообще засияло, во-вторых, что облака разошлись как раз около полуночи. Перед этим, часов в 8, мы стояли там же и учились различать сияние сквозь облака 😏 думали, можем большего не увидеть.

После полуночи мы запели гимн России все вместе, "алые паруса" под гитару. Небо затянуло облаками, чтобы мы смогли пойти на турбазу к новогоднему столу. Ещё один из участников потом сделал предложение своей девушке, сразу после начался одновременно салют и снова сияние, причем с разных сторон и не понятно куда смотреть))) Спасибо @intellecttour!!
#северноесияние #турбазаарктика #intellecttour #интеллекттур #полярноесияние #заполярнымкругом #Мурманск #murmansk #aurora #полярнаяночь #тулома #астростас #стаскороткий' },
    location          => {
        name            => 'Турбаза Арктика',
        slug            => '',
        id              => 60969779,
        has_public_page => 1
    },
});

ok(blessed($media_from_api) && $media_from_api->isa('Instagram::API::Media'));
is($media_from_api->{id},                         '1418403761009124612');
is($media_from_api->{code},                       'BOvLrSjBuUE');
is($media_from_api->{type},                       'image');
is($media_from_api->{createdTime},                1483306926);
is($media_from_api->{link},                       'https://www.instagram.com/p/BOvLrSjBuUE/');
is($media_from_api->{commentsCount},              4);
is($media_from_api->{likesCount},                 48);
is($media_from_api->{imageThumbnailUrl},          'https://scontent.cdninstagram.com/t/s150x150/15876235_217213092021117_7909162982590906368_n.jpg');
is($media_from_api->{imageLowResolutionUrl},      'https://scontent.cdninstagram.com/t/s320x320/15876235_217213092021117_7909162982590906368_n.jpg');
is($media_from_api->{imageStandardResolutionUrl}, 'https://scontent.cdninstagram.com/t/s640x640/15876235_217213092021117_7909162982590906368_n.jpg');
is($media_from_api->{imageHighResolutionUrl},     'https://scontent.cdninstagram.com/t/15876235_217213092021117_7909162982590906368_n.jpg');
is($media_from_api->{caption},                    'Никак не могла я предположить в прошлую новогоднюю ночь, что следующий новый год встречу так... Посреди заснеженной реки на турбазе под Мурманском под северным сиянием 😍 🌌 ребята даже трансляцию курантов запустили.
Вы представляете какое это везение? Во-первых, что вообще засияло, во-вторых, что облака разошлись как раз около полуночи. Перед этим, часов в 8, мы стояли там же и учились различать сияние сквозь облака 😏 думали, можем большего не увидеть.

После полуночи мы запели гимн России все вместе, "алые паруса" под гитару. Небо затянуло облаками, чтобы мы смогли пойти на турбазу к новогоднему столу. Ещё один из участников потом сделал предложение своей девушке, сразу после начался одновременно салют и снова сияние, причем с разных сторон и не понятно куда смотреть))) Спасибо @intellecttour!!
#северноесияние #турбазаарктика #intellecttour #интеллекттур #полярноесияние #заполярнымкругом #Мурманск #murmansk #aurora #полярнаяночь #тулома #астростас #стаскороткий');
is($media_from_api->{locationId},                 60969779);
is($media_from_api->{locationName},               'Турбаза Арктика');

#########################

# Insert your test code below, the Test::More module is use()ed here so read
# its man page ( perldoc Test::More ) for help writing this test script.
