use v5.38;
use local::lib;
use Object::Pad;

role Game::Role::Trait;

use feature qw(try);
no warnings qw(experimental::builtin);
use builtin qw(blessed);
use Carp qw(confess);
use Data::Printer;
use Game::Domain::Result;

use constant {
    Result => 'Game::Domain::Result',
};
use builtin qw(true false);
no warnings qw(experimental::builtin experimental::try);

field $is_dirty :accessor :param=!1;
field %abilities;

method description :common;

method update($entity, $iteration);
method abilities();
method properties();

method can_do($action)
{
    return false unless $action;
    return grep { $action eq $_ } $self->abilities()
}

method does_have($property)
{
    return false unless $property;
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
            if blessed $x && $x->isa('Game::Domain::Result');

        confess('Action did not return a Result object')
            unless defined $x;

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
        if (my $value = $self->$property())
        {
            return Result->with_ok($value)
        }
        return Result->with_err('Property $property returned undef')
    }

    return Result->with_err("Property $property not found")
}

1;
