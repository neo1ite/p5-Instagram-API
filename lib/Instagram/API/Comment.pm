package Instagram::API::Comment;

use utf8;
use strict;
use warnings;
use autouse 'Data::Dumper';

use Scalar::Util qw/blessed/;
use Instagram::API::Account;

sub new {
    my ($invocant, $params) = @_;

    my $class = ref($invocant) || $invocant;
    my $self = {
        text      => undef,
        createdAt => undef,
        id        => undef,
        user      => undef,
    };

    bless($self, $class);

    return $self;
}

sub fromApi
{
    my ($self, $commentArray) = @_;

    $self = __PACKAGE__->new() unless ($self && blessed($self) && $self->isa(__PACKAGE__));

    $self->{text}      = $commentArray->{'text'};
    $self->{createdAt} = $commentArray->{'created_at'};
    $self->{id}        = $commentArray->{'id'};
    $self->{user}      = Instagram::API::Account->fromAccountPage($commentArray->{'user'});

    return $self;
}

1;
__END__

=head1 NAME

Instagram::API::Comment - Perl extension for blah blah blah

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

=head3 fromApi

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
