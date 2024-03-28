use v5.38;
use local::lib;
use lib qw(lib);
use Object::Pad;

class Game::Trait::Planning;

no warnings qw(experimental::builtin);
use builtin qw(true false);
use feature qw(say);
use Carp;
use Data::Printer;
use Game::Domain::Command;

field @tasks;

method description :common ($name='An entity with this trait')
{
    return "$name be assigned tasks and will try to perform across a period until completion."
}

method queue_task($task)
{
    croak('Task required')
        unless $task;

    croak('Game::Domain::Task required')
        unless $task->isa('Game::Domain::Task');

    push @tasks, $task;

    return $task
}

method current_task()
{
    return $tasks[0]
}

method update($entity, $iteration)
{
    $DB::single=1;
    if (my $task = $self->current_task())
    {
        $task->update($entity, $iteration);

        shift @tasks
            if $task->done();

        return {}
    }
    return {}
}

method stringify()
{
    return sprintf 'Planning(%d tasks)', scalar @tasks;
}

method properties()
{
    return qw(current_task)
}

method abilities()
{
    return qw(queue_task)
}

apply Game::Role::Trait;

1;
