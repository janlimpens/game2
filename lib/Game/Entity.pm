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
use Game::Domain::Result;
# use Log::Log4perl qw(get_logger);

field $id :reader :param=undef;

my $count = 0;

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
        # always a Result
        return $trait->do($self, $ability, @params);
    }

    return Game::Domain::Result->with_error("Entity $id does not have ability $ability.");
}

method get($property)
{
    my @results =
        map { $_->get($property) }
        $self->find_traits_with_property($property);

    return Game::Domain::Result->new(
        @results
            ? ( some => @results == 1 ? $results[0] : \@results )
            : ( error => "Property $property not found in entity {$id}." ))
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
