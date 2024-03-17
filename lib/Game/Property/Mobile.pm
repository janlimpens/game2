use v5.38;
use local::lib;
use Object::Pad;

class Game::Property::Mobile;
apply Game::Property;

no warnings qw(experimental::builtin);
use builtin qw(true false);
use feature qw(say);
use Carp;
use Data::Printer;
use Game::Domain::Point;

ADJUST
{
    my %abilities = (
        move =>
            method($entity, @params)
            {
                my $p = $params[1]
                    ? join('_', $params[0..1])
                    : $params[0];
                $self->move($entity, $p)
            }
    );
    for my $ability (keys %abilities)
    {
        $self->add_ability($ability, $abilities{$ability});
    }
};

field %movements = (
    north => [0, 1],
    north_east => [1, 1],
    east => [1, 0],
    south_east => [1, -1],
    south => [0, -1],
    south_west => [-1, -1],
    west => [-1, 0],
    north_west => [-1, 1],
);

field %shortcuts = (
    n => 'north',
    ne => 'north_east',
    e => 'east',
    se => 'south_east',
    s => 'south',
    sw => 'south_west',
    w => 'west',
    nw => 'north_west',
);

method move($entity, $direction)
{
    croak "No direction given"
        unless $direction;

    $direction = $shortcuts{$direction}
        unless $movements{$direction};

    croak("Invalid direction $direction")
        unless $direction;

    my $target_coords = $movements{$direction};

    my $called = $entity->do('get_name') // $entity->id();

    my $can_move = $entity->has_ability('set_position');

    unless ($can_move)
    {
        say "$called can't move.";
        return
    }

    say "$called tries to move $direction.";

    my $position = $entity->do('get_position');

    unless ($position)
    {
        say "$called doesn't have a position.";
        return
    }

    my $target = Game::Domain::Point->new_from_values(
        $position->x() + $target_coords->[0],
        $position->y() + $target_coords->[1],
    );

    my $world = Game::World->get_instance();

    my $is_occupied = $world->get_entity_at($target);
    my $t = $target->stringify();

    if($is_occupied)
    {
        my $occupant =
            $is_occupied->do('get_name') // $is_occupied->id();
        say "Position $t is already occupied by $occupant. $called can't move there.";
        return
    }

    $entity->do('set_position', $target);
    say "$called moved $direction. ${called}'s position is now $t.";
    return
}

method stringify()
{
    return sprintf "Mobile";
}

1;
