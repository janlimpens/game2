use v5.38;
use local::lib;
use Object::Pad;

class Game::Property::Visible;
apply Game::Property;

no warnings qw(experimental::builtin);
use builtin qw(true false);
use feature qw(say);
use Data::Printer;

field $description :reader :param='';
field $visible :reader :param=1;

ADJUST
{
    my %abilities = (
        get_description => method($entity) {
            return $description
        },
        is_visible => method($entity) {
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
