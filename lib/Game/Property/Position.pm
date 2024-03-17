use v5.38;
use local::lib;
use Object::Pad;

class Game::Property::Position;
apply Game::Property;

no warnings qw(experimental::builtin);
use builtin qw(true false);
use feature qw(say);
use Carp;
use Data::Printer;
use Game::Domain::Point;

field $position :accessor :param=Game::Domain::Point->origin();

ADJUST
{
    my %abilities = (
        set_position => \&set_position,
        get_position => \&get_position,
    );

    for my $ability (keys %abilities)
    {
        $self->add_ability($ability, $abilities{$ability});
    }

    if (ref $position eq 'HASH')
    {
        $position = Game::Domain::Point->new($position->%*);
    } elsif (ref $position eq 'ARRAY')
    {
        $position = Game::Domain::Point->new_from_values($position->@*);
    }
    croak "Didn't get the point"
        unless $position->isa('Game::Domain::Point');
}

method set_position($entity, $point)
{
    $point->z($position->z())
        unless defined $point->z();

    my $world = Game::World->get_instance();

    my $is_occupied = $world->get_entity_at($point);

    if($is_occupied)
    {
        my $occupant = $is_occupied->do('get_name') // $is_occupied->id();
        say "Position " . $point->stringify() . "is already occupied by $occupant.";
        return
    }

    $point->x($world->width())
        if $point->x() > $world->width();
    # or remove from world?

    $point->y($world->height())
        if $point->y() > $world->height();

    if ($point->x() != $position->x() || $point->y() != $position->y())
    {
        $position = $point;
        $self->is_dirty(true);
    }
}

method get_position($entity)
{
    my $name = $entity->do('get_name') // $entity->id();
    say "$name is at " . $position->stringify();
    return $position
}

method stringify()
{
    return sprintf 'Position (%s)', $position->stringify()
}
