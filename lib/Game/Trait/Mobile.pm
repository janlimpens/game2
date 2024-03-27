use v5.38;
use local::lib;
use lib qw(lib);
use Object::Pad;

class Game::Trait::Mobile;

no warnings qw(
    experimental::builtin
    experimental::for_list);
use builtin qw(true false);
use feature qw(say);
use Data::Printer;
use Game::Domain::Point;

field $last_direction;
field %changes;

ADJUST
{
    my %abilities = (
        move => method ($entity, @params) {
            my ($dir) = @params;
            return $self->move($entity, $dir)
        },
        go_to => method ($entity, @params) {
            my ($target) = @params;
            return $self->go_to($entity, $target)
        },
    );

    for my ($ability, $code) (%abilities)
    {
        $self->add_ability($ability, $code);
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
        say "No direction given";
        return
    }

    $direction = $shortcuts{$direction}
        unless $movements{$direction};

    unless ($direction)
    {
        say "Invalid direction given.";
        return
    }

    $last_direction = $direction;

    my $target_coords = $movements{$direction};

    my $called = $entity->do('get_name') // $entity->id();

    my $can_move = $entity->has_ability('set_position');

    unless ($can_move)
    {
        say "$called can't move.";
        return
    }

    my $position = $entity->do('get_position');

    unless ($position)
    {
        say "$called doesn't have a position.";
        return
    }

    # say "$called tries to move $direction.";

    my $target = Game::Domain::Point->new_from_values(
        $position->x() + $target_coords->[0],
        $position->y() + $target_coords->[1],
    );

    $entity->do('set_position', $target);

    say $entity->do('get_position')->stringify();

    $self->is_dirty(true);

    $changes{move} = $direction;
    # say "$called moved $direction.";
    return true
}

method _move_towards_point($entity, $target_position)
{
    my $position = $entity->do('get_position');

    return unless $position;

    return true
        if $position->equals_to($target_position);

    my $direction = $position->approximate_direction_of($target_position);

    return $self->move($entity, $direction);
}

method _move_towards_entity($entity, $target)
{
    my $position = $entity->do('get_position');
    my $other_pos = $target->do('get_position');

    return unless $position || $other_pos;

    my $distance = $position->distance($other_pos);

    $self->_move_towards_point($other_pos)
        if $distance > 1;

    my $new_distance =
        $entity
        ->do('get_position')
        ->distance($target->do('get_position'));

    return $new_distance < $distance
}

method go_to($entity, $target)
{
    return $self->_move_towards_point($entity, $target)
        if $target->isa('Game::Domain::Position');

    return $self->_move_towards_entity($entity, $target)
        if $target->isa('Game::Entity');

    return false
}

apply Game::Role::Trait;

1;
