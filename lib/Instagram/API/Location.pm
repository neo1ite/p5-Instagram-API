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
