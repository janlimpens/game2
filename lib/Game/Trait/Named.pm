use v5.38;

use local::lib;

use Object::Pad;

class Game::Trait::Named;
no warnings qw(experimental::builtin);
use builtin qw(true false);
use feature qw(say);
use Data::Printer;

field $name :param;
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

apply Game::Role::Trait;

ADJUST
{
    my %abilities = (
        set_name => method($entity, $new) {
            $name = $new
                if $mutable && $name && $new ne $name;
            $self->is_dirty(true);
            return
        },
        get_name => method($entity) {
            return $name
        },
        get_pronouns => method($entity) {
            return $pronouns
        },
    );

    for my $ability (keys %abilities)
    {
        $self->add_ability($ability, $abilities{$ability});
    }
}

1;
