package Instagram::API::Tag;

use utf8;
use strict;
use warnings;
use autouse 'Data::Dumper';

use Scalar::Util qw/blessed/;

sub new {
    my ($invocant, $params) = @_;

    my $class = ref($invocant) || $invocant;
    my $self = {
        mediaCount => undef,
        name       => undef,
        id         => undef,
    };

    bless($self, $class);

    return $self;
}

sub fromSearchPage
{
    my ($self, $tagArray) = @_;

    $self = __PACKAGE__->new() unless ($self && blessed($self) && $self->isa(__PACKAGE__));

    $self->{mediaCount} = $tagArray->{'media_count'};
    $self->{name}       = $tagArray->{'name'};
    $self->{id}         = $tagArray->{'id'};

    return $self;
}

1;
