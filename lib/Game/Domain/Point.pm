use v5.38;

use local::lib;

use Object::Pad;

class Game::Domain::Point;

no warnings qw(experimental::builtin);
use builtin qw(true false);
use feature qw(say);
use Data::Printer;

# field $x :param//=0 :reader;
# field $y :param//=0 :reader;
# field $z :param//=0 :reader;

field $x :reader :param//=0;
field $y :reader :param//=0;
field $z :reader :param//=0;

ADJUST
{
    $x = 0 if $x < 0;
    $y = 0 if $y < 0;
}

method stringify()
{
    return sprintf "(%d/%d/%d)", $x, $y, $z;
}

method new_from_values :common (@values)
{
    my ($x, $y, $z) = @values;
    return Game::Domain::Point->new(x => $x, y => $y, z => $z);
}

method origin :common ()
{
    return Game::Domain::Point->new();
}

method to_array()
{
    return ($x, $y, $z);
}

method equals_to($other)
{
    return false unless $other;
    return $x == $other->x() && $y == $other->y() && $z == $other->z();
}

method distance_to($other)
{
    return 0 unless $other;
    return
        sqrt(
            ($x - $other->x())**2
            + ($y - $other->y())**2
            + ($z - $other->z())**2);
}
1;
