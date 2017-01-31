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
    skip 'No connection with Instragram.com', 10 + (20 * 19) + (14 * 20) unless ($r && $r->code == 200);

    my $user_by_name = $instagram->getAccount('ne01ite');
    ok(blessed($user_by_name) && $user_by_name->isa('Instagram::API::Account'), 'Getting account by name #1');
    is($user_by_name->{username}, 'ne01ite',    'Getting account by name #2');
    is($user_by_name->{id},       '1838386734', 'Getting account by name #3');

    my $user_by_id = $instagram->getAccountById(1838386734);

    ok(blessed($user_by_id) && $user_by_id->isa('Instagram::API::Account'), 'Getting account by ID');
    is($user_by_id->{id},       '1838386734', 'Getting account by name #2');
    is($user_by_id->{username}, 'ne01ite',    'Getting account by name #3');

    my $empty_media_by_user = $instagram->getMedias('ne01ite');

    ok(
        ref($empty_media_by_user) eq 'ARRAY'
        && (
            !@{$empty_media_by_user}
            || (
                blessed($empty_media_by_user->[-1])
                && $empty_media_by_user->[-1]->isa('Instagram::API::Media')
            )
        ),
        'Getting none user medias'
    );

    my $medias_by_user = $instagram->getMedias('realdonaldtrump');
    is(@{$medias_by_user // []}, 20, 'Getting user medias');

    my $i = 1;
    foreach my $media (@{$medias_by_user}) {
        ok(blessed($media) && $media->isa('Instagram::API::Media'), 'Checking media object #' . $i);
        ok(exists($media->{id}));
        ok(exists($media->{code}));
        ok(exists($media->{type}));
        if ($media->{type} eq 'video') {
            ok(exists($media->{videoViews}));
            ok(exists($media->{videoLowResolutionUrl}));
            ok(exists($media->{videoStandardResolutionUrl}));
            ok(exists($media->{videoLowBandwidthUrl}));
        }
        ok(exists($media->{createdTime}));
        ok(exists($media->{link}));
        ok(exists($media->{commentsCount}));
        ok(exists($media->{likesCount}));
        ok(exists($media->{imageThumbnailUrl}));
        ok(exists($media->{imageLowResolutionUrl}));
        ok(exists($media->{imageStandardResolutionUrl}));
        ok(exists($media->{imageHighResolutionUrl}));
        ok(exists($media->{caption}));
        ok(exists($media->{locationId}));
        ok(exists($media->{locationName}));
        $i++;
    }

    is(scalar(@{$instagram->getMediasByTag('russia')     // []}), 12, 'Getting medias by tag');
    is(scalar(@{$instagram->getMediasByTag('россия', 20) // []}), 20, 'Getting medias by national tag with count param');

    $i = 1;
    foreach my $media (@{$instagram->getMediasByTag('россия', 20)}) {
        ok(blessed($media) && $media->isa('Instagram::API::Media'), 'Checking media object #' . $i);
        ok(exists($media->{id}));
        ok(exists($media->{code}));
        ok(exists($media->{link}));
        ok(exists($media->{type}));
        if ($media->{type} eq 'video') {
            ok(exists($media->{videoViews}));
        }
        ok(exists($media->{createdTime}));

        ok(exists($media->{commentsCount}));
        ok(exists($media->{likesCount}));
        ok(exists($media->{imageThumbnailUrl}));
        ok(exists($media->{imageLowResolutionUrl}));
        ok(exists($media->{imageStandardResolutionUrl}));
        ok(exists($media->{imageHighResolutionUrl}));
        ok(exists($media->{caption}));
        $i++;
    }
};

#########################

# Insert your test code below, the Test::More module is use()ed here so read
# its man page ( perldoc Test::More ) for help writing this test script.
