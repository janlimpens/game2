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

field %last_command;

method description :common ($name='An entity with this trait')
{
    return "$name can be controlled by user commands."
}

method get_position($entity)
{
    return $entity->do('get_position');
}

method move($entity, $direction)
{
    my $name = $entity->do('get_name') // $entity->id();
    my $m = $entity->do('move', $direction);
    my $position = $entity->do('get_position')->stringify();
    say "$name moves $direction and arrives at $position";
}

method update($entity, $iteration)
{
    my $entity_name = $entity->do('get_name') // $entity->id();

    say "Input command for $entity_name and hit enter:";

    print "$entity_name > ";

    my $input = <STDIN>;
    chomp $input;

    # p $input;

    my $cmd;

    if ($input eq ':q')
    {
        return Game::World->get_instance()->quit();
    }
    elsif ($input eq '')
    {
        $cmd = $last_command{$entity->id()};
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

    # p $cmd;

    return say "$entity_name doesn't do anything at all."
        unless $cmd;

    $last_command{$entity->id()} = $cmd;

    my $action = $cmd->action();
    # p $cmd, class => { stringify => 0 };
    # p $action, as => 'action';

    # p $cmd;

    return say "$entity_name does not know how to do $action"
        unless $entity->has_ability($action);

    if (my $own_method = $self->can($action))
    {
        return $own_method->($self, $entity, $cmd->params()->@*);
    }

    return $entity->do( $cmd->action() => $cmd->params()->@* );
}

method stringify()
{
    return sprintf "Interactive";
}

apply Game::Role::Trait;

# ADJUST {};

1;
