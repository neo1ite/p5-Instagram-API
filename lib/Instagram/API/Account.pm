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
__END__

=head1 NAME

Instagram::API::Account - Perl extension for blah blah blah

=head1 SYNOPSIS

  use Instagram::API;

  my $instagram = Instagram::API->new();
  my $user = $instagram->getAccount($username);
  my $feed = $instagram->getMedias($username);

=head1 DESCRIPTION

Stub documentation for Instagram::API, created by h2xs. It looks like the
author of the extension was negligent enough to leave the stub
unedited.

Blah blah blah.

=head2 METHODS

=head3 new

=head3 fromAccountPage

=head3 fromMediaPage

=head3 fromSearchPage

=head1 SEE ALSO

Mention other useful documentation such as the documentation of
related modules or operating system documentation (such as man pages
in UNIX), or any relevant external documentation such as RFCs or
standards.

If you have a mailing list set up for your module, mention it here.

If you have a web site set up for your module, mention it here.

=head1 AUTHOR

A. U. Thor, E<lt>a.u.thor@a.galaxy.far.far.awayE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2017 by A. U. Thor

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself, either Perl version 5.22.2 or,
at your option, any later version of Perl 5 you may have available.


=cut
