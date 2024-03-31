use v5.38;
use local::lib;
use Object::Pad;
use lib qw(lib);

class Game::Trait::Visible;

no warnings qw(experimental::builtin experimental::for_list);
use builtin qw(true false);
use feature qw(say);
use Data::Printer;

field $appearance :reader :param(description)='';
field $visible :param=1;
field $can_change_visibility :param=false;

method description :common ($name='An entity with this trait')
{
    return "$name can define its visibility. Visible things have an appearance."
}

method stringify()
{
    return sprintf "Visible ($visible)";
}

method update($entity, $iteration)
{
    return {}
}

method properties()
{
    return qw(appearance is_visible)
}

method abilities()
{
    my @abilities = qw(toggle_visible);

    return
        grep { !$can_change_visibility || $_ ne 'toggle_visible' }
        @abilities
}

apply Game::Role::Trait;

method is_visible ()
{
    return $visible
}

method toggle_visible ($entity)
{
    return false
        unless $can_change_visibility;

    $visible = !$visible;
    $self->is_dirty(true);

    return $visible
}


1;
