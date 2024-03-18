use v5.38;
use local::lib;
use Object::Pad;

class Game::Entity;
no warnings qw(experimental::builtin);
use builtin qw(blessed);
use Carp;
use Data::Printer;
use Log::Log4perl qw(get_logger);;

field $id :reader :param=undef;
field %traits;
field $initial_traits :param(traits)=[];

my $count = 1;

ADJUST
{
    $id //= $count++;

    $self->add_trait($_)
        for $initial_traits->@*;
}

method trait_types()
{
    return keys %traits
}

method add_trait($trait)
{
    $traits{blessed $trait} = $trait;
}

method abilities()
{
    my @abs =
        sort
        map { $_->abilities()->@* }
        values %traits;

    return \@abs;
}

method has_ability($ability)
{
    return
        grep { $_ eq $ability }
        $self->abilities()->@*
}

method find_trait_with_ability($ability)
{
    my @found_traits =
        grep { $_->has_ability($ability) }
        values %traits;

    return @found_traits < 2
        ? $found_traits[0]
        : croak("Entity $id has more than one trait with ability $ability.");
}

method do($ability, @params)
{
    if (my $trait = $self->find_trait_with_ability($ability))
    {
        return $trait->do($self, $ability, @params);
    }
    $self->log(info => "Entity $id does not have ability $ability.");
}

method update($commands)
{
    my %responses =
        map {
            my $c = $_;
            my %resp =
                map {
                    my $r = $_->update($self, $c);
                    $r ? ($c->stringify() => $r) : ()
                }
                grep { $c->actor() eq $id && $_->has_ability($c->action()) }
                values %traits;
            %resp
        }
        $commands->@*;

    return \%responses
}

method stringify()
{
    return
        "Entity $id: "
        . join(', ', map { $_->stringify() } values %traits)
        . "; Abilities: "
        . join(', ', $self->abilities()->@*)
}

method log($level, $message)
{
    get_logger('Game::Entity')->$level($message);
}

1;
