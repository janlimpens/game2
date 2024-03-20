use v5.38;
use local::lib;
use lib qw(lib);
use Object::Pad;

class Game::Trait::Mobile;

no warnings qw(experimental::builtin);
use builtin qw(true false);
use feature qw(say);
use Data::Printer;
use Game::Domain::Point;

field $last_direction;

ADJUST
{
    my %abilities = (
        move => \&move,
        walk => \&move,
        go => \&move,
        run => \&move,
        tiptoe => \&move,
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

method description($name='An entity with this trait')
{
    return "$name can move."
}

method stringify()
{
    return sprintf "Mobile";
}

method update($entity, $iteration)
{
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

    $self->is_dirty(true);

    # say "$called moved $direction.";

    return
}

apply Game::Trait;

1;
