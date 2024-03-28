use v5.38;
use local::lib;
use Object::Pad;
use lib qw(lib);
class Game::Trait::NPC;

no warnings qw(experimental::builtin);
use builtin qw(true false);
use feature qw(say);
use Data::Printer;
use Game::Domain::Point;

field $last_direction;
field %changes;

method description :common ($name='An entity with this trait')
{
    return "$name autonomously does random stuff."
}

method stringify()
{
    return sprintf "NPC";
}

method update($entity, $iteration)
{
    my %actions = (
        walk_aimlessly => 1,
        stand_around => 1,
        repeat_last_movement => 1,
    );

    #random
    my ($action) = keys %actions;

    $self->$action($entity);

    return \%changes
}

method move($entity, $direction)
{
    return $entity->do('move', $direction);
}

method get_vicinity($entity)
{
    return $entity->get('vicinity')
}

method get_name($entity)
{
    return $entity->get('name')
}

method stand_around($entity)
{
    my $name = $self->get_name($entity) // $entity->id();
    my $pos = $self->get_position($entity)->stringify();
    say "$name just slacks off at position $pos.";

    $changes{does}{okthing} = false;

    return
}

method get_position($entity)
{
    return $entity->get('position')
}

method repeat_last_movement($entity)
{
    return unless (my $vicinity = $self->get_vicinity($entity));

    return $self->walk_aimlessly($entity)
        unless $last_direction;

    my $name = $self->get_name($entity) // $entity->id();

    my %open_directions = $vicinity
        ? map { $_ => 1 } grep { !$vicinity->{$_} } keys $vicinity->%*
        : ();

    my $can_go_there = $open_directions{$last_direction};

    say "$name continues to walk $last_direction."
        if $can_go_there;

    return $can_go_there
        ? $self->move($entity, $last_direction)
        : $self->walk_aimlessly($entity)
}

method walk_aimlessly($entity)
{
    return unless (my $vicinity = $self->get_vicinity($entity));

    my $name = $self->get_name($entity) // $entity->id();

    my %open_directions = $vicinity
        ? map { $_ => 1 } grep { !$vicinity->{$_} } keys $vicinity->%*
        : ();

    my ($direction) = keys %open_directions;

    return $self->stand_around($entity)
        unless $direction;

    $last_direction = $direction;

    $self->move($entity, $direction);

    my $pos = $self->get_position($entity);

    $changes{wanders}{$direction} = $pos->stringify();

    return
}

method properties()
{
    return ()
}

apply Game::Role::Trait;

1;
