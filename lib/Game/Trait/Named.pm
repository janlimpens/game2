use v5.38;

use local::lib;

use Object::Pad;

class Game::Trait::Named;
no warnings qw(experimental::builtin);
use builtin qw(true false);
use feature qw(say);
use Data::Printer;

field $name :reader :param;
field $mutable :param=true;
field $pronouns :param=[qw(they theirs them themself)];

method description :common ($name='An entity with this trait')
{
    return "$name has a name. It can be changed, if mutable is set to true."
}

method stringify()
{
    return sprintf "Name ($name)";
}

method update($entity, $iteration)
{
    return {}
}

method properties()
{
    return qw(name mutable)
}

method abilities()
{
    return qw(set_name)
}

apply Game::Role::Trait;

method set_name ($entity, $new)
{
    if ($mutable && $new ne $name)
    {
        $self->is_dirty(true);
        $name = $new
    }
    return $self->is_dirty()
}

1;
