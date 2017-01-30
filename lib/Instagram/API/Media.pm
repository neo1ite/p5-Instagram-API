package Instagram::API::Media;

use utf8;
use strict;
use warnings;
use autouse 'Data::Dumper';

use URI;
use Scalar::Util qw/blessed/;
use Instagram::API::Endpoints;
use Instagram::API::Account;

sub new {
    my ($invocant, $params) = @_;

    my $class = ref($invocant) || $invocant;
    my $self = {
        id                         => undef,
        createdTime                => undef,
        type                       => undef,
        link                       => undef,
        imageLowResolutionUrl      => undef,
        imageThumbnailUrl          => undef,
        imageStandardResolutionUrl => undef,
        imageHighResolutionUrl     => undef,
        caption                    => undef,
        captionIsEdited            => undef,
        isAd                       => undef,
        videoLowResolutionUrl      => undef,
        videoStandardResolutionUrl => undef,
        videoLowBandwidthUrl       => undef,
        videoViews                 => undef,
        code                       => undef,
        owner                      => undef,
        ownerId                    => undef,
        likesCount                 => undef,
        locationId                 => undef,
        locationName               => undef,
        commentsCount              => undef,
    };

    bless($self, $class);

    return $self;
}

sub fromApi
{
    my ($self, $mediaArray) = @_;

    $self = __PACKAGE__->new() unless ($self && blessed($self) && $self->isa(__PACKAGE__));
    $self->{id}            = $mediaArray->{'id'};
    $self->{type}          = $mediaArray->{'type'};
    $self->{createdTime}   = $mediaArray->{'created_time'};
    $self->{code}          = $mediaArray->{'code'};
    $self->{link}          = $mediaArray->{'link'};
    $self->{commentsCount} = $mediaArray->{'comments'}{'count'};
    $self->{likesCount}    = $mediaArray->{'likes'}{'count'};

    my $images = $self->_getImageUrls($mediaArray->{'images'}{'standard_resolution'}{'url'});
    $self->{imageLowResolutionUrl}      = $images->{'low'};
    $self->{imageThumbnailUrl}          = $images->{'thumbnail'};
    $self->{imageStandardResolutionUrl} = $images->{'standard'};
    $self->{imageHighResolutionUrl}     = $images->{'high'};

    if (exists($mediaArray->{'caption'})) {
        $self->{caption} = $mediaArray->{'caption'}{'text'};
    }

    if ($self->{type} == 'video') {
        if (exists($mediaArray->{'video_views'})) {
            $self->{videoViews} = $mediaArray->{'video_views'};
        }

        $self->{videoLowResolutionUrl}      = $mediaArray->{'videos'}{'low_resolution'}{'url'};
        $self->{videoStandardResolutionUrl} = $mediaArray->{'videos'}{'standard_resolution'}{'url'};
        $self->{videoLowBandwidthUrl}       = $mediaArray->{'videos'}{'low_bandwidth'}{'url'};
    }

    if (exists($mediaArray->{'location'}{'id'})) {
        $self->{locationId} = $mediaArray->{'location'}{'id'};
    }

    if (exists($mediaArray->{'location'}{'name'})) {
        $self->{locationName} = $mediaArray->{'location'}{'name'};
    }

    return $self;
}

sub _getImageUrls
{
    my ($self, $imageUrl) = @_;

    my $imageName = (split('/', URI->new($imageUrl)->path))[-1];
    my $urls = {
        'thumbnail' => Instagram::API::Endpoints::INSTAGRAM_CDN_URL() . 't/s150x150/' . $imageName,
        'low'       => Instagram::API::Endpoints::INSTAGRAM_CDN_URL() . 't/s320x320/' . $imageName,
        'standard'  => Instagram::API::Endpoints::INSTAGRAM_CDN_URL() . 't/s640x640/' . $imageName,
        'high'      => Instagram::API::Endpoints::INSTAGRAM_CDN_URL() . 't/'          . $imageName
    };

    return $urls;
}

sub fromMediaPage
{
    my ($self, $mediaArray) = @_;

    $self = __PACKAGE__->new() unless ($self && blessed($self) && $self->isa(__PACKAGE__));

    $self->{id}   = $mediaArray->{'id'};
    $self->{type} = 'image';

    if ($mediaArray->{'is_video'}) {
        $self->{type}                       = 'video';
        $self->{videoStandardResolutionUrl} = $mediaArray->{'video_url'};
        $self->{videoViews}                 = $mediaArray->{'video_views'};
    }

    if (exists($mediaArray->{'caption_is_edited'})) {
        $self->{captionIsEdited} = $mediaArray->{'caption_is_edited'};
    }

    if (exists($mediaArray->{'is_ad'})) {
        $self->{isAd} = $mediaArray->{'is_ad'};
    }

    $self->{createdTime}   = $mediaArray->{'date'};
    $self->{code}          = $mediaArray->{'code'};
    $self->{link}          = Instagram::API::Endpoints->getMediaPageLink($self->{code});
    $self->{commentsCount} = $mediaArray->{'comments'}{'count'};
    $self->{likesCount}    = $mediaArray->{'likes'}{'count'};

    my $images = $self->_getImageUrls($mediaArray->{'display_src'});
    $self->{imageStandardResolutionUrl} = $images->{'standard'};
    $self->{imageLowResolutionUrl} = $images->{'low'};
    $self->{imageHighResolutionUrl} = $images->{'high'};
    $self->{imageThumbnailUrl} = $images->{'thumbnail'};

    if (exists($mediaArray->{'caption'})) {
        $self->{caption} = $mediaArray->{'caption'};
    }

    if (exists($mediaArray->{'location'}{'id'})) {
        $self->{locationId} = $mediaArray->{'location'}{'id'};
    }

    if (exists($mediaArray->{'location'}{'name'})) {
        $self->{locationName} = $mediaArray->{'location'}{'name'};
    }
    
    $self->{owner} = Instagram::API::Account->fromMediaPage($mediaArray->{'owner'});

    return $self;
}

sub fromTagPage
{
    my ($self, $mediaArray) = @_;

    $self = __PACKAGE__->new() unless ($self && blessed($self) && $self->isa(__PACKAGE__));

    $self->{code}          = $mediaArray->{'code'};
    $self->{link}          = Instagram::API::Endpoints->getMediaPageLink($self->{code});
    $self->{commentsCount} = $mediaArray->{'comments'}{'count'};
    $self->{likesCount}    = $mediaArray->{'likes'}{'count'};
    $self->{ownerId}       = $mediaArray->{'owner'}{'id'};

    if (exists($mediaArray->{'caption'})) {
        $self->{caption} = $mediaArray->{'caption'};
    }

    $self->{createdTime} = $mediaArray->{'date'};

    my $images = $self->_getImageUrls($mediaArray->{'display_src'});
    $self->{imageStandardResolutionUrl} = $images->{'standard'};
    $self->{imageLowResolutionUrl}      = $images->{'low'};
    $self->{imageHighResolutionUrl}     = $images->{'high'};
    $self->{imageThumbnailUrl}          = $images->{'thumbnail'};
    $self->{type}                       = 'image';

    if ($mediaArray->{'is_video'}) {
        $self->{type}       = 'video';
        $self->{videoViews} = $mediaArray->{'video_views'};
    }

    $self->{id} = $mediaArray->{'id'};

    return $self;
}

sub getIdFromCode
{
    my ($self, $code) = @_;

    my @code = split '', $code;
    my $alphabet = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789-_';
    my $id = 0;
    for (my $i = 0; $i < @code; $i++) {
        my $c = $code[$i];
        $id = $id * 64 + index($alphabet, $c);
    }

    return $id;
}

sub getLinkFromId
{
    my ($self, $id) = @_;

    my $code = $self->getCodeFromId($id);

    return Instagram::API::Endpoints::getMediaPageLink($code);
}

sub getCodeFromId
{
    my ($self, $id) = @_;

    $id = (split('_', $id))[0];
    my @alphabet = ('A'..'Z','a'..'z',0..9,'-','_');#'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789-_';
    my $code = '';

    while ($id > 0) {
        my $remainder = $id % 64;
        $id = ($id - $remainder) / 64;
        $code = $alphabet[$remainder] . $code;
    };

    return $code;
}

1;
