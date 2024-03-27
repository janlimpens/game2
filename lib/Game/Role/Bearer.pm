use v5.38;
use local::lib;
use Object::Pad ':experimental(inherit_field)';

role Game::Role::Bearer;

no warnings qw(
    experimental::builtin
    experimental::try
    experimental::for_list);
use builtin qw(blessed true false);
use feature qw(try);
use Carp qw(carp cluck longmess);
use Data::Printer;
field %traits;
my $count = 1;

# ADJUST :params ( :$initial_traits //= [] )
# "state" variable  masks earlier declaration in same statement
field $initial_traits :inheritable :param //= [];
ADJUST
{
    while (my $t = pop $initial_traits->@*)
    {
        $t
            ? $self->add_trait($t)
            : cluck('No initial trait to add')
    }
}

method trait_types()
{
    return keys %traits
}

method has_trait($trait)
{
    return exists $traits{$trait}
}

method add_trait($trait)
{
    return $trait
        ? $traits{blessed $trait} = $trait
        : cluck('No trait to add')
}

method remove_trait($class)
{
    return delete $traits{$class}
}

method abilities()
{
    my @abs =
        sort
        map { $_->abilities() }
        values %traits;

    return @abs;
}

method properties()
{
    my @props =
        sort
        map { $_->properties() }
        values %traits;

    return @props;
}

method has($property)
{
    return !!
        grep { $_ eq $property }
        $self->properties()
}

method can_do($ability)
{
    return !!
        grep { $_ eq $ability }
        $self->abilities()
}

method find_traits_with_ability($ability)
{
    my @found_traits =
        grep { $_->can_do($ability) }
        values %traits;
p %traits;
    return @found_traits;
}

method find_traits_with_property($property)
{
    my @found_traits =
        grep { $_->has($property) }
        values %traits;

    return @found_traits;
}

method update($i)
{
    my %result;

    for my $trait (values %traits)
    {
        my $result = $trait->update($self, $i);

        next unless ref $result;

        for my($k, $v) ($result->%*) {
            $result{$k} = $v;
        }
    }

    return \%result
}

1;
