use v5.38;
use local::lib;
use lib qw(lib);
use Object::Pad;

class Game::Domain::Direction;

use List::Util qw(first);

my %directions =
(
    n => Game::Domain::Direction->new(
        key => 'n',
        order => 0,
        offset => [0, 1],
        name => 'north' ),
    ne => Game::Domain::Direction->new(
        key => 'ne',
        order => 1,
        offset => [1, 1],
        name => 'north east' ),
    e => Game::Domain::Direction->new(
        key => 'e',
        order => 2,
        offset => [1, 0],
        name => 'east' ),
    se => Game::Domain::Direction->new(
        key => 'se',
        order => 3,
        offset => [1, -1],
        name => 'south east' ),
    s => Game::Domain::Direction->new(
        key => 's',
        order => 4,
        offset => [0, -1],
        name => 'south' ),
    sw => Game::Domain::Direction->new(
        key => 'sw',
        order => 5,
        offset => [-1, -1],
        name => 'south west' ),
    w => Game::Domain::Direction->new(
        key => 'w',
        order => 6,
        offset => [-1, 0],
        name => 'west' ),
    nw => Game::Domain::Direction->new(
        key => 'nw',
        order => 7,
        offset => [-1, 1],
        name => 'north west' ),
);

field $key :reader :param;
field $name :reader :param;
field $offset :reader :param;
field $order :reader :param;

method names :common ()
{
    return [
        map { $directions{$_}->name() }
        sort { $directions{$a}->order() <=> $directions{$b}->order() }
        keys %directions ]
}

method named :common ($name)
{
    return
        first { $_->name() eq $name }
        values %directions
}

method direction :common ($direction)
{
    return $directions{$direction}
}

method directions :common ()
{
    return [ sort { $directions{$a}->order() <=> $directions{$b}->order() } keys %directions ]
}

method stringify()
{
    return $name
}

method serialize()
{
    return $self->stringify()
}

method deserialize($string)
{
    return $self->named($string)
}


1;
