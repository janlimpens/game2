use v5.38;
use local::lib;
use Object::Pad;

class Game::World;
no warnings qw(experimental::builtin);

use builtin qw(blessed);
use Data::Printer;
use List::Util qw(first);

field %entities;
field %types;
field $width :reader :param=100;
field $height :reader :param=100;

method get_instance :common (%params)
{
    state $instance = Game::World->new(%params);
    return $instance
}

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

method get_entity_at($point)
{
    return
        first {
            my $pos = $_->do('get_position');
            $pos->equals_to($point)
        }
        values %entities
}

method loop(@commands)
{
    my %actor_to_commands;
    for my $command (@commands)
    {
        my $actor = $command->actor();
        push $actor_to_commands{$actor}->@*, $command;
    }

    # p %actor_to_commands, as => 'actor_to_command';

    for my $entity (values %entities)
    {
        my $id = $entity->id();

        my $commands_for_actor =
            $actor_to_commands{$id};

        my $response = $entity->update($commands_for_actor);
        # p $response, as => 'response';
        # p $entity, as => 'entity';
    }

    return
}

1;
