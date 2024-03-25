use v5.38;
use local::lib;
use lib qw(lib);
use Object::Pad;

class Game::World :isa( Game::Entity );
no warnings qw(experimental::builtin);

use builtin qw(blessed true false);
use Data::Printer;
use List::Util qw(all first);
use Term::ANSIColor;

field %entities;
field $width :reader :param=100;
field $height :reader :param=100;
field $quit=false;

method should_quit() {
    return $quit
}

method quit()
{
    $quit = true;
}

method get_instance :common (%params)
{
    state $instance = Game::World->new(%params);
    return $instance
}

method add_entity ($entity) {
    $entities{$entity->id()} = $entity;
}

method get_entity_by_id($id) {
    return $entities{$id};
}

method get_entities_by_type(@type)
{
    return
        grep {
            my %pt = map { $_ => 1 } $_->trait_types();
            all { exists $pt{$_} } @type
        }
        values %entities;
}

method get_entity_at($point)
{
    return
        first {
            my $pos = $_->do('get_position');
            $pos ? $pos->equals_to($point) : false
        }
        values %entities
}

method get_entities_in_range($point, $distance)
{
    return
        grep {
            my $pos = $_->do('get_position');
            $pos->distance_to($point) <= $distance
        }
        values %entities
}

method update($i)
{
    say "Iteration $i";

    print color( join '', 'rgb', ( map { int(2 + rand(3)) } (0..2) ) );

    for my $entity (values %entities)
    {
        $entity->update($i);
    }

    print color('reset');
    say '-' x 80;
    return
}

1;
