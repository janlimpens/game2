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

method description($name='An entity with this trait')
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
        walk_aimlessly => \&walk_aimlessly,
        stand_around => \&stand_around,
        repeat_last_movement => \&repeat_last_movement,
    );

    my $action = [keys %actions]->[int(rand(scalar %actions))];

    return $actions{$action}->($self, $entity);
}

method move($entity, $direction)
{
    return $entity->do('move', $direction);
}

method get_vicinity($entity)
{
    return $entity->do('get_vicinity')
}

method get_name($entity)
{
    return $entity->do('get_name')
}

method stand_around($entity)
{
    my $name = $self->get_name($entity) // $entity->id();
    my $pos = $self->get_position($entity)->stringify();
    say "$name just slacks off at position $pos.";

    return
}

method get_position($entity)
{
    return $entity->do('get_position')
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

    my $direction = [keys %open_directions]->[int(rand(8))];

    return $self->stand_around($entity)
        unless $direction;

    $last_direction = $direction;

    $self->move($entity, $direction);

    my $pos = $self->get_position($entity);

    say sprintf '%s walks aimlessly %s and arrives at %s.',
        $name, $direction, $pos->stringify();

    return
}

apply Game::Trait;

1;
