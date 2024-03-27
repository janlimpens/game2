use v5.38;

use local::lib;
use lib 'lib';
use Object::Pad ':experimental(inherit_field)';

class Game::Domain::Pronouns;

no warnings qw(experimental::builtin);

field $nom :reader :inheritable :param='they';
field $gen :reader :inheritable :param='their';
field $dat :reader :inheritable :param='them';
field $selfref :reader :inheritable :param='themself';
field $conj :reader :inheritable :param='';

method I :common ()
{
    return $class->new(nom => 'I', gen => 'my', dat => 'me', selfref => 'myself')
}

method you :common ()
{
    return $class->new(nom => 'you', gen => 'your', dat => 'you', selfref => 'yourself')
}

method he :common ()
{
    return $class->new(nom => 'he', gen => 'his', dat => 'him', selfref => 'himself', conj => 's')
}

method she :common ()
{
    return $class->new(nom => 'she', gen => 'her', dat => 'her', selfref => 'herself', conj => 's')
}

method it :common ()
{
    return $class->new(nom => 'it', gen => 'its', dat => 'it', selfref => 'itself',
        conj => 's')
}

method we :common ()
{
    return $class->new(nom => 'we', gen => 'our', dat => 'us', selfref => 'ourselves')
}

method you_plural :common ()
{
    return $class->new(nom => 'you', gen => 'your', dat => 'you', selfref => 'yourselves')
}

method they :common ()
{
    return $class->new(nom => 'they', gen => 'their', dat => 'them', selfref => 'themselves')
}

1;
