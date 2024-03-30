use v5.38;
use local::lib;
use Object::Pad;
use lib qw(lib);
class Game::Trait::Sight;

no warnings qw(experimental::builtin experimental::for_list);
use builtin qw(true false);
use feature qw(say);
use Data::Printer;
use Game::World;

field $max_distance :param=10;
field $decrement :param=1;
field $world = Game::World->get_instance();
field $initialized = false;
field %sight;

method description :common ($name='An entity with this trait')
{
    return "$name can see."
}

method stringify()
{
    return sprintf "Sight";
}

method init($entity)
{
    $world->subscribe(direction => sub($other_entity, $direction)
    {
        return if $other_entity->id() eq $entity->id();
        return unless $self->can_see($entity, $other_entity);

        $sight{sees}{$other_entity->id()}{move} = $direction;

        return $entity->id() . " sees " . $other_entity->id() . " moving $direction.";
    });

    $world->subscribe(position => sub($other_entity, $position)
    {
        return if $other_entity->id() eq $entity->id();
        return unless $self->can_see($entity, $other_entity);

        $sight{sees}{$other_entity->id()}{position} = $position;
        $position = $position->stringify() if ref $position;

        return $entity->id() . " sees " . $other_entity->id() . " arrive at position $position.";
    });

    for my $dim (qw(height weight depth))
    {
        $world->subscribe($dim => sub($other, $value)
        {
            return if $other->id() eq $entity->id();
            return unless $self->can_see($entity, $other);

            # my $value = $other->get($_)->unwrap_or('?');

            $sight{sees}{$other->id()}{change}{$dim} = $value;

            return sprintf "%s sees %s's body change %s to %s.",
                $entity->id(), $other->id(), $dim, $value;
        });
    }
}

method update($entity, $iteration)
{
    unless ($initialized)
    {
        $self->init($entity);
        $initialized = true;
    }

    my $sight = { %sight };
    %sight = ();

    return $sight
}

method properties()
{
    return qw(max_distance decrement)
}

method abilities()
{
    # probably not a good idea to expose can_see
    return qw(look_around look_at)
}

apply Game::Role::Trait;

method look_around($entity)
{
    my $name =
        $entity->get('name')->unwrap_or($entity->id());

    my $position = $entity->get('position');

    if ($position->is_err())
    {
        say "$name has no position. Can't look around.";
        return
    }

    $position = $position->unwrap();

    say "$name takes ok time to look around.";

    my @candidates =
        grep {
            $_->id() ne $entity->id()
            && $_->get('is_visible')->unwrap_or(false)
        }
        $world->get_entities_by_type(qw(
            Game::Trait::Position
            Game::Trait::Visible));
    # p @candidates, as => 'candidates';

    my @in_range =
        sort { $a->[1] <=> $b->[1] }
        map {
            my $p = $_->get('position')->unwrap();
            my $d = $p->distance_to($position);
            $d <= $max_distance
                ? ([$p, $d, $_])
                : ()
        }
        @candidates;

    unless (@in_range)
    {
        say "$name can't see anything special from here.";
        return
    }

    for (@in_range)
    {
        my ($p, $d, $e) = $_->@*;
        my $name = $e->get('name')->unwrap_or($e->id());
        my $description = $e->get('appearance')->unwrap_or('');
        my $dir = $position->approximate_direction_of($p);
        say "In the $dir, there is $name. $description";
    }

    return @in_range
}

method can_see($entity, $target)
{
    return unless $entity;
    return unless $target;

    return unless
        my $own_position = $entity->get('position')->unwrap_or(undef);

    return unless
        my $target_position = $target->get('position')->unwrap_or(undef);

    my $distance = $target_position->distance_to($own_position);

    return $distance <= $max_distance
        ? $target
        : false
}

method look_at($entity, $target)
{
    my $position = $entity->get('position')->unwrap();

    my $name = $target->get('name')->unwrap_or($target->id());

    if ($self->can_see($entity, $target))
    {
        my $description = $target->get('appearance')->unwrap_or('');
        my $t_pos = $target->get('position')->unwrap();
        my $dir = $self->approximate_direction($position, $t_pos);
        my $d = $position->distance_to($t_pos);
        say "In the $dir, $d m away of $name, there is $name. $description";
    }
    else
    {
        say "$name can't quite see $target from here.";
    }
}

1;
