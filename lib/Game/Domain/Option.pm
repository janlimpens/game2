use v5.38;
use local::lib;
use Object::Pad;

class Game::Domain::Option;

no warnings qw(experimental::builtin);
use builtin qw(true false blessed);
use Carp qw(longmess croak confess);

field $some :reader :param=undef;

ADJUST
{
    confess "Some can't be a Game::Domain::Option"
        if blessed $some
        && $some->isa('Game::Domain::Option');
}

method with_none :common ()
{
    return $class->new()
}

method with_some :common ($some)
{
    return $class->new(some => $some)
}

method is_some()
{
    return defined $some
}

method is_none()
{
    return !defined $some
}

1;
