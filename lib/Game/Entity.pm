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
        if $self->does_have_trait($class) && !$other->does_have_trait($class);

    return false
}

method do($ability, @params)
{
    if (my ($trait) = $self->find_traits_with_ability($ability))
    {
        # always a Result
        return $trait->do($self, $ability, @params);
    }

    return Game::Domain::Result->with_err("Entity $id does not have ability $ability.");
}

method get($property)
{
    my @results =
        map { $_->get($property) }
        $self->find_traits_with_property($property);

    return Game::Domain::Result->with_err("Entity $id does not have property $property.")
        unless @results;

    if (@results == 1)
    {
        return $results[0];
    }

    return wantarray() ? @results : \@results;
}

apply Game::Role::Bearer;

method stringify()
{
    # p $self->trait_types(), as => 'trait types';

    my @traits =
        map { (blessed $_)->description() }
        $self->trait_types();

    return sprintf
        "Entity $id; Traits: %s; Abilities: %s.",
        join(', ', @traits),
        join(', ', $self->abilities())
}

method equal_to($other)
{
    return $id eq $other->id();
}

method log($level, $message)
{
    # get_logger('Game::Entity')->$level($message);
}


1;
