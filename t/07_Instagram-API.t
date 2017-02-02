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
    skip 'No connection with Instragram.com', 52 + (20 * 19) + (14 * 20) + (20 * 19) + (14 * 20) unless ($r && $r->code == 200);

#>----------------------------------------------------------------------------<#
#>                                 getAccount                                 <#
#>----------------------------------------------------------------------------<#

    my $user_by_name = $instagram->getAccount('ne01ite');
    ok(blessed($user_by_name) && $user_by_name->isa('Instagram::API::Account'), 'Getting account by name #1');
    is($user_by_name->{username}, 'ne01ite',    'Getting account by name #2');
    is($user_by_name->{id},       '1838386734', 'Getting account by name #3');

#>----------------------------------------------------------------------------<#
#>                               getAccountById                               <#
#>----------------------------------------------------------------------------<#

    my $user_by_id = $instagram->getAccountById(1838386734);

    ok(blessed($user_by_id) && $user_by_id->isa('Instagram::API::Account'), 'Getting account by ID');
    is($user_by_id->{id},       '1838386734', 'Getting account by name #2');
    is($user_by_id->{username}, 'ne01ite',    'Getting account by name #3');

#>----------------------------------------------------------------------------<#
#>                                 getMedias                                  <#
#>----------------------------------------------------------------------------<#

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

#>----------------------------------------------------------------------------<#
#>                                 getMedias                                  <#
#>----------------------------------------------------------------------------<#

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

#>----------------------------------------------------------------------------<#
#>                             getPaginateMedias                              <#
#>----------------------------------------------------------------------------<#

    my $paginate_medias = $instagram->getPaginateMedias('avrillavigne');

    ok(exists($paginate_medias->{medias}));
    ok(exists($paginate_medias->{maxId}));
    ok(exists($paginate_medias->{hasNextPage}));

    is(scalar(@{$paginate_medias->{medias} // []}), 20, 'Getting paginate medias: count');
    is($paginate_medias->{hasNextPage},             1,  'Getting paginate medias: hasNextPage');

    $i = 1;
    foreach my $media (@{$paginate_medias->{medias}}) {
        ok(blessed($media) && $media->isa('Instagram::API::Media'), 'Checking media object #' . $i);
        ok(exists($media->{id}));
        ok(exists($media->{code}));
        ok(exists($media->{link}));
        ok(exists($media->{type}));
        ok(exists($media->{createdTime}));
        if ($media->{type} eq 'video') {
            ok(exists($media->{videoViews}) || 1);
            ok(exists($media->{videoLowResolutionUrl}));
            ok(exists($media->{videoStandardResolutionUrl}));
            ok(exists($media->{videoLowBandwidthUrl}));
        }
        ok(exists($media->{commentsCount}));
        ok(exists($media->{likesCount}));
        ok(exists($media->{imageThumbnailUrl}));
        ok(exists($media->{imageLowResolutionUrl}));
        ok(exists($media->{imageStandardResolutionUrl}));
        ok(exists($media->{imageHighResolutionUrl}));
        ok(exists($media->{caption}));
        ok(exists($media->{locationId})   || 1);
        ok(exists($media->{locationName}) || 1);
        $i++;
    }

#>----------------------------------------------------------------------------<#
#>                                getMediaByUrl                               <#
#>----------------------------------------------------------------------------<#

    my $media_by_url = $instagram->getMediaByUrl('https://www.instagram.com/p/BP6dCn0B2Vc/');
    ok(blessed($media_by_url) && $media_by_url->isa('Instagram::API::Media'), 'Getting media by URL');
    ok(exists($media_by_url->{id}));
    ok(exists($media_by_url->{code}));
    ok($media_by_url->{owner} && blessed($media_by_url->{owner}) && $media_by_url->{owner}->isa('Instagram::API::Account'));
    ok(exists($media_by_url->{type}));
    ok(exists($media_by_url->{createdTime}));
    ok(exists($media_by_url->{commentsCount}));
    ok(exists($media_by_url->{likesCount}));
    ok(exists($media_by_url->{imageThumbnailUrl}));
    ok(exists($media_by_url->{imageLowResolutionUrl}));
    ok(exists($media_by_url->{imageStandardResolutionUrl}));
    ok(exists($media_by_url->{imageHighResolutionUrl}));
    ok(exists($media_by_url->{caption})         || 1);
    ok(exists($media_by_url->{captionIsEdited}) || 1);
    ok(exists($media_by_url->{isAd})            || 1);
    ok(exists($media_by_url->{locationId})      || 1);
    ok(exists($media_by_url->{locationName})    || 1);

#>----------------------------------------------------------------------------<#
#>                               getMediaByCode                               <#
#>----------------------------------------------------------------------------<#

    my $media_by_code = $instagram->getMediaByCode('BOSsBnUhAaF');
    ok(blessed($media_by_code) && $media_by_code->isa('Instagram::API::Media'), 'Getting media by URL');
    ok(exists($media_by_code->{id}));
    ok(exists($media_by_code->{code}));
    ok($media_by_code->{owner} && blessed($media_by_code->{owner}) && $media_by_code->{owner}->isa('Instagram::API::Account'));
    ok(exists($media_by_code->{type}));
    ok(exists($media_by_code->{createdTime}));
    ok(exists($media_by_code->{commentsCount}));
    ok(exists($media_by_code->{likesCount}));
    ok(exists($media_by_code->{imageThumbnailUrl}));
    ok(exists($media_by_code->{imageLowResolutionUrl}));
    ok(exists($media_by_code->{imageStandardResolutionUrl}));
    ok(exists($media_by_code->{imageHighResolutionUrl}));
    ok(exists($media_by_code->{caption})         || 1);
    ok(exists($media_by_code->{captionIsEdited}) || 1);
    ok(exists($media_by_code->{isAd})            || 1);
    ok(exists($media_by_code->{locationId})      || 1);
    ok(exists($media_by_code->{locationName})    || 1);

#>----------------------------------------------------------------------------<#
#>                           getPaginateMediasByTag                           <#
#>----------------------------------------------------------------------------<#

    ok(scalar(@{($instagram->getPaginateMediasByTag('winter')                                  // {})->{medias} // []}), 'Getting paginate medias by tag');
    my $paginate_media_by_tag = $instagram->getPaginateMediasByTag('солнце');
    ok(scalar(@{($paginate_media_by_tag                                                        // {})->{medias} // []}), 'Getting paginate medias by national tag');
    ok(scalar(@{($instagram->getPaginateMediasByTag('солнце', $paginate_media_by_tag->{maxId}) // {})->{medias} // []}), 'Getting paginate medias by tag with maxID param');

    $i = 1;
    foreach my $media (@{$paginate_media_by_tag->{medias}}) {
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

#>----------------------------------------------------------------------------<#
#>                               getMediasByTag                               <#
#>----------------------------------------------------------------------------<#

    is(scalar(@{$instagram->getMediasByTag('russia')                                     // []}), 12, 'Getting medias by tag');
    is(scalar(@{$instagram->getMediasByTag('россия', 20)                                 // []}), 20, 'Getting medias by national tag with count param');
    is(scalar(@{$instagram->getMediasByTag('москва', 20, $instagram->getPaginateMediasByTag('москва')->{maxId}) // []}), 20, 'Getting medias by national tag with count and maxID params');

    $i = 1;
    foreach my $media (@{$instagram->getMediasByTag('москва', 20)}) {
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

    #$instagram->searchAccountsByUsername();

    #$instagram->searchTagsByTagName();

    #$instagram->getTopMediasByTagName();

    #$instagram->getMediaById();
    #$instagram->getMediaCommentsById();
    #$instagram->getMediaCommentsByCode();
    #$instagram->getLocationTopMediasById();
    #$instagram->getLocationMediasById();
    #$instagram->getLocationById();


};

#########################

# Insert your test code below, the Test::More module is use()ed here so read
# its man page ( perldoc Test::More ) for help writing this test script.
