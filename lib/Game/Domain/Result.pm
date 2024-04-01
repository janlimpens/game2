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
field $is_ok :param=false;

ADJUST
{
    while (blessed $ok && $ok->isa('Game::Domain::Result'))
    {
        $ok = $ok->ok();
        $err = $ok->err()
    }

    while (blessed $err && $err->isa('Game::Domain::Result'))
    {
        $ok = $err->ok();
        $err = $err->err();
    }
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
    return $class->new(ok => $ok, is_ok => true)
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
    return $is_ok
}

method is_err()
{
    return !$is_ok
}

1;
