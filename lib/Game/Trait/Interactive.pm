use v5.38;
use local::lib;
use Object::Pad;
use lib qw(lib);
class Game::Trait::Interactive;

no warnings qw(experimental::builtin);
use builtin qw(true false);
use feature qw(say);
use Carp;
use Data::Printer;
use Game::Domain::Command;
use Game::World;

field $last_command;
field $world = Game::World->get_instance();
field %changes;
field $current_position;
field $init = false;
field $entity_name;

method description :common ($name='An entity with this trait')
{
    return "$name can be controlled by user commands."
}

method update($entity, $iteration)
{
    unless ($init)
    {
        $world->subscribe(position => sub($e, $position)
        {
            $current_position = $position
                if $e->id() eq $entity->id();
        });

        $init = true;
    }

    $entity_name = $entity->do('get_name') // $entity->id();

    say "Input command for $entity_name and hit enter:";

    print "$entity_name > ";

    my $input = <STDIN>;
    chomp $input;
    my $cmd;

    if ($input eq ':q')
    {
        return { quit => $world->quit() };
    }
    elsif ($input eq '')
    {
        $cmd = $last_command;
    }

    unless ($cmd)
    {
        my ($action, @params) = split / /, $input;

        $cmd = Game::Domain::Command->new(
                actor => $entity->id(),
                action => $action,
                params => \@params)
            if $action;
    }

    unless ($cmd)
    {
        return say "$entity_name doesn't know what to do with $input.";
    }

    $last_command = $cmd;

    my $action = $cmd->action();

    return say "$entity_name does not know how to do $action"
        unless $entity->has_ability($action);

    return $entity->do( $cmd->action() => $cmd->params()->@* )
}

method stringify()
{
    return sprintf "Interactive";
}

apply Game::Role::Trait;

# ADJUST {};

1;
