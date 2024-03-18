use v5.38;
use local::lib;
use Object::Pad;

class Game::Property::Sight;
apply Game::Property;

no warnings qw(experimental::builtin);
use builtin qw(true false);
use feature qw(say);
use Data::Printer;
use Game::World;

field $distance :reader :param=10;
field $decrement :reader :param=1;

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

method approximate_direction($standpoint, $other)
{
    my %directions = (
        'north' => [0, 1],
        'north east' => [1, 1],
        'east' => [1, 0],
        'south east' => [1, -1],
        'south' => [0, -1],
        'south west' => [-1, -1],
        'west' => [-1, 0],
        'north west' => [-1, 1] );

    my @distances =
        sort { $a->[1] <=> $b->[1] }
        map {
            my $p = Game::Domain::Point->new(
                x => $standpoint->x() + $directions{$_}->[0],
                y => $standpoint->y() + $directions{$_}->[1]);
            my $d = $other->distance_to($p);
            [$_, $d]
        }
        keys %directions;

    return $distances[0][0]
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

    my $world = Game::World->get_instance();

    my @candidates =
        grep { $_->id() ne $entity->id() }
        $world->get_entities_by_type(qw(
            Game::Property::Position
            Game::Property::Visible));
    # p @candidates, as => 'candidates';

    my @in_range =
        sort { $a->[1] <=> $b->[1] }
        map {
            my $p = $_->do('get_position');
            my $d = $p->distance_to($position);
            $d <= $distance
                ? ([$p, $d, $_])
                : ()
        }
        @candidates;

    unless (@in_range)
    {
        say "$name can't see anything from here.";
        return
    }

    for (@in_range)
    {
        my ($p, $d, $e) = $_->@*;
        my $name = $e->do('get_name');
        my $description = $e->do('get_description');
        my $dir = $self->approximate_direction($position, $p);
        say "In the $dir, there is $name. $description";
    }

    return @in_range
}

method look_at($entity, $target)
{
    my $position = $entity->do('get_position');
    return unless $position;

    my $name = $entity->do('get_name') // $entity->id();

    my $p = $target->do('get_position');
    my $d = $p->distance($position);

    if ($d <= $distance)
    {
        my $description = $target->do('get_description');
        my $dir = $self->approximate_direction($position, $p);
        say "In the $dir, $d m away of $name, there is $name. $description";
    }
    else
    {
        say "$name can't quite see $target from here.";
    }
}

method stringify()
{
    return sprintf "Sight";
}

1;
