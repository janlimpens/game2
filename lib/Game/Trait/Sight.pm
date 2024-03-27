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

    my $body_change = sub($other, $dimension, $dim_name)
    {
        return if $other->id() eq $entity->id();
        return unless $self->can_see($entity, $other);
        $sight{sees}{$other->id()}{change}{$dim_name} = $dimension;

        return sprintf '%s sees %s change %s to %s.',
            $entity->id(), $other->id(), $dim_name, $dimension;
    };

    $world->subscribe($_ => sub($other, $dim) { $body_change->($other, $dim, $_) })
        for qw(height weight diameter);
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

apply Game::Role::Trait;

ADJUST
{
    my %abilities = (
        look_around => \&look_around,
        look_at => \&look_at,
    );

    for my ($ability, $method) (%abilities)
    {
        $self->add_ability($ability, $method);
    };
}

method look_around($entity)
{
    my $name = $entity->do('get_name') // $entity->id();

    my $position = $entity->do('get_position');

    unless ($position)
    {
        say "$name has no position. Can't look around.";
        return
    }

    say "$name takes some time to look around.";

    my @candidates =
        grep { $_->id() ne $entity->id() && $_->do('is_visible')}
        $world->get_entities_by_type(qw(
            Game::Trait::Position
            Game::Trait::Visible));
    # p @candidates, as => 'candidates';

    my @in_range =
        sort { $a->[1] <=> $b->[1] }
        map {
            my $p = $_->do('get_position');
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
        my $name = $e->do('get_name');
        my $description = $e->do('get_description');
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
        my $own_position = $entity->do('get_position');

    return unless
        my $target_position = $target->do('get_position');

    my $distance = $target_position->distance_to($own_position);

    return $distance <= $max_distance
        ? $target
        : false
}

method look_at($entity, $target)
{
    my $position = $entity->do('get_position');
    my $name = $target->do('get_name') // $target->id();
    if ($self->can_see($entity, $target))
    {
        my $description = $target->do('get_description');
        my $t_pos = $target->do('get_position');
        my $dir = $self->approximate_direction($position, );
        my $d = $position->distance_to($t_pos);
        say "In the $dir, $d m away of $name, there is $name. $description";
    }
    else
    {
        say "$name can't quite see $target from here.";
    }
}

1;
