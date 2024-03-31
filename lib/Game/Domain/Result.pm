use v5.38;
use local::lib;
use Object::Pad;

class Game::Domain::Result;

no warnings qw(experimental::builtin);
use builtin qw(true false blessed);
use lib qw(lib);
use Carp qw(longmess croak confess);

field $err :reader :param=undef;
field $ok :param=undef;

ADJUST
{
    # undef can be a valid result value,
    # so we need an option type, too.
    # result->ok and err (with_ok, with_err)
    # option->ok and none (with_ok, with_none)
    confess 'Some or Error required, not both'
        if defined $err && defined $ok;

    confess 'Either ok or err required'
        if !defined $err && !defined $ok;

    confess 'ok cannot be another Result'
        if blessed $ok
        && $ok->isa('Game::Domain::Result');
}

method ok()
{
    return wantarray()
        ? ref $ok eq 'ARRAY' ? $ok->@* : ($ok)
        : $ok
}

method with_err :common ($err, @params)
{
    return $class->new(err => sprintf($err, @params))
}

method with_ok :common ($ok)
{
    return $class->new(ok => $ok)
}

method unwrap()
{
    croak $err
        if $self->is_err();

    return $self->ok()
}

method unwrap_or($default)
{
    return $self->is_err()
        ? $default
        : $self->ok()
}

method is_ok()
{
    return defined $ok
}

method is_err()
{
    return defined $err
}

1;
