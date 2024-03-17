use v5.38;
use local::lib;
use Object::Pad;

class Game::Entity;

use Data::Printer;

field $id :reader :param=undef;
field %properties;
field %abilities;
field $initial_properties :param(properties)=[];

my $count = 1;

ADJUST
{
    $id //= $count++;

    $properties{$_->name()} = $_
        for $initial_properties->@*;
}

method add_property($property)
{
    $properties{$property->name()} = $property;
    say "$id has a new property: " . $property->name();
}

method abilities()
{
    my %abs =
        map { $_->abilities() => 1 }
        values %properties;

    return [ sort keys %abs ];
}

method update($commands)
{
    my @commands = grep { $_ } $commands->@*;

    say sprintf 'Updating %s with %d command(s)', $id, scalar @commands;

    for my $property (values %properties)
    {
        for my $command (@commands)
        {
            $property->update($command)
                if $command->action()
                    && $property->can_process($command->action());
        }
    }
}

method stringify()
{
    return
        "Entity $id: properties: "
        . join(', ', map { $_->stringify() } values %properties);
}

1;
