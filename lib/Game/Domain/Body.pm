use v5.38;
use local::lib;
use Object::Pad;

class Game::Domain::Body;

no warnings qw(experimental::builtin);
use builtin qw(true false blessed);
use Carp;

field $height :reader :param=1;

field $width :reader :param=1;

# negative value indicates opening
field $depth :reader :param=1;

method volume()
{
    return $height * $width * $depth
}

method fits_inside($other)
{
    croak "Wanted a Game::Domain::Body', but got a ". ref $other
        unless blessed $other && $other->isa('Game::Domain::Body');
    return false unless $other;
    return $height >= $other->height()
        && $width >= $other->width()
        && $depth >= $other->depth();
}

method fits_through($other)
{
    # $other is negative space
    return
        $other->height() < 0
        && $other->width() < 0
        && $other->depth() < 0
        && $self->is_smaller_than(
            Game::Domain::Body->new(
                height => $other->height() * -1,
                width => $other->width() * -1,
                depth => $other->depth() * -1) );
}

method equal_to($other)
{
    return $height == $other->height()
        && $width == $other->width()
        && $depth == $other->depth();
}

method intersects($other)
{
    return $height >= $other->height()
        || $width >= $other->width()
        || $depth >= $other->depth();
}

method is_smaller_than($other)
{
    return $height < $other->height()
        && $width < $other->width()
        && $depth < $other->depth();
}

method is_larger_than($other)
{
    return !$self->equal_to($other)
    && !$self->is_smaller_than($other)
}

method stringify()
{
    return sprintf "h: %d;w: %d; d: %d",
        $height, $width, $depth;
}

method serialize()
{
    return $self->stringify()
}

method deserialize($data)
{
    my ($height, $width, $depth) = $data =~ m/\((-?\d+)\/(-?\d+)\/(-?\d+)\)/;
    return Game::Domain::Body->new(
        height => $height,
        width => $width,
        depth => $depth);
}

apply Game::Role::Serializes;

1;
