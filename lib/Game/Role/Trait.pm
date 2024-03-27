use v5.38;
use feature qw(try);
use local::lib;
use Object::Pad;

role Game::Role::Trait;

no warnings qw(experimental::builtin experimental::try);
use Data::Printer;

field $is_dirty :accessor :param=!1;
field %abilities;

method description :common;

method update($entity, $iteration);
method abilities();
method properties();

method can_do($action)
{
    return grep { $action eq $_ } $self->abilities()
}

method has($property)
{
    return grep { $_ eq $property } $self->properties()
}

method do($entity, $action, @params)
{
    return
        Game::Domain::Result->with_error("Action $action not found")
            unless $self->can_do($action);

    try
    {
        my $x = $self->$action($entity, @params);

        return $x
            if defined $x && $x->isa('Game::Domain::Result');

        return Game::Domain::Result->with_some($x)
    }
    catch($e)
    {
        return Game::Domain::Result->with_error($e)
    }
}

method get($property)
{
    return
        Game::Domain::Result->new(
            $self->has($property)
                ? ( some => $self->$property() )
                : ( error => "Property $property not found") )
}

1;
