package Instagram::API::Comment;

use utf8;
use strict;
use warnings;
use autouse 'Data::Dumper';

use Scalar::Util qw/blessed/;

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
    $self->{user}      = Account::fromAccountPage($commentArray->{'user'});

    return $self;
}

1;
