use v5.38;

use local::lib;

use Object::Pad;

class Game::Property::Named;
apply Game::Property;
no warnings qw(experimental::builtin);
use builtin qw(true false);
use feature qw(say);
use Data::Printer;

field $name :param :reader;

ADJUST
{
    my %abilities = (
        set_name => method($entity, $new) {
            $name = $new
                if $name && $new ne $name;
            $self->is_dirty(true);
            return
        },
        get_name => method($entity) {
            return $name
        },
    );

    for my $ability (keys %abilities)
    {
        $self->add_ability($ability, $abilities{$ability});
    }
}

method stringify()
{
    return sprintf "Name ($name)";
}

1;
