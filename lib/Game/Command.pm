use v5.38;
use local::lib;
use Object::Pad;

class Game::Command;

field $actor :param :reader;
field $action :param :reader;
field $params :reader :param=[];

method stringify()
{
    return "$actor shall $action with " . join(', ', $params->@*);
}

1;
