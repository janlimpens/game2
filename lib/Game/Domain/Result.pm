use v5.38;
use local::lib;
use Object::Pad;

class Game::Domain::Result;

no warnings qw(experimental::builtin);
use builtin qw(true false blessed);
use Carp qw(longmess croak confess);

field $error :reader :param=undef;
field $some :param=undef;

ADJUST
{
    # undef can be a valid result value,
    # so we need an option type, too.
    # result->ok and err (with_ok, with_err)
    # option->some and none (with_some, with_none)
    confess 'Some or Error required, not both'
        if defined $error && defined $some;

    confess 'Either some or error required required'
        if !defined $error && !defined $some;

    confess 'some cannot be another Result'
        if blessed $some
        && $some->isa('Game::Domain::Result');
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
