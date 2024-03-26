use v5.38;
use local::lib;
use Object::Pad;

class Game::Trait::Body;

no warnings qw(experimental::builtin);
use lib qw(lib);
use builtin qw(true false);
use feature qw(say);
use Carp;
use Data::Printer;
use Game::Domain::Body;

field $body;

method height() { return $body->height() }

method width() { return $body->width() }

method diameter() { return $body->diameter() }

ADJUST :params ( :$height, :$width, :$diameter )
{
    $body = Game::Domain::Body->new(
        height => $height,
        width => $width,
        diameter => $diameter);

    my %abilities = (
        fits_inside => method ($entity, $other)
        {
            my $other_body = $other->do('get_body');
            return $body->fits_inside($other_body)
        },
        fits_through => method ($entity, $other) {
            return $body->fits_through($other)
        },
        get_body => method ($entity) { return $body },
        get_diameter => sub { return $body->diameter() },
        get_height => sub { return $body->height() },
        get_width => sub { return $body->width() },
        get_volume => sub { return $body->volume() },
    );

    for my $ability (keys %abilities)
    {
        $self->add_ability($ability, $abilities{$ability});
    }
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
    return
}

apply Game::Role::Trait;

1;
