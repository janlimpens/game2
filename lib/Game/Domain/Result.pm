use v5.38;
use local::lib;
use Object::Pad;

class Game::Domain::Result;

no warnings qw(experimental::builtin);
use builtin qw(true false blessed);
use Carp;
use Syntax::Operator::Equ;

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

method was_success()
{
    return defined $some;
}

1;
