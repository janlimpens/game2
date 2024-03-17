use v5.38;
use local::lib;
use Object::Pad;

class Game::Command;
no warnings qw(experimental::builtin);

field $actor :param :reader;
field $action :param :reader;
field $params :reader :param=[];

method stringify()
{
    return "$actor->$action(" . join(', ', $params->@*).")";
}

1;
