package Instagram::API::Endpoints;

use utf8;
use strict;
use warnings;
use autouse 'Data::Dumper';

use URI::Escape;

use constant BASE_URL                           => 'https://www.instagram.com';
use constant ACCOUNT_PAGE                       => 'https://www.instagram.com/{username}';
use constant MEDIA_LINK                         => 'https://www.instagram.com/p/{code}';
use constant ACCOUNT_MEDIAS                     => 'https://www.instagram.com/{username}/media?max_id={max_id}';
use constant ACCOUNT_JSON_INFO                  => 'https://www.instagram.com/{username}/?__a=1';
use constant MEDIA_JSON_INFO                    => 'https://www.instagram.com/p/{code}/?__a=1';
use constant MEDIA_JSON_BY_LOCATION_ID          => 'https://www.instagram.com/explore/locations/{{facebookLocationId}}/?__a=1&max_id={{maxId}}';
use constant MEDIA_JSON_BY_TAG                  => 'https://www.instagram.com/explore/tags/{tag}/?__a=1&max_id={max_id}';
use constant GENERAL_SEARCH                     => 'https://www.instagram.com/web/search/topsearch/?query={query}';
use constant ACCOUNT_JSON_INFO_BY_ID            => 'ig_user({userId}){id,username,external_url,full_name,profile_pic_url,biography,followed_by{count},follows{count},media{count},is_private,is_verified}';
use constant LAST_COMMENTS_BY_CODE              => 'ig_shortcode({{code}}){comments.last({{count}}){count,nodes{id,created_at,text,user{id,profile_pic_url,username,follows{count},followed_by{count},biography,full_name,media{count},is_private,external_url,is_verified}},page_info}}';
use constant COMMENTS_BEFORE_COMMENT_ID_BY_CODE => 'ig_shortcode({{code}}){comments.before({{commentId}},{{count}}){count,nodes{id,created_at,text,user{id,profile_pic_url,username,follows{count},followed_by{count},biography,full_name,media{count},is_private,external_url,is_verified}},page_info}}';
use constant LAST_LIKES_BY_CODE                 => 'ig_shortcode({{code}}){likes{nodes{id,user{id,profile_pic_url,username,follows{count},followed_by{count},biography,full_name,media{count},is_private,external_url,is_verified}},page_info}}';

use constant INSTAGRAM_QUERY_URL                => 'https://www.instagram.com/query/';
use constant INSTAGRAM_CDN_URL                  => 'https://scontent.cdninstagram.com/';

sub getAccountPageLink
{
    my ($username) = @_;

    return ACCOUNT_PAGE =~ s/\{username\}/uri_escape_utf8($username)/ser;
}

sub getAccountJsonLink
{
    my ($username) = @_;

    return ACCOUNT_JSON_INFO =~ s/\{username\}/uri_escape_utf8($username)/ser;
}

sub getAccountJsonInfoLinkByAccountId
{
    my ($id) = @_;

    return ACCOUNT_JSON_INFO_BY_ID =~ s/\{userId\}/uri_escape($id)/ser;
}

sub getAccountMediasJsonLink
{
    my ($username, $maxId) = @_;
    $maxId //= '';

    return (ACCOUNT_MEDIAS =~ s/\{username\}/uri_escape_utf8($username)/ser)
        =~ s/\{max_id\}/uri_escape_utf8($maxId)/ser;
}

sub getMediaPageLink
{
    my ($code) = @_;

    return MEDIA_LINK =~ s/\{code\}/uri_escape_utf8($code)/ser;
}

sub getMediaJsonLink
{
    my ($code) = @_;

    return MEDIA_JSON_INFO =~ s/\{code\}/uri_escape_utf8($code)/ser;
}

sub getMediasJsonByLocationIdLink
{
    my ($facebookLocationId, $maxId) = @_;
    $maxId //= '';

    return (MEDIA_JSON_BY_LOCATION_ID =~ s/\{\{facebookLocationId\}\}/uri_escape_utf8($facebookLocationId)/ser)
        =~ s/\{\{maxId\}\}/uri_escape_utf8($maxId)/ser;
}

sub getMediasJsonByTagLink
{
    my ($tag, $maxId) = @_;
    $maxId //= '';

    return (MEDIA_JSON_BY_TAG =~ s/\{tag\}/uri_escape_utf8($tag)/ser)
        =~ s/\{max_id\}/uri_escape_utf8($maxId)/ser;
}

sub getGeneralSearchJsonLink
{
    my ($query) = @_;

    return GENERAL_SEARCH =~ s/\{query\}/uri_escape_utf8($query)/ser;
}

sub getLastCommentsByCodeLink
{
    my ($code, $count) = @_;

    return (LAST_COMMENTS_BY_CODE =~ s/\{\{code\}\}/uri_escape_utf8($code)/ser)
        =~ s/\{\{count\}\}/uri_escape_utf8($count)/ser;
}

sub getCommentsBeforeCommentIdByCode
{
    my ($code, $count, $commentId) = @_;

    return ((COMMENTS_BEFORE_COMMENT_ID_BY_CODE =~ s/\{\{code\}\}/uri_escape_utf8($code)/ser)
        =~ s/\{\{count\}\}/uri_escape_utf8($count)/ser)
            =~ s/\{\{commentId\}\}/uri_escape_utf8($commentId)/ser;
}

sub getLastLikesByCodeLink
{
    my ($code) = @_;

    return LAST_LIKES_BY_CODE =~ s/\{\{code\}\}/uri_escape_utf8($code)/ser;
}

1;
__END__

=head1 NAME

Instagram::API::Endpoints - Perl extension for blah blah blah

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

=head3 getAccountJsonInfoLinkByAccountId

=head3 getAccountJsonLink

=head3 getAccountMediasJsonLink

=head3 getAccountPageLink

=head3 getCommentsBeforeCommentIdByCode

=head3 getGeneralSearchJsonLink

=head3 getLastCommentsByCodeLink

=head3 getLastLikesByCodeLink

=head3 getMediaJsonLink

=head3 getMediaPageLink

=head3 getMediasJsonByLocationIdLink

=head3 getMediasJsonByTagLink

=head1 CONSTANTS

=head3 INSTAGRAM_QUERY_URL

=head3 INSTAGRAM_CDN_URL

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
