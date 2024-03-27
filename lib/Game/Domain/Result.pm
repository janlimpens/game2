use v5.38;
use local::lib;
use Object::Pad;

class Game::Domain::Result;

no warnings qw(experimental::builtin);
use builtin qw(true false blessed);
use Carp qw(longmess croak);

field $error :reader :param=undef;
field $some :param=undef;

ADJUST
{
    # croak does not seem to work here
    die 'Some or Error required, not both'
        if defined $error && defined $some;

    die 'Either some or error required required'
        if !defined $error && !defined $some;

    $self = $some
        if blessed $some
        && $some->isa('Game::Domain::Result')
        && $some ne $self;
}

method some()
{
    return wantarray()
        ? ref $some eq 'ARRAY' ? $some->@* : ($some)
        : $some
}

method with_error :common ($error)
{
    return $class->new(error => $error)
}

method with_some :common ($some)
{
    return $class->new(some => $some)
}

method unwrap()
{
    croak $error
        if $self->is_error();

    return $self->some()
}

method unwrap_or($default)
{
    return $self->is_error()
        ? $default
        : $self->some()
}

method is_some()
{
    return defined $some
}

method is_error()
{
    return defined $error
}

1;
