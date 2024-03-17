use v5.38;
use local::lib;
use Object::Pad;

class Game::World;

use builtin qw(blessed);
use Data::Printer;

field %entities;
field %types;

method add_entity ($entity) {
    $entities{$entity->id()} = $entity;
    $types{blessed $entity} = $entity;
}

method get_entity_by_id($id) {
    return $entities{$id};
}

method get_entities_by_type($type) {
    return $types{$type};
}

method loop(@commands)
{
    my %actor_to_command =
        map { $_->actor() => $_ }
        @commands;
    # p @commands, as => 'commands';
    for my $entity (values %entities)
    {
        p $entity, as => 'entity';
        my $id = $entity->id();

        my @commands_that_concern_me =
            $actor_to_command{$id};

        $entity->update(\@commands_that_concern_me);
    }

    return
}

1;
