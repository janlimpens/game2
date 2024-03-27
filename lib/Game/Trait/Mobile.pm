use v5.38;
use local::lib;
use lib qw(lib);
use Object::Pad;

class Game::Trait::Mobile;

no warnings qw(experimental::builtin);
use builtin qw(true false);
use feature qw(say);
use Carp;
use Data::Printer;
use Game::Domain::Point;

field $last_direction;

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

method description :common ($name='An entity with this trait')
{
    return "$name can move."
}

method stringify()
{
    return sprintf "Mobile";
}

method update($entity, $iteration)
{
    my %changes;

    $changes{direction} = $last_direction
        if $self->is_dirty();

    return \%changes
}

method move($entity, @params)
{
    my $direction = $params[1]
        ? join('_', $params[0..1])
        : $params[0];

    unless ($direction)
    {
        croak "No direction given";
    }

    $direction = $shortcuts{$direction}
        unless $movements{$direction};

    unless ($direction)
    {
        croak "Invalid direction given.";
    }

    $last_direction = $direction;

    my $target_coords = $movements{$direction};

    my $called = $entity->get('name') // $entity->id();

    unless ($entity->can_do('set_position'))
    {
        croak "$called can't move.";
    }

    my $position = $entity->get('position');

    # p $position;

    if ($position->is_error())
    {
        croak "$called doesn't have a position.";
    }

    $position = $position->unwrap();
    # say "$called tries to move $direction.";

    # p $position;

    my $target = Game::Domain::Point->new_from_values(
        $position->x() + $target_coords->[0],
        $position->y() + $target_coords->[1],
    );

    $entity->do('set_position', $target);

    say $entity->get('position')->stringify();

    $self->is_dirty(true);

    # say "$called moved $direction.";

    return true
}

method _move_towards_point($entity, $target_position)
{
    my $position = $entity->get('position');

    return unless $position;

    return true
        if $position->equals_to($target_position);

    my $direction = $position->approximate_direction_of($target_position);

    return $self->move($entity, $direction);
}

method _move_towards_entity($entity, $target)
{
    my $position = $entity->get('position');
    my $other_pos = $target->get('position');

    return unless $position || $other_pos;

    my $distance = $position->distance($other_pos);

    $self->_move_towards_point($other_pos)
        if $distance > 1;

    my $new_distance =
        $entity
        ->get('position')
        ->distance($target->get('position'));

    return $new_distance < $distance
}

method go_to($entity, $target)
{
    return $self->_move_towards_point($entity, $target)
        if $target->isa('Game::Domain::Point');

    return $self->_move_towards_entity($entity, $target)
        if $target->isa('Game::Entity');

    return false
}

method properties()
{
    return ()
}

method abilities()
{
    return qw(move go_to)
}

apply Game::Role::Trait;

1;
