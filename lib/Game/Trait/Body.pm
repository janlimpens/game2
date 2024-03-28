use v5.38;
use local::lib;
use Object::Pad ':experimental(inherit_field)';

class Game::Trait::Body;

no warnings qw(experimental::builtin);
use lib qw(lib);
use builtin qw(true false);
use feature qw(say);
use Carp;
use Data::Printer;
use Game::Domain::Body;

field $body;
field %changes;
field %abilities;

method height($h=undef)
{
    $body = Game::Domain::Body->new(
        height => $h,
        width => $body->width(),
        depth => $body->depth())
        if defined $h;

    $changes{height} = $h;
    $changes{body} = $body;

    return $body->height()
}

method width($w=undef)
{
    $body = Game::Domain::Body->new(
        height => $body->height(),
        width => $w,
        depth => $body->depth())
        if defined $w;

    $changes{width} = $w;
    $changes{body} = $body;

    return $body->width()
}

method depth($d=undef)
{
    $body = Game::Domain::Body->new(
        height => $body->height(),
        width => $body->width(),
        depth => $d)
        if defined $d;

    $changes{depth} = $d;
    $changes{body} = $body;

    return $body->depth()
}

method volume()
{
    return $body->volume()
}

method description :common ($name='An entity with this trait')
{
    return "$name has a body."
}

method stringify()
{
    return sprintf 'Body (%s)', $body->stringify()
}

method update($entity, $iteration)
{
    my $result = { %changes };
    %changes = ();
    return $result
}

method equal_to($other)
{
    return $body->equal_to($other)
}

method intersects($other)
{
    return $body->intersects($other)
}

method properties()
{
    return qw(body height width depth volume)
}

method abilities()
{
    return qw(fits_inside fits_through)
}

apply Game::Role::Trait;

method fits_inside($entity, $other)
{
    my $other_body = $other->get('body')->unwrap();

    return $other_body->is_smaller_than($body)
}

method fits_through($entity, $other)
{
    return $body->fits_inside($other)
}

method body()
{
    return Game::Domain::Body->new(
        height => $body->height(),
        width => $body->width(),
        depth => $body->depth())
}

ADJUST :params ( :$height, :$width, :$depth )
{
    $body = Game::Domain::Body->new(
        height => $height,
        width => $width,
        depth => $depth);
};

1;
