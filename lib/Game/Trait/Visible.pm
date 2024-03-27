use v5.38;
use local::lib;
use Object::Pad;
use lib qw(lib);

class Game::Trait::Visible;

no warnings qw(experimental::builtin experimental::for_list);
use builtin qw(true false);
use feature qw(say);
use Data::Printer;

field $appearance :param(description)='';
field $visible :param=1;

method description :common ($name='An entity with this trait')
{
    return "$name can define its visibility. Visible things have a description"
}

method stringify()
{
    return sprintf "Visible ($visible)";
}

method update($entity, $iteration)
{
    return
}

method properties()
{
    return qw(appearance visible)
}

apply Game::Role::Trait;

ADJUST
{
    my %abilities = (
        get_description => method($entity) {
            return $appearance
        },
        is_visible => method($entity) {
            return $visible
        },
        toggle_visible => method($entity) {
            $visible = !$visible;
            $self->is_dirty(true);
            return $visible
        },
    );

    for my ($ability, $method) (%abilities)
    {
        $self->add_ability($ability, $method);
    };
}

1;
