use v5.38;
use local::lib;
use Object::Pad;

role Game::Role::Trait;

no warnings qw(experimental::builtin);
use Data::Printer;

field $is_dirty :accessor :param=!1;
field %abilities;

method description :common;

method update;

method abilities()
{
    return sort keys %abilities
}

method has_ability($action)
{
    return exists $abilities{$action}
}

method has($property)
{
    return grep { $_ eq $property } $self->properties()
}

method add_ability($action, $code)
{
    return $abilities{$action} //= $code;
}

method do($entity, $action, @params)
{
    # p %abilities, as => 'abilities';
    if (my $action = $abilities{$action})
    {
        # p $action;
        return $action->($self, $entity, @params)
    }
    return
}

method get($property)
{
    return
        Game::Domain::Result->new(
            $self->has($property)
                ? ( some => $self->$property() )
                : ( error => "Property $property not found")
        )
}

method properties();

1;
