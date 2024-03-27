use v5.38;
use local::lib;
use Object::Pad;

class Game::Trait::Position;
no warnings qw(experimental::builtin);
use lib qw(lib);
use builtin qw(true false);
use feature qw(say);
use Carp;
use Data::Printer;
use Game::Domain::Point;
use Game::World;

field $last_position;
field $position :param=Game::Domain::Point->origin();
field $world = Game::World->get_instance();

method description :common ($name='An entity with this trait')
{
    return "$name has a position. It can be directly changed. It is not intended to be used directly, in regular situations."
}

method stringify()
{
    return sprintf 'Position (%s)', $position->stringify()
}

method update($entity, $iteration)
{
    my %changes;

    unless ($position->equals_to($last_position))
    {
        $changes{position} = $position;
        $last_position = $position;
    }

    return \%changes
}


method properties()
{
    return qw(position vicinity)
}

method abilities()
{
    return qw(set_position)
}

apply Game::Role::Trait;

ADJUST
{
    if (ref $position eq 'HASH')
    {
        $position = Game::Domain::Point->new($position->%*);
    } elsif (ref $position eq 'ARRAY')
    {
        $position = Game::Domain::Point->new_from_values($position->@*);
    }

    croak "Didn't get the point"
        unless $position->isa('Game::Domain::Point');

    $last_position = $position;
}

method set_position($entity, $point)
{
    croak "Didn't get the point"
        unless defined $point || $point->isa('Game::Domain::Point');

    my $z = defined $point->z()
        ? $point->z()
        : $position->z();

    my $x = $point->x() > $world->width()
        ? $world->width()
        : $point->x();

    my $y = $point->y() > $world->height()
        ? $world->height()
        : $point->y();

    my $target = Game::Domain::Point->new_from_values($x, $y, $z);

    if (my $occupant = $world->get_entity_at($target))
    {
        my $occupant_name = $occupant->get('name') // $occupant->id();

        if ($occupant->id() eq $entity->id()) {
            say "$occupant_name is already at position " . $target->stringify() . ".";
        } else {
            say "Position " . $target->stringify() . "is already occupied by $occupant_name.";
        }

        return
    }
    # p $target, as => 'target';
    # p $position, as => 'position';
    return if $position->equals_to($target);
    $position = $target;
    $self->is_dirty(true);

    return true
}

method position()
{
    return $position
}

method get_vicinity($entity)
{
    if (my $position = $entity->get('position'))
    {
        my %offsets = (
            s  => [0,-1],
            se => [1,-1],
            e  => [1,0],
            ne => [1,1],
            n  => [0,1],
            nw => [-1,1],
            w  => [-1,0],
            sw => [-1,-1] );

        return {
            map {
                my $point = Game::Domain::Point->new(
                    x => $position->x() + $offsets{$_}->[0],
                    y => $position->y() + $offsets{$_}->[1]);
                $_ => Game::World->get_instance()->get_entity_at($point)
            }
            keys %offsets }
    }
}

1;
