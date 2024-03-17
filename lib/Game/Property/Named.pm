use v5.38;
use local::lib;

use Object::Pad;

class Game::Property::Named;
apply Game::Property;

use feature qw(say);
use Data::Printer;

field $my_name :param(name);

field $is_dirty;

field %abilities = (
    introduce => \&introduce,
    set_name => \&my_name,
    get_name => \&my_name,
);

method name { 'named' }

method my_name(@params)
{
    if (@params)
    {
        $my_name = $params[0] // 'nobody';
    }

    $self->introduce();
    return $my_name
}

method introduce(@params)
{
    say("Hello, I'm called $my_name.")
}

method abilities()
{
    return [sort keys %abilities]
}

method update($command)
{
    if ($abilities{$command->action()})
    {
        $abilities{$command->action()}->($self, $command->params()->@*);
    }
}

method can_process($action)
{
    return exists $abilities{$action}
}

method stringify()
{
    return
        sprintf "Named ($my_name), abilities: %s.",
            join(', ', ($self->abilities())->@*);
}

1;
