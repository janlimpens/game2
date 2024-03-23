use v5.38;
use local::lib;
use Object::Pad;

class Game::Domain::Result;

no warnings qw(experimental::builtin);
use builtin qw(true false blessed);
use Carp;

field $error :reader :param=undef;
field $some :reader :param=undef;

ADJUST
{
    # croak does not seem to work here
    die 'Some or Error required, not both'
        if defined $error && defined $some;

    die 'Either some or error required required'
        if !defined $error && !defined $some;
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
    croak 'No value to unwrap'
        unless defined $some;

    return ref $some eq 'CODE'
        ? $some->()
        : $some
}

method was_successful()
{
    return defined $some
}

1;
