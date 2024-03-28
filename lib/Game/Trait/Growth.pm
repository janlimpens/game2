use v5.38;
use local::lib;
use Object::Pad;

class Game::Trait::Growth;

no warnings qw(experimental::builtin);
use lib qw(lib);
use builtin qw(true false);
use feature qw(say);
use Carp;
use Data::Printer;
use Game::Domain::Body;

use constant {
    Body => 'Game::Domain::Body',
};

field %changes;
field $body_trait :param;
field $min :param=Body->new(height => 0, width => 0, depth => 0);
field $max :param=Body->new(height => 3, width => 3, depth => 3);
field $increment :param=1;
field $curve :param=sub { default_curve(@_) };
field $stopped_growing = false;

method description :common ($name='An entity with this trait')
{
    return "$name can grow."
}

method stringify()
{
    return sprintf 'Body (%s)', $body_trait->body()->stringify()
}

method grow($entity, $iteration)
{
    return if $stopped_growing;
    my $body = $body_trait->body();

    my $new_size = $min->is_smaller_than($max)
        ? $curve->($iteration, $body_trait, $min, $max, $increment, \%changes)
        : $curve->($iteration, $body_trait, $max, $min, $increment, \%changes);

    $stopped_growing = true
        if $new_size >= $max->volume();

    return $new_size
}

method update($entity, $iteration)
{
    return unless
        $self->grow($entity, $iteration);

    my $changes = { %changes };
    %changes = ();

    return $changes
}

method properties()
{
    return ()
}

method abilities()
{
    return ()
}

apply Game::Role::Trait;

## no critic prototypes
sub default_curve($time, $body, $min, $max, $value, $changes)
{
    return
        if $body->equal_to($max);

    my $v1 = $body->volume();

    my $negative = $max->is_smaller_than($min);

    my $augment = $negative ? -1 * $value : $value;

    if ($body->height() < $max->height())
    {
        $body->height($body->height() + $augment);
        $changes->{height} = $body->height();
    }

    if ($body->width() < $max->width())
    {
        $body->width($body->width() + $augment);
        $changes->{width} = $body->height();
    }

    if ($body->depth() < $max->depth())
    {
        $body->depth($body->depth() + $augment);
        $changes->{depth} = $body->height();
    }

    my $v2 = $body->volume();
    my $growth = $v2 - $v1;
    $changes->{volume} = $growth;

    # p $changes, as => 'growth';

    return $growth
}

1;
