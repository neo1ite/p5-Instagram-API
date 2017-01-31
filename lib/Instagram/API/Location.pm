package Instagram::API::Location;

use utf8;
use strict;
use warnings;
use autouse 'Data::Dumper';

use Scalar::Util qw/blessed/;

sub new {
    my ($invocant, $params) = @_;

    my $class = ref($invocant) || $invocant;
    my $self = {
        id   => undef,
        name => undef,
        lat  => undef,
        lng  => undef,
    };

    bless($self, $class);

    return $self;
}

sub makeLocation
{
    my ($self, $locationArray) = @_;

    $self = __PACKAGE__->new() unless ($self && blessed($self) && $self->isa(__PACKAGE__));

    $self->{id}   = $locationArray->{'id'};
    $self->{name} = $locationArray->{'name'};
    $self->{lat}  = $locationArray->{'lat'};
    $self->{lng}  = $locationArray->{'lng'};

    return $self;
}

1;
__END__

=head1 NAME

Instagram::API::Location - Perl extension for blah blah blah

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

=head3 makeLocation

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
