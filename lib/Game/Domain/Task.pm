use v5.38;

use local::lib;

use Object::Pad;

class Game::Domain::Task;

no warnings qw(experimental::builtin);
use builtin qw(true false indexed);
use feature qw(say);
use Carp;
use Data::Printer;

field $steps :param //= [];
field $current = 0;
# field $importance :param //= 1;
# field $params :param //= {};

method current_step()
{
    return $steps->[$current]
}

method next_step()
{
    return unless $steps->@* >= $current;
    $current++;
    return $steps->[$current]
}

1;
