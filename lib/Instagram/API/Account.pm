package Instagram::API::Account;

use utf8;
use strict;
use warnings;
use autouse 'Data::Dumper';

use Scalar::Util qw/blessed/;

sub new {
    my ($invocant, $params) = @_;

    my $class = ref($invocant) || $invocant;
    my $self = {
        id              => undef,
        username        => undef,
        fullName        => undef,
        profilePicUrl   => undef,
        biography       => undef,
        externalUrl     => undef,
        followsCount    => undef,
        followedByCount => undef,
        mediaCount      => undef,
        isPrivate       => undef,
        isVerified      => undef,
    };

    bless($self, $class);

    return $self;
}

sub fromAccountPage
{
    my ($self, $userArray) = @_;

    $self = __PACKAGE__->new() unless ($self && blessed($self) && $self->isa(__PACKAGE__));

    $self->{username}        = $userArray->{'username'};
    $self->{followsCount}    = $userArray->{'follows'}{'count'};
    $self->{followedByCount} = $userArray->{'followed_by'}{'count'};
    $self->{profilePicUrl}   = $userArray->{'profile_pic_url'};
    $self->{id}              = $userArray->{'id'};
    $self->{biography}       = $userArray->{'biography'};
    $self->{fullName}        = $userArray->{'full_name'};
    $self->{mediaCount}      = $userArray->{'media'}{'count'};
    $self->{isPrivate}       = $userArray->{'is_private'};
    $self->{externalUrl}     = $userArray->{'external_url'};
    $self->{isVerified}      = $userArray->{'is_verified'};

    return $self;
}

sub fromMediaPage
{
    my ($self, $userArray) = @_;

    $self = __PACKAGE__->new() unless ($self && blessed($self) && $self->isa(__PACKAGE__));

    $self->{username}      = $userArray->{'username'};
    $self->{profilePicUrl} = $userArray->{'profile_pic_url'};
    $self->{id}            = $userArray->{'id'};
    $self->{fullName}      = $userArray->{'full_name'};
    $self->{isPrivate}     = $userArray->{'is_private'};

    return $self;
}

sub fromSearchPage
{
    my ($self, $userArray) = @_;

    $self = __PACKAGE__->new() unless ($self && blessed($self) && $self->isa(__PACKAGE__));

    $self->{username}        = $userArray->{'username'};
    $self->{profilePicUrl}   = $userArray->{'profile_pic_url'};
    $self->{id}              = $userArray->{'pk'};
    $self->{fullName}        = $userArray->{'full_name'};
    $self->{isPrivate}       = $userArray->{'is_private'};
    $self->{isVerified}      = $userArray->{'is_verified'};
    $self->{followedByCount} = $userArray->{'follower_count'};

    return $self;
}

1;
