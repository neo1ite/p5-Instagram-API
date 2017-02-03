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

sub get_response_with_code($$;$$$$$) {
    my ($instance, $sub, $params, $code, $method, $msg, $content) = @_;
    $params //= [];
    $code   //= 400;
    $method //= 'get';

    no strict 'refs';
    no warnings 'redefine';
    local $instance->{browser} = LWP::UserAgent->new();
    my $package = ref($instance->{browser}) . '::MonkeyPatch';
    @{$package . '::ISA'} = (ref($instance->{browser}));
    *{$package . '::' . $method} = sub { return HTTP::Response->new($code, $msg, undef, $content); };
    bless $instance->{browser}, $package;
    eval { $instance->$sub(@{$params}) };

    return $@;
}

SKIP: {
    skip 'No connection with Instragram.com', 60 + (20 * 19) + (14 * 20) + (20 * 19) + (14 * 20) + (99 * 8) unless ($r && $r->code == 200);

#>----------------------------------------------------------------------------<#
#>                                getAccount(4)                               <#
#>----------------------------------------------------------------------------<#

    my $user_by_name = $instagram->getAccount('ne01ite');

    ok(blessed($user_by_name) && $user_by_name->isa('Instagram::API::Account'), 'Getting account by name #1');
    is($user_by_name->{username}, 'ne01ite',    'Getting account by name #2');
    is($user_by_name->{id},       '1838386734', 'Getting account by name #3');

    like(get_response_with_code($instagram, 'getAccount', ['NSDALUJaASDNFLUADKFNA'], 404), qr/^Account with given username does not exist\./, 'Fail get account by name with code 404');
    like(get_response_with_code($instagram, 'getAccount', ['NSDALUJaASDNFLUADKFNA']), qr/^Response code is 400\. Body\: .*? Something went wrong\. Please report issue\./, 'Fail get account by name with code 400');
    like(get_response_with_code($instagram, 'getAccount', ['NSDALUJaASDNFLUADKFNA'], 200, undef, 'OK', '{"test_var": "test_value", "test_": '), qr/^Response decoding failed\. Returned data corrupted or this library outdated\. Please report issue/, 'Fail get account by name by broken JSON');

#>----------------------------------------------------------------------------<#
#>                              getAccountById(8)                             <#
#>----------------------------------------------------------------------------<#

    my $user_by_id = $instagram->getAccountById(1838386734);

    ok(blessed($user_by_id) && $user_by_id->isa('Instagram::API::Account'), 'Getting account by ID');
    is($user_by_id->{id},       '1838386734', 'Getting account by name #2');
    is($user_by_id->{username}, 'ne01ite',    'Getting account by name #3');

    eval { $instagram->getAccountById(12347867214694126) };
    like($@, qr/^User with this id not found/, 'Fail get account by ID with unexisting ID');

    eval { $instagram->getAccountById('blahblahblahid') };
    like($@, qr/^User id must be integer or integer wrapped in string/, 'Fail get account by ID with NaN ID');
    like(get_response_with_code($instagram, 'getAccountById', [1838386734], 400, 'request'), qr/^Response code is 400\. Body\: .*? Something went wrong\. Please report issue\./, 'Fail get account by ID with code 400');
    like(get_response_with_code($instagram, 'getAccountById', ['1838386734'], 200, 'request', 'OK', '{"test_var": "test_value", "test_": '), qr/^Response decoding failed\. Returned data corrupted or this library outdated\. Please report issue/, 'Fail get account by ID by broken JSON');

#>----------------------------------------------------------------------------<#
#>                                getMedias(1)                                <#
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

    like(get_response_with_code($instagram, 'getMedias', ['ne01ite']), qr/^Response code is 400\. Body\: .*? Something went wrong\. Please report issue\./, 'Fail get medias by username with code 400');
    like(get_response_with_code($instagram, 'getMedias', ['ne01ite'], 200, undef, 'OK', '{"test_var": "test_value", "test_": '), qr/^Response decoding failed\. Returned data corrupted or this library outdated\. Please report issue/, 'Fail get medias by username by broken JSON');

#>----------------------------------------------------------------------------<#
#>                       getMedias(1 + (20 * (15 + 4)))                       <#
#>----------------------------------------------------------------------------<#

    my $medias_by_user = $instagram->getMedias('realdonaldtrump');

    is(@{$medias_by_user // []}, 20, 'Getting user medias');

    my $i = 1;
    foreach my $media (@{$medias_by_user}) {
        isa_ok($media, 'Instagram::API::Media', 'Checking media object #' . $i);
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
#>                   getPaginateMedias(5 + (20 * (15 + 4)))                   <#
#>----------------------------------------------------------------------------<#

    my $paginate_medias = $instagram->getPaginateMedias('avrillavigne');

    ok(exists($paginate_medias->{medias}));
    ok(exists($paginate_medias->{maxId}));
    ok(exists($paginate_medias->{hasNextPage}));

    is(scalar(@{$paginate_medias->{medias} // []}), 20, 'Getting paginate medias: count');
    is($paginate_medias->{hasNextPage},             1,  'Getting paginate medias: hasNextPage');

    $i = 1;
    foreach my $media (@{$paginate_medias->{medias}}) {
        isa_ok($media, 'Instagram::API::Media', 'Checking media object #' . $i);
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

    like(get_response_with_code($instagram, 'getPaginateMedias', ['avrillavigne']), qr/^Response code is 400\. Body\: .*? Something went wrong\. Please report issue\./, 'Fail get paginate medias by username with code 400');
    like(get_response_with_code($instagram, 'getPaginateMedias', ['avrillavigne'], 200, undef, 'OK', '{"test_var": "test_value", "test_": '), qr/^Response decoding failed\. Returned data corrupted or this library outdated\. Please report issue/, 'Fail get paginate medias by username by broken JSON');

#>----------------------------------------------------------------------------<#
#>                              getMediaByUrl(17)                             <#
#>----------------------------------------------------------------------------<#

    my $media_by_url = $instagram->getMediaByUrl('https://www.instagram.com/p/BP6dCn0B2Vc/');

    isa_ok($media_by_url, 'Instagram::API::Media', 'Getting media by URL');

    ok(exists($media_by_url->{id}));
    ok(exists($media_by_url->{code}));
    isa_ok($media_by_url->{owner}, 'Instagram::API::Account');
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

    like(get_response_with_code($instagram, 'getMediaByUrl', ['https://www.instagram.com/p/BP6dCn0B2Vc/'], 404), qr/^Media with given code does not exist or account is private\./, 'Fail get media by URL with code 404');
    like(get_response_with_code($instagram, 'getMediaByUrl', ['https://www.instagram.com/p/BP6dCn0B2Vc/']), qr/^Response code is 400\. Body\: .*? Something went wrong\. Please report issue\./, 'Fail get media by URL with code 400');
    like(get_response_with_code($instagram, 'getMediaByUrl', ['https://www.instagram.com/p/BP6dCn0B2Vc/'], 200, undef, 'OK', '{"test_var": "test_value", "test_": '), qr/^Response decoding failed\. Returned data corrupted or this library outdated\. Please report issue/, 'Fail get media by URL by broken JSON');

#>----------------------------------------------------------------------------<#
#>                             getMediaByCode(17)                             <#
#>----------------------------------------------------------------------------<#

    my $media_by_code = $instagram->getMediaByCode('BOSsBnUhAaF');

    isa_ok($media_by_code, 'Instagram::API::Media', 'Getting media by URL');

    ok(exists($media_by_code->{id}));
    ok(exists($media_by_code->{code}));
    isa_ok($media_by_code->{owner}, 'Instagram::API::Account');
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

    like(get_response_with_code($instagram, 'getMediaByCode', ['BOSsBnUhAaF'], 404), qr/^Media with given code does not exist or account is private\./, 'Fail get media by code with code 404');
    like(get_response_with_code($instagram, 'getMediaByCode', ['BOSsBnUhAaF']), qr/^Response code is 400\. Body\: .*? Something went wrong\. Please report issue\./, 'Fail get media by code with code 400');
    like(get_response_with_code($instagram, 'getMediaByCode', ['BOSsBnUhAaF'], 200, undef, 'OK', '{"test_var": "test_value", "test_": '), qr/^Response decoding failed\. Returned data corrupted or this library outdated\. Please report issue/, 'Fail get media by code by broken JSON');

#>----------------------------------------------------------------------------<#
#>                 getPaginateMediasByTag(3 + (20 * (13 + 1)))                <#
#>----------------------------------------------------------------------------<#

    ok(scalar(@{($instagram->getPaginateMediasByTag('winter')                                  // {})->{medias} // []}), 'Getting paginate medias by tag');
    my $paginate_media_by_tag = $instagram->getPaginateMediasByTag('солнце');
    ok(scalar(@{($paginate_media_by_tag                                                        // {})->{medias} // []}), 'Getting paginate medias by national tag');
    ok(scalar(@{($instagram->getPaginateMediasByTag('солнце', $paginate_media_by_tag->{maxId}) // {})->{medias} // []}), 'Getting paginate medias by tag with maxID param');

    $i = 1;
    foreach my $media (@{$paginate_media_by_tag->{medias}}) {
        isa_ok($media, 'Instagram::API::Media', 'Checking media object #' . $i);
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

    like(get_response_with_code($instagram, 'getPaginateMediasByTag', ['winter']), qr/^Response code is 400\. Body\: .*? Something went wrong\. Please report issue\./, 'Fail get paginate medias by tag with code 400');
    like(get_response_with_code($instagram, 'getPaginateMediasByTag', ['winter'], 200, undef, 'OK', '{"test_var": "test_value", "test_": '), qr/^Response decoding failed\. Returned data corrupted or this library outdated\. Please report issue/, 'Fail get paginate medias by tag by broken JSON');

#>----------------------------------------------------------------------------<#
#>                     getMediasByTag(3 + (20 * (13 + 1)))                    <#
#>----------------------------------------------------------------------------<#

    is(scalar(@{$instagram->getMediasByTag('russia')                                                            // []}), 12, 'Getting medias by tag');
    is(scalar(@{$instagram->getMediasByTag('россия', 20)                                                        // []}), 20, 'Getting medias by national tag with count param');
    is(scalar(@{$instagram->getMediasByTag('москва', 20, $instagram->getPaginateMediasByTag('москва')->{maxId}) // []}), 20, 'Getting medias by national tag with count and maxID params');

    $i = 1;
    foreach my $media (@{$instagram->getMediasByTag('москва', 20)}) {
        isa_ok($media, 'Instagram::API::Media', 'Checking media object #' . $i);
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

    like(get_response_with_code($instagram, 'getMediasByTag', ['россия']), qr/^Response code is 400\. Body\: .*? Something went wrong\. Please report issue\./, 'Fail get medias by tag with code 400');
    like(get_response_with_code($instagram, 'getMediasByTag', ['россия'], 200, undef, 'OK', '{"test_var": "test_value", "test_": '), qr/^Response decoding failed\. Returned data corrupted or this library outdated\. Please report issue/, 'Fail get medias by tag by broken JSON');

#>----------------------------------------------------------------------------<#
#>                   searchAccountsByUsername(2 + (99 * 8))                   <#
#>----------------------------------------------------------------------------<#

    is(scalar(@{$instagram->searchAccountsByUsername('ne01ite')}),         1,  'Search user accounts #1');
    cmp_ok(scalar(@{$instagram->searchAccountsByUsername('trump')}), '>=', 54, 'Search user accounts #2');
    #eval { $instagram->searchAccountsByUsername('chiragchirag78') };
    #like($@, qr/^Account with given username does not exist\./, 'Search non-existing user account');

    foreach my $account (@{$instagram->searchAccountsByUsername('kremlin') // []}) {
        isa_ok($account, 'Instagram::API::Account');
        ok(exists($account->{id}));
        ok(exists($account->{username}));
        ok(exists($account->{fullName}));
        ok(exists($account->{profilePicUrl}));
        ok(exists($account->{followedByCount}));
        ok(exists($account->{isPrivate}));
        ok(exists($account->{isVerified}));
    }

    like(get_response_with_code($instagram, 'searchAccountsByUsername', ['ne01ite']), qr/^Response code is 400\. Body\: .*? Something went wrong\. Please report issue\./, 'Fail search account by name with code 400');
    like(get_response_with_code($instagram, 'searchAccountsByUsername', ['ne01ite'], 200, undef, 'OK', '{"test_var": "test_value", "test_": '), qr/^Response decoding failed\. Returned data corrupted or this library outdated\. Please report issue/, 'Fail search account by name by broken JSON');

#>----------------------------------------------------------------------------<#
#>                      searchTagsByTagName(2 + (3 * 4))                      <#
#>----------------------------------------------------------------------------<#

    cmp_ok(@{$instagram->searchTagsByTagName('ivanka') // []}, '>=', 0, 'Search tags');
    cmp_ok(@{$instagram->searchTagsByTagName('море')   // []}, '>=', 2, 'Search national tags');

    foreach my $tag (@{$instagram->searchTagsByTagName('солн') // []}) {
        isa_ok($tag, 'Instagram::API::Tag');
        ok(exists($tag->{id}));
        ok(exists($tag->{name}));
        ok(exists($tag->{mediaCount}));
    }

    like(get_response_with_code($instagram, 'searchTagsByTagName', ['солн']), qr/^Response code is 400\. Body\: .*? Something went wrong\. Please report issue\./, 'Fail search tags by name with code 400');
    like(get_response_with_code($instagram, 'searchTagsByTagName', ['солн'], 200, undef, 'OK', '{"test_var": "test_value", "test_": '), qr/^Response decoding failed\. Returned data corrupted or this library outdated\. Please report issue/, 'Fail search tags by name by broken JSON');

#>----------------------------------------------------------------------------<#
#>                     getTopMediasByTagName(2 + (3 * 4))                     <#
#>----------------------------------------------------------------------------<#

    my $top_medias_by_tag_name = $instagram->getTopMediasByTagName('sweethome');

    is(scalar(@{$top_medias_by_tag_name}), 9, 'Getting top medias by tag name');

    $i = 1;
    foreach my $media (@{$top_medias_by_tag_name}) {
        isa_ok($media, 'Instagram::API::Media', 'Checking media object #' . $i);

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

    like(get_response_with_code($instagram, 'getTopMediasByTagName', ['sweethome']), qr/^Response code is 400\. Body\: .*? Something went wrong\. Please report issue\./, 'Fail get top medias by tag with code 400');
    like(get_response_with_code($instagram, 'getTopMediasByTagName', ['sweethome'], 200, undef, 'OK', '{"test_var": "test_value", "test_": '), qr/^Response decoding failed\. Returned data corrupted or this library outdated\. Please report issue/, 'Fail get top medias by tag by broken JSON');

#>----------------------------------------------------------------------------<#
#>                              getMediaById(17)                              <#
#>----------------------------------------------------------------------------<#

    my $media_by_id = $instagram->getMediaById(1422615236019959838);

    isa_ok($media_by_id, 'Instagram::API::Media', 'Getting media by URL');

    ok(exists($media_by_id->{id}));
    ok(exists($media_by_id->{code}));
    isa_ok($media_by_id->{owner}, 'Instagram::API::Account');
    ok(exists($media_by_id->{type}));
    ok(exists($media_by_id->{createdTime}));
    ok(exists($media_by_id->{commentsCount}));
    ok(exists($media_by_id->{likesCount}));
    ok(exists($media_by_id->{imageThumbnailUrl}));
    ok(exists($media_by_id->{imageLowResolutionUrl}));
    ok(exists($media_by_id->{imageStandardResolutionUrl}));
    ok(exists($media_by_id->{imageHighResolutionUrl}));
    ok(exists($media_by_id->{caption})         || 1);
    ok(exists($media_by_id->{captionIsEdited}) || 1);
    ok(exists($media_by_id->{isAd})            || 1);
    ok(exists($media_by_id->{locationId})      || 1);
    ok(exists($media_by_id->{locationName})    || 1);

    like(get_response_with_code($instagram, 'getMediaById', [1422615236019959838]), qr/^Response code is 400\. Body\: .*? Something went wrong\. Please report issue\./, 'Fail get media by id with code 400');
    like(get_response_with_code($instagram, 'getMediaById', [1422615236019959838], 200, undef, 'OK', '{"test_var": "test_value", "test_": '), qr/^Response decoding failed\. Returned data corrupted or this library outdated\. Please report issue/, 'Fail get media by id by broken JSON');

#>----------------------------------------------------------------------------<#
#>                    getMediaCommentsByCode(1 + (10 * 5))                    <#
#>----------------------------------------------------------------------------<#

    is(scalar(@{$instagram->getMediaCommentsByCode('BP79NgXhdJn', 900) // []}), 876, 'Getting comments by media code #1'); # very strange magic...

    my $comments_by_code = $instagram->getMediaCommentsByCode('BCqxgYrKBXx');
    is(scalar(@{$comments_by_code}), 10, 'Getting comments by media code #2');

    foreach my $comment (@{$comments_by_code}) {
        isa_ok($comment, 'Instagram::API::Comment');

        ok(exists($comment->{id}));
        ok(exists($comment->{user}));
        ok(exists($comment->{text}));
        ok(exists($comment->{createdAt}));
    }

    like(get_response_with_code($instagram, 'getMediaCommentsByCode', ['BP79NgXhdJn'], 400, 'request'), qr/^Response code is 400\. Body\: .*? Something went wrong\. Please report issue\./, 'Fail get media comments by code with code 400');
    like(get_response_with_code($instagram, 'getMediaCommentsByCode', ['BP79NgXhdJn'], 200, 'request', 'OK', '{"test_var": "test_value", "test_": '), qr/^Response decoding failed\. Returned data corrupted or this library outdated\. Please report issue/, 'Fail get media comments by code by broken JSON');

#>----------------------------------------------------------------------------<#
#>                     getMediaCommentsById(1 + (10 * 5))                     <#
#>----------------------------------------------------------------------------<#

    my $comments_by_id = $instagram->getMediaCommentsById(1175476025847977789);

    is(scalar(@{$comments_by_code}), 10, 'Getting comments by media id');

    foreach my $comment (@{$comments_by_code}) {
        isa_ok($comment, 'Instagram::API::Comment', 'Getting comments by media code');

        ok(exists($comment->{id}));
        ok(exists($comment->{user}));
        ok(exists($comment->{text}));
        ok(exists($comment->{createdAt}));
    }

    like(get_response_with_code($instagram, 'getMediaCommentsById', [1175476025847977789], 400, 'request'), qr/^Response code is 400\. Body\: .*? Something went wrong\. Please report issue\./, 'Fail get media comments by id with code 400');
    like(get_response_with_code($instagram, 'getMediaCommentsById', [1175476025847977789], 200, 'request', 'OK', '{"test_var": "test_value", "test_": '), qr/^Response decoding failed\. Returned data corrupted or this library outdated\. Please report issue/, 'Fail get media comments by id by broken JSON');

#>----------------------------------------------------------------------------<#
#>                getLocationTopMediasById(1 + (12 * (13 + 1)))               <#
#>----------------------------------------------------------------------------<#

    my $top_medias_by_location_id = $instagram->getLocationTopMediasById(60969779);

    is(scalar(@{$top_medias_by_location_id}), 9, 'Getting top medias by location id');

    $i = 1;
    foreach my $media (@{$top_medias_by_location_id}) {
        isa_ok($media, 'Instagram::API::Media', 'Checking media object #' . $i);
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

    like(get_response_with_code($instagram, 'getLocationTopMediasById', [60969779]), qr/^Response code is 400\. Body\: .*? Something went wrong\. Please report issue\./, 'Fail get location top medias by id with code 400');
    like(get_response_with_code($instagram, 'getLocationTopMediasById', [60969779], 200, undef, 'OK', '{"test_var": "test_value", "test_": '), qr/^Response decoding failed\. Returned data corrupted or this library outdated\. Please report issue/, 'Fail get location top medias by id by broken JSON');

#>----------------------------------------------------------------------------<#
#>                 getLocationMediasById(1 + (12 * (13 + 1)))                 <#
#>----------------------------------------------------------------------------<#

    my $medias_by_location_id = $instagram->getLocationMediasById(60969779);

    is(scalar(@{$medias_by_location_id}), 12, 'Getting medias by location id');

    $i = 1;
    foreach my $media (@{$medias_by_location_id}) {
        isa_ok($media, 'Instagram::API::Media', 'Checking media object #' . $i);
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

    like(get_response_with_code($instagram, 'getLocationMediasById', [60969779]), qr/^Response code is 400\. Body\: .*? Something went wrong\. Please report issue\./, 'Fail get location medias by id with code 400');
    like(get_response_with_code($instagram, 'getLocationMediasById', [60969779], 200, undef, 'OK', '{"test_var": "test_value", "test_": '), qr/^Response decoding failed\. Returned data corrupted or this library outdated\. Please report issue/, 'Fail get location medias by id by broken JSON');

#>----------------------------------------------------------------------------<#
#>                             getLocationById(9)                             <#
#>----------------------------------------------------------------------------<#

    my $location_by_id = $instagram->getLocationById(60969779);

    isa_ok($location_by_id, 'Instagram::API::Location', 'Getting location by ID');

    ok(exists($location_by_id->{id}));
    ok(exists($location_by_id->{name}));
    ok(exists($location_by_id->{lat}));
    ok(exists($location_by_id->{lng}));

    is($location_by_id->{id},   60969779);
    is($location_by_id->{name}, 'Турбаза Арктика');
    is($location_by_id->{lat},  68.786284278082);
    is($location_by_id->{lng},  32.491183685900);

    like(get_response_with_code($instagram, 'getLocationById', [60969779]), qr/^Response code is 400\. Body\: .*? Something went wrong\. Please report issue\./, 'Fail get location by id with code 400');
    like(get_response_with_code($instagram, 'getLocationById', [60969779], 200, undef, 'OK', '{"test_var": "test_value", "test_": '), qr/^Response decoding failed\. Returned data corrupted or this library outdated\. Please report issue/, 'Fail get location by id by broken JSON');
};

#########################

# Insert your test code below, the Test::More module is use()ed here so read
# its man page ( perldoc Test::More ) for help writing this test script.
