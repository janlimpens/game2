use v5.38;

use local::lib;
use lib 'lib';
use Object::Pad;

class Game::Domain::Point;

no warnings qw(experimental::builtin);
use builtin qw(true false);
use feature qw(say);
use Carp;
use Data::Printer;
use Game::Domain::Direction;
use List::Util qw(any);

field $x :reader :param//=0;
field $y :reader :param//=0;
field $z :reader :param//=0;

ADJUST
{
    $x = $x + 0 if any { defined $_ } ( $x, $y, $z );
    $y = $y + 0 if any { defined $_ } ( $x, $y, $z );
    $z = $z + 0 if any { defined $_ } ( $x, $y, $z );
}

method stringify()
{
    return sprintf "(%s/%s/%s)", defined $x ? ($x, $y, $z) : ('?', '?', '?');
}

method new_from_values :common (@values)
{
    my ($x, $y, $z) = @values;
    return Game::Domain::Point->new(x => $x, y => $y, z => $z);
}

method origin :common ()
{
    return Game::Domain::Point->new_from_values(0,0,0);
}

method unknown :common ()
{
    return Game::Domain::Point->new();
}

method to_array()
{
    return ($x, $y, $z);
}

method equal_to($other)
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

method approximate_direction_of($other)
{
    return if $self->equal_to($other);

    my @distances =
        sort { $a->[1] <=> $b->[1] }
        map {
            my $d = Game::Domain::Direction->direction($_);
            my $offset = $d->offset();
            my $p = Game::Domain::Point->new(
                x => $x + $offset->[0],
                y => $y + $offset->[1]);
            my $dist = $other->distance_to($p);
            [$_, $dist]
        }
        Game::Domain::Direction->directions()->@*;

    return $distances[0][0]
}

method serialize() {
    return $self->stringify()
}

method deserialize($data) {
    my ($x, $y, $z) = $data =~ m/\((-?\d+)\/(-?\d+)\/(-?\d+)\)/;
    return Game::Domain::Point->new(x => $x, y => $y, z => $z);
}

apply Game::Role::Serializes;

1;
