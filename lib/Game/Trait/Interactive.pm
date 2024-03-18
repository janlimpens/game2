use v5.38;
use local::lib;
use Object::Pad;

class Game::Trait::Interactive;

no warnings qw(experimental::builtin);
use builtin qw(true false);
use feature qw(say);
use Carp;
use Data::Printer;
use Game::Command;

method description($name='An entity with this trait')
{
    return "$name can be controlled by user commands."
}

apply Game::Trait;

ADJUST
{
    my %abilities = (
        receive_command =>
            method($entity, @params)
            {
                say 'Received command: ', join(' ', @params);
            }
    );
    for my $ability (keys %abilities)
    {
        $self->add_ability($ability, $abilities{$ability});
    }
};

method stringify()
{
    return sprintf "Interactive";
}

1;
