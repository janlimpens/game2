use v5.38;
use local::lib;
use lib qw(lib);
use Object::Pad;

class Game::Trait::Planning;

no warnings qw(experimental::builtin);
use builtin qw(true false);
use feature qw(say);
use Data::Printer;
use Game::Domain::Result;
use Game::Command;

field @tasks;
# Game::Trait implementation

method description :common ($name='An entity with this trait')
{
    return "$name be assigned tasks and will try to perform across a period until completion."
}

method queue_task($entity, $task)
{
    return Game::Domain::Result->with_error('Task required')
        unless $task;

    return Game::Domain::Result->with_some(push @tasks, $task);
}

method current_task($entity)
{
    if (my $t = $tasks[0]) {
        return $t;
    }
}

method update($entity, $iteration)
{
    my $task = $self->current_task($entity);
    if ($task)
    {
        if (my $command = $task->current_step())
        {
            my $result =
                $entity->do($command->action(), $command->params()->@*);

            if (ref $result eq 'Game::Domain::Result' && $result->was_successful()){
                $task->next_step();
            } elsif ($result) {
                $task->next_step();
            }
        }
        else
        {
            $task->complete();
            shift @tasks;
        }
    }
}

apply Game::Trait;

ADJUST
{
    $self->add_ability( queue_task => \&queue_task );
    $self->add_ability( current_task => \&current_task );
}

1;
