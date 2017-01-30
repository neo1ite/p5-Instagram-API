package Instagram::API;

use utf8;
use strict;
use warnings;
use autouse 'Data::Dumper';

use Carp;
use Try::Tiny;
use JSON::MaybeXS;
use Data::Validate::URI qw(is_uri);

require Exporter;

our @ISA = qw(Exporter);

our %EXPORT_TAGS = ( 'all' => [ qw(

) ] );

our @EXPORT_OK = ( @{ $EXPORT_TAGS{'all'} } );

our @EXPORT = qw(

);

our $VERSION = '0.01';

use constant MAX_COMMENTS_PER_REQUEST => 300;

sub new {
    my ($invocant, $params) = @_;

    my $class = ref($invocant) || $invocant;
    my $self = {};
    $self->{browser} ||= LWP::UserAgent->new();
	carp 'Browser is not a LWP::UserAgent' unless $self->{browser}->isa('LWP::UserAgent');

    bless($self, $class);

    return $self;
}

sub getAccount
{
    my ($self, $username) = @_;

    my $response = $self->{browser}->get(Instagram::API::Endpoints->getAccountJsonLink($username));
    if ($response->code == 404) {
        #throw new InstagramNotFoundException('Account with given username does not exist.');
        carp 'Account with given username does not exist.';
    }
    if ($response->code != 200) {
        #throw new InstagramException('Response code is ' . $response->code . '. Body: ' . $response->body . ' Something went wrong. Please report issue.');
        carp 'Response code is ' . $response->code . '. Body: ' . $response->body . ' Something went wrong. Please report issue.';
    }

    my $userArray = decode_json($response->content);
    if (!exists($userArray->{'user'})) {
        #throw new InstagramException('Account with this username does not exist');
        carp 'Account with this username does not exist';
    }
    return Instagram::API::Account->fromAccountPage($userArray->{'user'});
}

sub getAccountById
{
    my ($self, $id) = @_;

    if (!is_numeric($id)) {
        #throw new InvalidArgumentException('User id must be integer or integer wrapped in string');
        carp 'User id must be integer or integer wrapped in string';
    }

    my $parameters = Instagram::API::Endpoints->getAccountJsonInfoLinkByAccountId($id);
    my $userArray = decode_json($self->_getContentsFromUrl($parameters));

    if ($userArray->{'status'} == 'fail') {
        #throw new InstagramException($userArray['message']);
        carp $userArray->{'message'};
    }

    if (!exists($userArray->{'username'})) {
        #throw new InstagramNotFoundException('User with this id not found');
        carp 'User with this id not found';
    }

    return Instagram::API::Account->fromAccountPage($userArray);
}

sub _getContentsFromUrl
{
    my ($self, $parameters) = @_;

    #if (!function_exists('curl_init')) {
    #    return;
    #}

    my $random = $self->_generateRandomString();
    my $request = HTTP::Request->new(
        'POST' => Instagram::API::Endpoints::INSTAGRAM_QUERY_URL(),
        HTTP::Headers->new(
            'Cookie'      => 'csrftoken=' . $random . ';',
            'X-Csrftoken' => $random,
            'Referer' => 'https://www.instagram.com/',
        ),
        'q=' . $parameters
    );
    #my $ch = curl_init();
    #curl_setopt($ch, CURLOPT_URL, Instagram::API::Endpoints::INSTAGRAM_QUERY_URL);
    #curl_setopt($ch, CURLOPT_RETURNTRANSFER, TRUE);
    #curl_setopt($ch, CURLOPT_POST, 1);
    #curl_setopt($ch, CURLOPT_POSTFIELDS, 'q=' . $parameters);
    my $response = $self->{browser}->request($request);

    #my @headers;
    #push @headers, "Cookie:  csrftoken=$random;";
    #push @headers, "X-Csrftoken: $random";
    #push @headers, "Referer: https://www.instagram.com/";
    #curl_setopt($ch, CURLOPT_HTTPHEADER, \@headers);
    #my $output = curl_exec($ch);
    #curl_close($ch);

    return $response->content;
}

sub _generateRandomString
{
    my ($self, $length) = @_;
    $length //= 10;

    my @characters = (0..9,'a'..'z','A'..'Z');#'0123456789abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ';
    my $charactersLength = @characters;
    my $randomString = '';

    for (my $i = 0; $i < $length; $i++) {
        $randomString .= $characters[sprintf('%.f', rand($charactersLength - 1))];
    }

    return $randomString;
}

sub getMedias
{
    my ($self, $username, $count, $maxId) = @_;
    $count //= 20;
    $maxId //= '';

    my $index = 0;
    my $medias = [];
    my $isMoreAvailable = 1;

    while ($index < $count && $isMoreAvailable) {
        my $response = $self->{browser}->get(Instagram::API::Endpoints->getAccountMediasJsonLink($username, $maxId));
        if ($response->code != 200) {
            #throw new InstagramException('Response code is ' . $response->code . '. Body: ' . $response->body . ' Something went wrong. Please report issue.');
            carp 'Response code is ' . $response->code . '. Body: ' . $response->body . ' Something went wrong. Please report issue.';
        }

        my $arr = decode_json($response->content);
        if (ref($arr) ne 'ARRAY') {
            #throw new InstagramException('Response code is ' . $response->code . '. Body: ' . $response->body . ' Something went wrong. Please report issue.');
            carp 'Response code is ' . $response->code . '. Body: ' . $response->body . ' Something went wrong. Please report issue.';
        }
        if (@{$arr->{'items'}} == 0) {
            return [];
        }
        foreach my $mediaArray (@{$arr->{'items'}}) {
            if ($index == $count) {
                return $medias;
            }
            push @{$medias}, Instagram::API::Media->fromApi($mediaArray);
            $index++;
        }
        if (@{$arr->{'items'}} == 0) {
            return $medias;
        }
        $maxId = $arr->{'items'}[-1]{'id'};
        $isMoreAvailable = $arr->{'more_available'};
    }

    return $medias;
}

sub getPaginateMedias
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

    my $response = $self->{browser}->get(Instagram::API::Endpoints->getAccountMediasJsonLink($username, $maxId));

    if ($response->code != 200) {
        #throw new InstagramException('Response code is ' . $response->code . '. Body: ' . $response->body . ' Something went wrong. Please report issue.');
        carp 'Response code is ' . $response->code . '. Body: ' . $response->body . ' Something went wrong. Please report issue.';
    }

    my $arr = decode_json($response->content);

    if (ref($arr) ne 'ARRAY') {
        #throw new InstagramException('Response code is ' . $response->code . '. Body: ' . $response->body . ' Something went wrong. Please report issue.');
        carp 'Response code is ' . $response->code . '. Body: ' . $response->body . ' Something went wrong. Please report issue.';
    }

    if (@{$arr->{'items'}} == 0) {
        return $toReturn;
    }

    foreach my $mediaArray (@{$arr->{'items'}}) {
        push @{$medias}, Instagram::API::Media->fromApi($mediaArray);
    }

    $maxId = $arr->{'items'}[-1]{'id'};
    $hasNextPage = $arr->{'more_available'};

    $toReturn = {
        'medias'      => $medias,
        'maxId'       => $maxId,
        'hasNextPage' => $hasNextPage
    };

    return $toReturn;
}

sub getMediaByCode
{
    my ($self, $mediaCode) = @_;

    return $self->getMediaByUrl(Instagram::API::Endpoints->getMediaPageLink($mediaCode));
}

sub getMediaByUrl
{
    my ($self, $mediaUrl) = @_;

    if (!is_uri($mediaUrl)) {
        #throw new \InvalidArgumentException('Malformed media url');
        carp 'Malformed media url';
    }

    my $response = $self->{browser}->get(($mediaUrl =~ s!/+$!!r) . '/?__a=1');

    if ($response->code == 404) {
        #throw new InstagramNotFoundException('Media with given code does not exist or account is private.');
        carp 'Media with given code does not exist or account is private.';
    }

    if ($response->code != 200) {
        #throw new InstagramException('Response code is ' . $response->code . '. Body: ' . $response->body . ' Something went wrong. Please report issue.');
        carp 'Response code is ' . $response->code . '. Body: ' . $response->body . ' Something went wrong. Please report issue.';
    }

    my $mediaArray = decode_json($response->content);
    
    if (!exists($mediaArray->{'media'})) {
        #throw new InstagramException('Media with this code does not exist');
        carp 'Media with this code does not exist';
    }

    return Instagram::API::Media->fromMediaPage($mediaArray->{'media'});
}

sub getMediasByTag
{
    my ($self, $tag, $count, $maxId) = @_;
    $count //= 12;
    $maxId //= '';

    my $index = 0;
    my $medias = [];
    my $hasNextPage = 1;

    while ($index < $count && $hasNextPage) {
        my $response = $self->{browser}->get(Instagram::API::Endpoints->getMediasJsonByTagLink($tag, $maxId));
        if ($response->code != 200) {
            #throw new InstagramException('Response code is ' . $response->code . '. Body: ' . $response->body . ' Something went wrong. Please report issue.');
            carp 'Response code is ' . $response->code . '. Body: ' . $response->body . ' Something went wrong. Please report issue.';
        }

        my $arr = decode_json($response->content);
        if (ref($arr) ne 'ARRAY') {
            #throw new InstagramException('Response decoding failed. Returned data corrupted or this library outdated. Please report issue');
            carp 'Response decoding failed. Returned data corrupted or this library outdated. Please report issue';
        }
        if (@{$arr->{'tag'}{'media'}{'count'}} == 0) {
            return [];
        }
        my $nodes = $arr->{'tag'}{'media'}{'nodes'};
        foreach my $mediaArray (@{$nodes}) {
            if ($index == $count) {
                return $medias;
            }
            push @{$medias}, Instagram::API::Media->fromTagPage($mediaArray);
            $index++;
        }
        if (@{$nodes} == 0) {
            return $medias;
        }
        $maxId = $arr->{'tag'}{'media'}{'page_info'}{'end_cursor'};
        $hasNextPage = $arr->{'tag'}{'media'}{'page_info'}{'has_next_page'};
    }

    return $medias;
}

sub getPaginateMediasByTag
{
    my ($self, $tag, $maxId) = @_;
    $maxId //= '';

    my $hasNextPage = 1;
    my $medias = [];

    my $toReturn = {
        'medias'      => $medias,
        'maxId'       => $maxId,
        'hasNextPage' => $hasNextPage
    };

    my $response = $self->{browser}->get(Instagram::API::Endpoints->getMediasJsonByTagLink($tag, $maxId));

    if ($response->code != 200) {
        #throw new InstagramException('Response code is ' . $response->code . '. Body: ' . $response->body . ' Something went wrong. Please report issue.');
        carp 'Response code is ' . $response->code . '. Body: ' . $response->body . ' Something went wrong. Please report issue.';
    }

    my $arr = decode_json($response->content);

    if (ref($arr) ne 'ARRAY') {
        #throw new InstagramException('Response decoding failed. Returned data corrupted or this library outdated. Please report issue');
        carp 'Response decoding failed. Returned data corrupted or this library outdated. Please report issue';
    }

    if (@{$arr->{'tag'}{'media'}{'count'}} == 0) {
        return $toReturn;
    }

    my $nodes = $arr->{'tag'}{'media'}{'nodes'};

    if (@{$nodes} == 0) {
        return $toReturn;
    }

    foreach my $mediaArray (@{$nodes}) {
        push @{$medias}, Instagram::API::Media->fromTagPage($mediaArray);
    }

    $maxId       = $arr->{'tag'}{'media'}{'page_info'}{'end_cursor'};
    $hasNextPage = $arr->{'tag'}{'media'}{'page_info'}{'has_next_page'};

    $toReturn = {
        'medias'      => $medias,
        'maxId'       => $maxId,
        'hasNextPage' => $hasNextPage
    };

    return $toReturn;
}

sub searchAccountsByUsername
{
    my ($self, $username) = @_;

    my $response = $self->{browser}->get(Instagram::API::Endpoints->getGeneralSearchJsonLink($username));

    if ($response->code == 404) {
        #throw new InstagramNotFoundException('Account with given username does not exist.');
        carp 'Account with given username does not exist.';
    }

    if ($response->code != 200) {
        #throw new InstagramException('Response code is ' . $response->code . '. Body: ' . $response->body . ' Something went wrong. Please report issue.');
        carp 'Response code is ' . $response->code . '. Body: ' . $response->body . ' Something went wrong. Please report issue.';
    }

    my $jsonResponse = decode_json($response->content);
    if (!exists($jsonResponse->{'status'}) || $jsonResponse->{'status'} != 'ok') {
        #throw new InstagramException('Response code is not equal 200. Something went wrong. Please report issue.');
        carp 'Response code is not equal 200. Something went wrong. Please report issue.';
    }
    if (!exists($jsonResponse->{'users'}) || @{$jsonResponse->{'users'}} == 0) {
        return [];
    }

    my $accounts = [];
    foreach my $jsonAccount (@{$jsonResponse->{'users'}}) {
        push @{$accounts}, Instagram::API::Account->fromSearchPage($jsonAccount->{'user'});
    }

    return $accounts;
}

sub searchTagsByTagName
{
    my ($self, $tag) = @_;

    my $response = $self->{browser}->get(Instagram::API::Endpoints->getGeneralSearchJsonLink($tag));

    if ($response->code == 404) {
        #throw new InstagramNotFoundException('Account with given username does not exist.');
        carp 'Account with given username does not exist.';
    }

    if ($response->code != 200) {
        #throw new InstagramException('Response code is ' . $response->code . '. Body: ' . $response->body . ' Something went wrong. Please report issue.');
        carp 'Response code is ' . $response->code . '. Body: ' . $response->body . ' Something went wrong. Please report issue.';
    }

    my $jsonResponse = decode_json($response->content);
    if (!exists($jsonResponse->{'status'}) || $jsonResponse->{'status'} != 'ok') {
        #throw new InstagramException('Response code is not equal 200. Something went wrong. Please report issue.');
        carp 'Response code is not equal 200. Something went wrong. Please report issue.';
    }

    if (!exists($jsonResponse->{'hashtags'}) || @{$jsonResponse->{'hashtags'}} == 0) {
        return [];
    }

    my $hashtags = [];
    foreach my $jsonHashtag (@{$jsonResponse->{'hashtags'}}) {
        push @{$hashtags}, Tag::fromSearchPage($jsonHashtag->{'hashtag'});
    }

    return $hashtags;
}

sub getTopMediasByTagName
{
    my ($self, $tagName) = @_;

    my $response = $self->{browser}->get(Instagram::API::Endpoints->getMediasJsonByTagLink($tagName, ''));

    if ($response->code == 404) {
        #throw new InstagramNotFoundException('Account with given username does not exist.');
        carp 'Account with given username does not exist.';
    }

    if ($response->code != 200) {
        #throw new InstagramException('Response code is ' . $response->code . '. Body: ' . $response->body . ' Something went wrong. Please report issue.');
        carp 'Response code is ' . $response->code . '. Body: ' . $response->body . ' Something went wrong. Please report issue.';
    }

    my $jsonResponse = decode_json($response->content);

    my $medias = [];
    foreach my $mediaArray (@{$jsonResponse->{'tag'}{'top_posts'}{'nodes'}}) {
        push @{$medias}, Instagram::API::Media->fromTagPage($mediaArray);
    }

    return $medias;
}

sub getMediaById
{
    my ($self, $mediaId) = @_;
    my $mediaLink = Media::Instagram::API::Media->getLinkFromId($mediaId);

    return $self->getMediaByUrl($mediaLink);
}

sub getMediaCommentsById
{
    my ($self, $mediaId, $count, $maxId) = @_;
    $count //= 10;

    my $code = Instagram::API::Media->getCodeFromId($mediaId);

    return $self->getMediaCommentsByCode($code, $count, $maxId);
}

sub getMediaCommentsByCode
{
    my ($self, $code, $count, $maxId) = @_;
    $count //= 10;

    my $remain      = $count;
    my $comments    = [];
    my $index       = 0;
    my $hasPrevious = 1;

    while ($hasPrevious && $index < $count) {
        my $numberOfCommentsToRetreive;
        if ($remain > MAX_COMMENTS_PER_REQUEST) {
            $numberOfCommentsToRetreive = MAX_COMMENTS_PER_REQUEST;
            $remain -= MAX_COMMENTS_PER_REQUEST;
            $index += MAX_COMMENTS_PER_REQUEST;
        } else {
            $numberOfCommentsToRetreive = $remain;
            $index += $remain;
            $remain = 0;
        }

        my $parameters;
        if (!isset($maxId)) {
            $parameters = Instagram::API::Endpoints->getLastCommentsByCodeLink($code, $numberOfCommentsToRetreive);
        } else {
            $parameters = Instagram::API::Endpoints->getCommentsBeforeCommentIdByCode($code, $numberOfCommentsToRetreive, $maxId);
        }

        my $jsonResponse = decode_json($self->_getContentsFromUrl($parameters));
        my $nodes = $jsonResponse->{'comments'}{'nodes'};

        foreach my $commentArray (@{$nodes}) {
            push @{$comments}, Comment::fromApi($commentArray);
        }

        my $hasPrevious      = $jsonResponse->{'comments'}{'page_info'}{'has_previous_page'};
        my $numberOfComments = $jsonResponse->{'comments'}{'count'};

        if ($count > $numberOfComments) {
            $count = $numberOfComments;
        }
        if (sizeof($nodes) == 0) {
            return $comments;
        }

        $maxId = $nodes->[-1]{'id'};
    }

    return $comments;
}

sub getLocationTopMediasById
{
    my ($self, $facebookLocationId) = @_;

    my $response = $self->{browser}->get(Instagram::API::Endpoints->getMediasJsonByLocationIdLink($facebookLocationId));

    if ($response->code == 404) {
        #throw new InstagramNotFoundException('Location with this id doesn\'t exist');
        carp 'Location with this id doesn\'t exist';
    }

    if ($response->code != 200) {
        #throw new InstagramException('Response code is ' . $response->code . '. Body: ' . $response->body . ' Something went wrong. Please report issue.');
        carp 'Response code is ' . $response->code . '. Body: ' . $response->body . ' Something went wrong. Please report issue.';
    }

    my $jsonResponse = decode_json($response->content);
    my $nodes = $jsonResponse->{'location'}{'top_posts'}{'nodes'};
    my $medias = [];

    foreach my $mediaArray ($nodes) {
        push @{$medias}, Instagram::API::Media->fromTagPage($mediaArray);
    }

    return $medias;
}

sub getLocationMediasById
{
    my ($self, $facebookLocationId, $quantity, $offset) = @_;
    $quantity //= 12;
    $offset //= '';

    my $index = 0;
    my $medias = [];
    my $hasNext = 1;

    while ($index < $quantity && $hasNext) {
        my $response = $self->{browser}->get(Instagram::API::Endpoints->getMediasJsonByLocationIdLink($facebookLocationId, $offset));

        if ($response->code != 200) {
            #throw new InstagramException('Response code is ' . $response->code . '. Body: ' . $response->body . ' Something went wrong. Please report issue.');
            carp 'Response code is ' . $response->code . '. Body: ' . $response->body . ' Something went wrong. Please report issue.';
        }

        my $arr = decode_json($response->content);
        my $nodes = $arr->{'location'}{'media'}{'nodes'};

        foreach my $mediaArray (@{$nodes}) {
            if ($index == $quantity) {
                return $medias;
            }
            push @{$medias}, Instagram::API::Media->fromTagPage($mediaArray);
            $index++;
        }

        if (@{$nodes} == 0) {
            return $medias;
        }

        $hasNext = $arr->{'location'}{'media'}{'page_info'}{'has_next_page'};
        $offset  = $arr->{'location'}{'media'}{'page_info'}{'end_cursor'};
    }

    return $medias;
}

sub getLocationById
{
    my ($self, $facebookLocationId) = @_;

    my $response = $self->{browser}->get(Instagram::API::Endpoints->getMediasJsonByLocationIdLink($facebookLocationId));

    if ($response->code == 404) {
        #throw new InstagramNotFoundException('Location with this id doesn\'t exist');
        carp 'Location with this id doesn\'t exist';
    }

    if ($response->code != 200) {
        #throw new InstagramException('Response code is ' . $response->code . '. Body: ' . $response->body . ' Something went wrong. Please report issue.');
        carp 'Response code is ' . $response->code . '. Body: ' . $response->body . ' Something went wrong. Please report issue.';
    }

    my $jsonResponse = decode_json($response->content);

    return Location::makeLocation($jsonResponse->{'location'});
}

1;
__END__

=head1 NAME

Instagram::API - Perl extension for blah blah blah

=head1 SYNOPSIS

  use Instagram::API;
  blah blah blah

=head1 DESCRIPTION

Stub documentation for Instagram::API, created by h2xs. It looks like the
author of the extension was negligent enough to leave the stub
unedited.

Blah blah blah.

=head2 EXPORT

None by default.



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
