
use v5.38;
use local::lib;
use Object::Pad;

class Game::Domain::Task;

no warnings qw(experimental::builtin);
use builtin qw(true false indexed);
use feature qw(say);
use Carp;
use Data::Printer;

field $do :param;
field $while :param;
field $done=false;
field $max_iterations :param=undef;

method done()
{
    return $done
}

method update($entity, $iteration)
{
    return if $done;

    if (defined $max_iterations && $iteration >= $max_iterations)
    {
        return $done = true;
    }

    if ($while->($entity, $iteration))
    {
        return $entity->do( $do->action(), $do->params()->@* );
    }
    else
    {
        return $done = true;
    }
}

1;
