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

method queue_task($task)
{
    return Game::Domain::Result->with_error('Task required')
        unless $task;

    return Game::Domain::Result->with_error('Game::Domain::Task required')
        unless $task->isa('Game::Domain::Task');

    push @tasks, $task;

    return Game::Domain::Result->with_some($task)
}

method current_task()
{
    if (my $t = $tasks[0]) {
        return $t;
    }
}

method update($entity, $iteration)
{
    if (my $task = $self->current_task())
    {
$DB::single=1;
        $task->update($entity, $iteration);
        shift @tasks
            if $task->done();
    }
    return
}

apply Game::Trait;

ADJUST
{
    $self->add_ability( queue_task => sub($entity, @tasks) { $self->queue_task($_) for @tasks } );
    $self->add_ability( current_task => sub($entity, @params) { return $self->current_task() } );
}

1;
