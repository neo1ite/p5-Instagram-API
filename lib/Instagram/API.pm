package Instagram::API;

use utf8;
use strict;
use warnings;
use autouse 'Data::Dumper';

use Carp qw/carp croak cluck confess/;
use Try::Tiny;
use JSON::MaybeXS;
use LWP::UserAgent;
use Data::Validate::URI qw(is_uri);
use Instagram::API::Endpoints;
use Instagram::API::Media;
use Instagram::API::Tag;
use Instagram::API::Comment;
use Instagram::API::Location;

our $VERSION = '0.01';

use constant MAX_COMMENTS_PER_REQUEST => 300;

sub new($;$) {
    my ($invocant, $params) = @_;

    my $class = ref($invocant) || $invocant;
    my $self = { %{$params // {}} };
    $self->{browser} ||= LWP::UserAgent->new(agent => 'instagram-api-' . $VERSION);
	carp 'Browser is not a LWP::UserAgent' unless $self->{browser}->isa('LWP::UserAgent');

    bless($self, $class);

    return $self;
}

sub getAccount($$)
{
    my ($self, $username) = @_;

    my $response = $self->{browser}->get(Instagram::API::Endpoints::getAccountJsonLink($username));

    croak 'Account with given username does not exist.' if ($response->code == 404);
    #throw new InstagramNotFoundException('Account with given username does not exist.');
cluck Data::Dumper::Dumper $response if ($response->code == 403);
    croak 'Response code is ' . $response->code
        . '. Body: ' . $response->content
        . ' Something went wrong. Please report issue.' if ($response->code != 200);
    #throw new InstagramException('Response code is ' . $response->code . '. Body: ' . $response->body . ' Something went wrong. Please report issue.');

    my $userArray;
    try {
        $userArray = decode_json($response->content);
    } catch {
        croak 'Response decoding failed. Returned data corrupted or this library outdated. Please report issue';
    };

    croak 'Account with this username does not exist' if (!exists($userArray->{'user'}));
    #throw new InstagramException('Account with this username does not exist');

    return Instagram::API::Account->fromAccountPage($userArray->{'user'});
}

sub getAccountById($$)
{
    my ($self, $id) = @_;

    croak 'User id must be integer or integer wrapped in string' unless ($id && $id =~ /^\d+$/);
    #throw new InvalidArgumentException('User id must be integer or integer wrapped in string');

    my $parameters = Instagram::API::Endpoints::getAccountJsonInfoLinkByAccountId($id);

    my $response = $self->_getContentsFromUrl($parameters);
cluck Data::Dumper::Dumper $response if ($response->code == 403);
    croak 'Response code is ' . $response->code
        . '. Body: ' . $response->content
        . ' Something went wrong. Please report issue.' if ($response->code != 200);
    #throw new InstagramException('Response code is ' . $response->code . '. Body: ' . $response->body . ' Something went wrong. Please report issue.');

    my $userArray;
    try {
        $userArray = decode_json($response->content);
    } catch {
        croak 'Response decoding failed. Returned data corrupted or this library outdated. Please report issue';
    };

    croak $userArray->{'message'} if ($userArray->{'status'} eq 'fail');
    #throw new InstagramException($userArray['message']);

    croak 'User with this id not found' unless exists($userArray->{'username'});
    #throw new InstagramNotFoundException('User with this id not found');

    return Instagram::API::Account->fromAccountPage($userArray);
}

sub _getContentsFromUrl($$)
{
    my ($self, $parameters) = @_;

    my $random = $self->_generateRandomString(32);

    my $request = HTTP::Request->new(
        'POST' => Instagram::API::Endpoints::INSTAGRAM_QUERY_URL(),
        HTTP::Headers->new(
            'Cookie'       => 'csrftoken=' . $random . ';',
            'X-Csrftoken'  => $random,
            'Referer'      => 'https://www.instagram.com/',
            'Content-Type' => 'application/x-www-form-urlencoded',
        ),
        'q=' . $parameters
    );

    my $response = $self->{browser}->request($request);

    return $response;
}

sub _generateRandomString($;$)
{
    my ($self, $length) = @_;
    $length //= 10;

    my @characters       = (0 .. 9, 'a' .. 'z', 'A' .. 'Z');
    my $charactersLength = scalar @characters;
    my $randomString     = '';

    for (my $i = 0; $i < $length; $i++) {
        $randomString .= $characters[sprintf('%.f', rand($charactersLength - 1))];
    }

    return $randomString;
}

sub getMedias($$;$$)
{
    my ($self, $username, $count, $maxId) = @_;
    $count //= 20;
    $maxId //= '';

    my $medias          = [];
    my $index           = 0;
    my $isMoreAvailable = 1;

    while ($index < $count && $isMoreAvailable) {
        my $response = $self->{browser}->get(Instagram::API::Endpoints::getAccountMediasJsonLink($username, $maxId));
cluck Data::Dumper::Dumper $response if ($response->code == 403);
        croak 'Response code is ' . $response->code
            . '. Body: ' . $response->content
            . ' Something went wrong. Please report issue.' if ($response->code != 200);
        #throw new InstagramException('Response code is ' . $response->code . '. Body: ' . $response->body . ' Something went wrong. Please report issue.');

        my $jsonResponse;
        try {
            $jsonResponse = decode_json($response->content);
        } catch {
            croak 'Response decoding failed. Returned data corrupted or this library outdated. Please report issue';
        };

        return [] unless @{$jsonResponse->{'items'} // []};

        foreach my $mediaArray (@{$jsonResponse->{'items'}}) {
            return $medias if ($index == $count);

            push @{$medias}, Instagram::API::Media->fromApi($mediaArray);

            $index++;
        }

        $maxId           = $jsonResponse->{'items'}[-1]{'id'};
        $isMoreAvailable = $jsonResponse->{'more_available'};
    }

    return $medias;
}

sub getPaginateMedias($$;$)
{
    my ($self, $username, $maxId) = @_;
    $maxId //= '';

    my $hasNextPage = 1;
    my $medias = [];

    my $toReturn = {
        'medias'      => $medias,
        'maxId'       => $maxId,
        'hasNextPage' => $hasNextPage
    };

    my $response = $self->{browser}->get(Instagram::API::Endpoints::getAccountMediasJsonLink($username, $maxId));
cluck Data::Dumper::Dumper $response if ($response->code == 403);
    croak 'Response code is ' . $response->code
        . '. Body: ' . $response->content
        . ' Something went wrong. Please report issue.' if ($response->code != 200);
    #throw new InstagramException('Response code is ' . $response->code . '. Body: ' . $response->body . ' Something went wrong. Please report issue.');

    my $jsonResponse;
    try {
        $jsonResponse = decode_json($response->content);
    } catch {
        croak 'Response decoding failed. Returned data corrupted or this library outdated. Please report issue';
    };

    return $toReturn unless @{$jsonResponse->{'items'} // []};

    foreach my $mediaArray (@{$jsonResponse->{'items'}}) {
        push @{$medias}, Instagram::API::Media->fromApi($mediaArray);
    }

    $maxId       = $jsonResponse->{'items'}[-1]{'id'};
    $hasNextPage = $jsonResponse->{'more_available'};

    $toReturn = {
        'medias'      => $medias,
        'maxId'       => $maxId,
        'hasNextPage' => $hasNextPage
    };

    return $toReturn;
}

sub getMediaByCode($$)
{
    my ($self, $mediaCode) = @_;

    return $self->getMediaByUrl(Instagram::API::Endpoints::getMediaPageLink($mediaCode));
}

sub getMediaByUrl($$)
{
    my ($self, $mediaUrl) = @_;

    croak 'Malformed media url' unless is_uri($mediaUrl);
    #throw new \InvalidArgumentException('Malformed media url');

    my $response = $self->{browser}->get(($mediaUrl =~ s!/+$!!r) . '/?__a=1');

    croak 'Media with given code does not exist or account is private.' if ($response->code == 404);
    #throw new InstagramNotFoundException('Media with given code does not exist or account is private.');
cluck Data::Dumper::Dumper $response if ($response->code == 403);
    croak 'Response code is ' . $response->code
        . '. Body: ' . $response->content
        . ' Something went wrong. Please report issue.' if ($response->code != 200);
    #throw new InstagramException('Response code is ' . $response->code . '. Body: ' . $response->body . ' Something went wrong. Please report issue.');

    my $mediaArray;
    try {
        $mediaArray = decode_json($response->content);
    } catch {
        croak 'Response decoding failed. Returned data corrupted or this library outdated. Please report issue';
    };

    croak 'Media with this code does not exist' unless exists($mediaArray->{'media'});
    #throw new InstagramException('Media with this code does not exist');

    return Instagram::API::Media->fromMediaPage($mediaArray->{'media'});
}

sub getMediasByTag($$;$$)
{
    my ($self, $tag, $count, $maxId) = @_;
    $count //= 12;
    $maxId //= '';

    my $medias      = [];
    my $index       = 0;
    my $hasNextPage = 1;

    while ($index < $count && $hasNextPage) {
        my $response = $self->{browser}->get(Instagram::API::Endpoints::getMediasJsonByTagLink($tag, $maxId));
cluck Data::Dumper::Dumper $response if ($response->code == 403);
        croak 'Response code is ' . $response->code
            . '. Body: ' . $response->content
            . ' Something went wrong. Please report issue.' if ($response->code != 200);
        #throw new InstagramException('Response code is ' . $response->code . '. Body: ' . $response->body . ' Something went wrong. Please report issue.');

        my $jsonResponse;
        try {
            $jsonResponse = decode_json($response->content);
        } catch {
            croak 'Response decoding failed. Returned data corrupted or this library outdated. Please report issue';
        };
        #throw new InstagramException('Response decoding failed. Returned data corrupted or this library outdated. Please report issue');
        return $medias unless $jsonResponse->{'tag'}{'media'}{'count'};

        my $nodes = $jsonResponse->{'tag'}{'media'}{'nodes'};
        return $medias unless @{$nodes};

        foreach my $mediaArray (@{$nodes}) {
            return $medias if ($index == $count);

            push @{$medias}, Instagram::API::Media->fromTagPage($mediaArray);
            $index++;
        }

        $maxId       = $jsonResponse->{'tag'}{'media'}{'page_info'}{'end_cursor'};
        $hasNextPage = $jsonResponse->{'tag'}{'media'}{'page_info'}{'has_next_page'};
    }

    return $medias;
}

sub getPaginateMediasByTag($$;$)
{
    my ($self, $tag, $maxId) = @_;
    $maxId //= '';

    my $hasNextPage = 1;
    my $medias      = [];

    my $toReturn = {
        'medias'      => $medias,
        'maxId'       => $maxId,
        'hasNextPage' => $hasNextPage
    };

    my $response = $self->{browser}->get(Instagram::API::Endpoints::getMediasJsonByTagLink($tag, $maxId));
cluck Data::Dumper::Dumper $response if ($response->code == 403);
    croak 'Response code is ' . $response->code
        . '. Body: ' . $response->content
        . ' Something went wrong. Please report issue.' if ($response->code != 200);
    #throw new InstagramException('Response code is ' . $response->code . '. Body: ' . $response->body . ' Something went wrong. Please report issue.');

    my $jsonResponse;
    try {
        $jsonResponse = decode_json($response->content);
    } catch {
        croak 'Response decoding failed. Returned data corrupted or this library outdated. Please report issue';
    };
    #throw new InstagramException('Response decoding failed. Returned data corrupted or this library outdated. Please report issue');
    return $toReturn unless $jsonResponse->{'tag'}{'media'}{'count'};

    my $nodes = $jsonResponse->{'tag'}{'media'}{'nodes'};
    return $toReturn unless @{$nodes};

    foreach my $mediaArray (@{$nodes}) {
        push @{$medias}, Instagram::API::Media->fromTagPage($mediaArray);
    }

    $maxId       = $jsonResponse->{'tag'}{'media'}{'page_info'}{'end_cursor'};
    $hasNextPage = $jsonResponse->{'tag'}{'media'}{'page_info'}{'has_next_page'};

    $toReturn = {
        'medias'      => $medias,
        'maxId'       => $maxId,
        'hasNextPage' => $hasNextPage
    };

    return $toReturn;
}

sub searchAccountsByUsername($$)
{
    my ($self, $username) = @_;

    my $response = $self->{browser}->get(Instagram::API::Endpoints::getGeneralSearchJsonLink($username));
cluck Data::Dumper::Dumper $response if ($response->code == 403);
    croak 'Response code is ' . $response->code
        . '. Body: ' . $response->content
        . ' Something went wrong. Please report issue.' if ($response->code != 200);
    #throw new InstagramException('Response code is ' . $response->code . '. Body: ' . $response->body . ' Something went wrong. Please report issue.');

    my $jsonResponse;
    try {
        $jsonResponse = decode_json($response->content);
    } catch {
        croak 'Response decoding failed. Returned data corrupted or this library outdated. Please report issue';
    };

    croak 'Response code is not equal 200. Something went wrong. Please report issue.' if (!exists($jsonResponse->{'status'}) || $jsonResponse->{'status'} ne 'ok');
    #throw new InstagramException('Response code is not equal 200. Something went wrong. Please report issue.');

    my $accounts = [];

    return $accounts if (!exists($jsonResponse->{'users'}) || !@{$jsonResponse->{'users'}});

    foreach my $jsonAccount (@{$jsonResponse->{'users'}}) {
        push @{$accounts}, Instagram::API::Account->fromSearchPage($jsonAccount->{'user'});
    }

    return $accounts;
}

sub searchTagsByTagName($$)
{
    my ($self, $tag) = @_;

    my $response = $self->{browser}->get(Instagram::API::Endpoints::getGeneralSearchJsonLink($tag));

    #if ($response->code == 404) {
    #    #throw new InstagramNotFoundException('Account with given username does not exist.');
    #    croak 'Account with given username does not exist.';
    #}
cluck Data::Dumper::Dumper $response if ($response->code == 403);
    croak 'Response code is ' . $response->code
        . '. Body: ' . $response->content
        . ' Something went wrong. Please report issue.' if ($response->code != 200);
    #throw new InstagramException('Response code is ' . $response->code . '. Body: ' . $response->body . ' Something went wrong. Please report issue.');

    my $jsonResponse;
    try {
        $jsonResponse = decode_json($response->content);
    } catch {
        croak 'Response decoding failed. Returned data corrupted or this library outdated. Please report issue';
    };

    croak 'Response code is not equal 200. Something went wrong. Please report issue.' if (!exists($jsonResponse->{'status'}) || $jsonResponse->{'status'} ne 'ok');
    #throw new InstagramException('Response code is not equal 200. Something went wrong. Please report issue.');

    my $hashtags = [];

    return $hashtags if (!exists($jsonResponse->{'hashtags'}) || @{$jsonResponse->{'hashtags'}} == 0);

    foreach my $jsonHashtag (@{$jsonResponse->{'hashtags'}}) {
        push @{$hashtags}, Instagram::API::Tag->fromSearchPage($jsonHashtag->{'hashtag'});
    }

    return $hashtags;
}

sub getTopMediasByTagName($$)
{
    my ($self, $tagName) = @_;

    my $response = $self->{browser}->get(Instagram::API::Endpoints::getMediasJsonByTagLink($tagName, ''));

    if ($response->code == 404) {
        #throw new InstagramNotFoundException('Account with given username does not exist.');
        croak 'Account with given username does not exist.';
    }
cluck Data::Dumper::Dumper $response if ($response->code == 403);
    croak 'Response code is ' . $response->code
        . '. Body: ' . $response->content
        . ' Something went wrong. Please report issue.' if ($response->code != 200);
    #throw new InstagramException('Response code is ' . $response->code . '. Body: ' . $response->body . ' Something went wrong. Please report issue.');

    my $jsonResponse;
    try {
        $jsonResponse = decode_json($response->content);
    } catch {
        croak 'Response decoding failed. Returned data corrupted or this library outdated. Please report issue';
    };

    my $medias = [];

    return $medias unless (exists($jsonResponse->{'tag'}{'top_posts'}{'nodes'}) && @{$jsonResponse->{'tag'}{'top_posts'}{'nodes'}});

    foreach my $mediaArray (@{$jsonResponse->{'tag'}{'top_posts'}{'nodes'}}) {
        push @{$medias}, Instagram::API::Media->fromTagPage($mediaArray);
    }

    return $medias;
}

sub getMediaById($$)
{
    my ($self, $mediaId) = @_;

    my $mediaLink = Instagram::API::Media->getLinkFromId($mediaId);

    return $self->getMediaByUrl($mediaLink);
}

sub getMediaCommentsById($$;$$)
{
    my ($self, $mediaId, $count, $maxId) = @_;
    $count //= 10;

    my $code = Instagram::API::Media->getCodeFromId($mediaId);

    return $self->getMediaCommentsByCode($code, $count, $maxId);
}

sub getMediaCommentsByCode($$;$$)
{
    my ($self, $code, $count, $maxId) = @_;
    $count //= 10;

    my $remain      = $count;
    my $index       = 0;
    my $hasPrevious = 1;
    my $comments    = [];

    while ($hasPrevious && $index < $count) {
        my $numberOfCommentsToRetreive;

        if ($remain > MAX_COMMENTS_PER_REQUEST) {
            $numberOfCommentsToRetreive  = MAX_COMMENTS_PER_REQUEST;
            $remain                     -= MAX_COMMENTS_PER_REQUEST;
            $index                      += MAX_COMMENTS_PER_REQUEST;
        } else {
            $numberOfCommentsToRetreive  = $remain;
            $index                      += $remain;
            $remain                      = 0;
        }

        my $parameters;
        if (!defined($maxId)) {
            $parameters = Instagram::API::Endpoints::getLastCommentsByCodeLink($code, $numberOfCommentsToRetreive);
        } else {
            $parameters = Instagram::API::Endpoints::getCommentsBeforeCommentIdByCode($code, $numberOfCommentsToRetreive, $maxId);
        }

        my $response = $self->_getContentsFromUrl($parameters);
cluck Data::Dumper::Dumper $response if ($response->code == 403);
        croak 'Response code is ' . $response->code
            . '. Body: ' . $response->content
            . ' Something went wrong. Please report issue.' if ($response->code != 200);
        #throw new InstagramException('Response code is ' . $response->code . '. Body: ' . $response->body . ' Something went wrong. Please report issue.');

        my $jsonResponse;
        try {
            $jsonResponse = decode_json($response->content);
        } catch {
            croak 'Response decoding failed. Returned data corrupted or this library outdated. Please report issue';
        };
        #throw new InstagramException('Response decoding failed. Returned data corrupted or this library outdated. Please report issue');

        my $nodes = $jsonResponse->{'comments'}{'nodes'};
        return $comments unless @{$nodes};

        foreach my $commentArray (@{$nodes}) {
            push @{$comments}, Instagram::API::Comment->fromApi($commentArray);
        }

        my $hasPrevious      = $jsonResponse->{'comments'}{'page_info'}{'has_previous_page'};
        my $numberOfComments = $jsonResponse->{'comments'}{'count'};

        $count = $numberOfComments if ($count > $numberOfComments);

        $maxId = $nodes->[-1]{'id'};
    }

    return $comments;
}

sub getLocationTopMediasById($$)
{
    my ($self, $facebookLocationId) = @_;

    my $response = $self->{browser}->get(Instagram::API::Endpoints::getMediasJsonByLocationIdLink($facebookLocationId));

    croak 'Location with this id doesn\'t exist' if ($response->code == 404);
    #throw new InstagramNotFoundException('Location with this id doesn\'t exist');
cluck Data::Dumper::Dumper $response if ($response->code == 403);
    croak 'Response code is ' . $response->code
        . '. Body: ' . $response->content
        . ' Something went wrong. Please report issue.' if ($response->code != 200);
    #throw new InstagramException('Response code is ' . $response->code . '. Body: ' . $response->body . ' Something went wrong. Please report issue.');

    my $jsonResponse;
    try {
        $jsonResponse = decode_json($response->content);
    } catch {
        croak 'Response decoding failed. Returned data corrupted or this library outdated. Please report issue';
    };
    #throw new InstagramException('Response decoding failed. Returned data corrupted or this library outdated. Please report issue');

    my $nodes = $jsonResponse->{'location'}{'top_posts'}{'nodes'};

    my $medias = [];

    foreach my $mediaArray (@{$nodes}) {
        push @{$medias}, Instagram::API::Media->fromTagPage($mediaArray);
    }

    return $medias;
}

sub getLocationMediasById($$;$$)
{
    my ($self, $facebookLocationId, $quantity, $offset) = @_;
    $quantity //= 12;
    $offset   //= '';

    my $index   = 0;
    my $medias  = [];
    my $hasNext = 1;

    while ($index < $quantity && $hasNext) {
        my $response = $self->{browser}->get(Instagram::API::Endpoints::getMediasJsonByLocationIdLink($facebookLocationId, $offset));
cluck Data::Dumper::Dumper $response if ($response->code == 403);
        croak 'Response code is ' . $response->code
            . '. Body: ' . $response->content
            . ' Something went wrong. Please report issue.' if ($response->code != 200);
        #throw new InstagramException('Response code is ' . $response->code . '. Body: ' . $response->body . ' Something went wrong. Please report issue.');

        my $jsonResponse;
        try {
            $jsonResponse = decode_json($response->content);
        } catch {
            croak 'Response decoding failed. Returned data corrupted or this library outdated. Please report issue';
        };
        #throw new InstagramException('Response decoding failed. Returned data corrupted or this library outdated. Please report issue');

        my $nodes = $jsonResponse->{'location'}{'media'}{'nodes'};

        return $medias unless @{$nodes};

        foreach my $mediaArray (@{$nodes}) {
            return $medias if ($index == $quantity);

            push @{$medias}, Instagram::API::Media->fromTagPage($mediaArray);

            $index++;
        }

        $hasNext = $jsonResponse->{'location'}{'media'}{'page_info'}{'has_next_page'};
        $offset  = $jsonResponse->{'location'}{'media'}{'page_info'}{'end_cursor'};
    }

    return $medias;
}

sub getLocationById($$)
{
    my ($self, $facebookLocationId) = @_;

    my $response = $self->{browser}->get(Instagram::API::Endpoints::getMediasJsonByLocationIdLink($facebookLocationId));

    croak 'Location with this id doesn\'t exist' if ($response->code == 404);
    #throw new InstagramNotFoundException('Location with this id doesn\'t exist');
cluck Data::Dumper::Dumper $response if ($response->code == 403);
    croak 'Response code is ' . $response->code
        . '. Body: ' . $response->content
        . ' Something went wrong. Please report issue.' if ($response->code != 200);
    #throw new InstagramException('Response code is ' . $response->code . '. Body: ' . $response->body . ' Something went wrong. Please report issue.');

    my $jsonResponse;
    try {
        $jsonResponse = decode_json($response->content);
    } catch {
        croak 'Response decoding failed. Returned data corrupted or this library outdated. Please report issue';
    };
    #throw new InstagramException('Response decoding failed. Returned data corrupted or this library outdated. Please report issue');

    return Instagram::API::Location->makeLocation($jsonResponse->{'location'});
}

1;
__END__

=head1 NAME

Instagram::API - Perl extension for blah blah blah

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

=head3 getAccount

=head3 getAccountById

=head3 getLocationById

=head3 getLocationMediasById

=head3 getLocationTopMediasById

=head3 getMediaByCode

=head3 getMediaById

=head3 getMediaByUrl

=head3 getMediaCommentsByCode

=head3 getMediaCommentsById

=head3 getMedias

=head3 getMediasByTag

=head3 getPaginateMedias

=head3 getPaginateMediasByTag

=head3 getTopMediasByTagName

=head3 searchAccountsByUsername

=head3 searchTagsByTagName

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
