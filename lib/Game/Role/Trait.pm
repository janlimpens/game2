use v5.38;
use feature qw(try);
use local::lib;
use Data::Printer;
use Game::Domain::Result;
use Object::Pad;

role Game::Role::Trait;

use constant {
    Result => 'Game::Domain::Result',
};

no warnings qw(experimental::builtin experimental::try);

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

method does_have($property)
{
    return grep { $_ eq $property } $self->properties()
}

method do($entity, $action, @params)
{
    return
        Result->with_err("Action $action not found")
            unless $self->can_do($action);

    try
    {
        my $x = $self->$action($entity, @params);

        return $x
            if defined $x && $x->isa('Game::Domain::Result');

        return Result->with_ok($x)
    }
    catch($e)
    {
        return Result->with_err($e)
    }
}

method get($property)
{
    if ($self->does_have($property))
    {
        return Result->with_ok($self->$property())
    }

    return Result->with_err("Property $property not found")
}

1;
