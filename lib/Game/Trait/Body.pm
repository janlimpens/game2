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

field $body :reader;
field %changes;

method height($h=undef)
{
    $body = Game::Domain::Body->new(
        height => $h,
        width => $body->width(),
        diameter => $body->diameter())
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
        diameter => $body->diameter())
        if defined $w;

    $changes{width} = $w;
    $changes{body} = $body;

    return $body->width()
}

method diameter($d=undef)
{
    $body = Game::Domain::Body->new(
        height => $body->height(),
        width => $body->width(),
        diameter => $d)
        if defined $d;

    $changes{diameter} = $d;
    $changes{body} = $body;

    return $body->diameter()
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

method properties()
{
    return qw(body height width diameter)
}

apply Game::Role::Trait;

ADJUST :params ( :$height, :$width, :$diameter )
{
    $body = Game::Domain::Body->new(
        height => $height,
        width => $width,
        diameter => $diameter);

    my %abilities = (
        diameter => \&diameter,
        fits_inside => method ($entity, $other)
        {
            my $other_body = $other->do('get_body');
            return $body->fits_inside($other_body)
        },
        fits_through => method ($entity, $other) {
            return $body->fits_through($other)
        },
        get_body => method ($entity) { return $body },
        height => \&height,
        width => \&width,
        volume => \&volume,
    );

    for my $ability (keys %abilities)
    {
        $self->add_ability($ability, $abilities{$ability});
    }

};

1;
