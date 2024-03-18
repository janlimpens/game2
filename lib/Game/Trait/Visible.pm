use v5.38;
use local::lib;
use Object::Pad;

class Game::Trait::Visible;

method description($name='An entity with this trait')
{
    return "$name can define its visibility. Visible things have a description"
}

apply Game::Trait;

no warnings qw(experimental::builtin);
use builtin qw(true false);
use feature qw(say);
use Data::Printer;

field $my_description :param(description)='';
field $visible :param=1;

ADJUST
{
    my %abilities = (
        get_description => method($entity) {
            return $my_description
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

method stringify()
{
    return sprintf "Visible ($visible)";
}

1;
