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
field %properties;
field $initial_properties :param(properties)=[];

my $count = 1;

ADJUST
{
    $id //= $count++;

    $self->add_property($_)
        for $initial_properties->@*;
}

method add_property($property)
{
    $properties{blessed $property} = $property;
}

method abilities()
{
    my @abs =
        sort
        map { $_->abilities()->@* }
        values %properties;

    return \@abs;
}

method has_ability($ability)
{
    return
        grep { $_ eq $ability }
        $self->abilities()->@*
}

method find_property_with_ability($ability)
{
    my @found_properties =
        grep { $_->has_ability($ability) }
        values %properties;

    return @found_properties < 2
        ? $found_properties[0]
        : croak("Entity $id has more than one property with ability $ability.");
}

method do($ability, @params)
{
    if (my $property = $self->find_property_with_ability($ability))
    {
        return $property->do($self, $ability, @params);
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
                values %properties;
            %resp
        }
        $commands->@*;

    return \%responses
}

method stringify()
{
    return
        "Entity $id: "
        . join(', ', map { $_->stringify() } values %properties)
        . "; Abilities: "
        . join(', ', $self->abilities()->@*)
}

method log($level, $message)
{
    get_logger('Game::Entity')->$level($message);
}

1;
