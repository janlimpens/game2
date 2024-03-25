use v5.38;
use local::lib;
use Object::Pad;
use lib './lib';
class Game::Entity;
apply Game::Role::Bearer;
no warnings qw(experimental::builtin);
use builtin qw(blessed true false);
use Carp;
use Data::Printer;
# use Log::Log4perl qw(get_logger);

field $id :reader :param=undef;

my $count = 1;

ADJUST
{
    $id //= $count++;
}

method give_trait($other, $class)
{
    return $other->add_trait($self->remove_trait($class))
        if $self->has_trait($class) && !$other->has_trait($class);

    return false
}

method do($ability, @params)
{
    if (my ($trait) = $self->find_traits_with_ability($ability))
    {
        return $trait->do($self, $ability, @params);
    }
    return
    # $self->log(info => "Entity $id does not have ability $ability.");
}

method stringify()
{
    my @traits =
        map { (blessed $_)->description() }
        $self->trait_types();

    return sprintf
        "Entity $id; Traits: %s; Abilities: %s.",
        join(', ', @traits),
        join(', ', $self->abilities())
}

method log($level, $message)
{
    # get_logger('Game::Entity')->$level($message);
}

1;
