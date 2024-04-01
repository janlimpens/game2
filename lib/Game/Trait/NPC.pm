use v5.38;
use local::lib;
use Object::Pad;

class Game::Trait::NPC;

no warnings qw(experimental::builtin);
use lib qw(lib);
use builtin qw(true false blessed);
use feature qw(say);
use Carp;
use Data::Printer;
use Game::Domain::Point;
use Scalar::Util qw(looks_like_number);

field $last_direction;
field %changes;
field %memory;

method description :common ($name='An entity with this trait')
{
    return "$name autonomously does random stuff and tries to learn from it."
}

method stringify()
{
    return sprintf "NPC";
}

method update($entity, $iteration)
{
    my %actions =
        map { $_ => 1 }
        $self->abilities();
    #random
    my ($ability) = keys %actions;

    say sprintf "NPC %s tries to %s.", $entity->id(), $ability;

    return {} unless $ability;

    my $result = $self->_do_something($entity, $ability);
    # p $result, as => 'result from npc';

    # p %memory;

    return \%changes
}

method _move($entity, $direction=undef)
{
    my $curr_pos = $entity->get('position')->unwrap_or(Game::Domain::Point->unknown());
    # p $curr_pos, as => "pos " . $entity->id();

    $direction =
        Game::Domain::Direction->direction($direction)
        // Game::Domain::Direction->direction($last_direction)
        // $self->_try_get_random_free_direction($entity)
        if (blessed $direction // 'x') ne 'Game::Domain::Direction';

    # p $direction, as => 'dir ' . $entity->id();

    return Game::Domain::Result->with_err('can\'t move')
        unless $direction;

    my $result = $entity->do('move', $direction);
    # p $result;

    $memory{move}{$direction} //= 0;
    $memory{move}{$direction} += $result->is_ok() ? 1 : -1;

    $last_direction = $direction
        if $result->is_ok();

    $curr_pos = $entity->get('position')->unwrap_or(Game::Domain::Point->unknown());
    # p $curr_pos, as => "pos " . $entity->id();

    return $result
}

method stand_around($entity)
{
    my $name = $entity->get('name')->unwrap_or($entity->id());

    my %variations =
        map { $_ => 1 }
        (
        'nothing',
        'nothing whatsoever',
        'nothing at all',
        'stare at their feet');

    my ($v) = keys %variations;

    $changes{does}{$v} = true;
    $last_direction = undef;

    return Game::Domain::Result->with_ok(true)
}

method repeat_last_movement($entity)
{
    $self->_move($entity)
}

method _try_get_random_free_direction($entity)
{
    my $vicinity = $entity->do('get_vicinity');

    $vicinity = $vicinity->unwrap_or(undef);

    return unless $vicinity;

    my %open_directions = $vicinity
        ? map { $_ => 1 } grep { !$vicinity->{$_} } keys $vicinity->%*
        : ();

    my ($dir) = keys %open_directions;

    return $dir
}

method walk_aimlessly($entity)
{
    my $dir = $self->_try_get_random_free_direction($entity);
    # say "Got dir $dir";
    my $result = $self->_move($entity, $dir);
    # p $result;
    return $result;
}

method do_something_random($entity)
{
    my %abilities =
        map { $_ => 1 }
        grep { $_ ne 'do_something_random' }
        $entity->abilities();

    my %properties =
        map { $_ => 1 }
        $entity->properties();

    return
        Game::Domain::Result->with_err('Entity %s has no abilities', $entity->id())
            unless %abilities;

    my ($ability) = keys %abilities;
    my ($param) = keys %properties; # inventory, too!

    my @param = $entity->get($param)->unwrap_or(undef);

    return $self->_do_something($entity, $ability, grep {$_} @param)
}

method get_type(@param)
{
    return 'VOID'
        unless @param;

    my ($value) = @param;

    return 'UNDEF'
        unless defined($value);

    return ref ($value)
        ? ref ($value) eq 'ARRAY'
            ? 'ARRAY'
            : ref($value) eq 'HASH'
                ? 'HASH'
                : blessed($value)
        : looks_like_number($value)
            ? 'NUMBER'
            : 'STRING'
}

method _do_something($entity, $ability, @params)
{
    confess "No ability given"
        unless $ability;

    confess "No recursion"
        if $ability eq '_do_something';

    return
        Game::Domain::Result->with_err("Entity cannot do $ability")
            unless $entity->can_do($ability);

    my $result = $entity->do($ability, @params);

    # p $result, as => $entity->id() . '::' . $ability;

    my $type = $self->get_type(@params);
    my ($value) = @params;

    # p $value, as => 'value';

    my $stored = ref($value)
        ? $value->isa('Game::Role::Serializes')
             ? $value->serialize()
             : '???'
        : $value;

    $memory{$ability}{$type}{attempts} //= 0;
    $memory{$ability}{$type}{attempts}++;
    $memory{$ability}{$type}{success} //= 0;
    $memory{$ability}{$type}{success} += $result->is_ok() ? 1 : -1;

    $memory{$ability}{$type}{values}{$stored//'UNDEF'} //= 0;
    $memory{$ability}{$type}{values}{$stored//'UNDEF'} += $result->is_ok() ? 1 : -1;;

    return $result
}

method do_something_easy($entity)
{
    my %abilities =
        map { $_ => 1 }
        grep { $_ ne 'do_something_easy' }
        $self->is_good_at();

    my ($ability) = keys %abilities;
    # params from memory!
    return $self->walk_aimlessly($entity)
        unless $ability;

    return $self->_do_something($entity, $ability)
}

method try_something_new($entity, @param)
{
    my %never_done_before =
        map { $_ => 1 }
        grep { !$memory{$_} }
        $entity->abilities();

    # p %never_done_before, as => 'never_done_before';

    return $self->do_something_easy($entity)
        unless %never_done_before;

    my ($ability) = keys %never_done_before;

    return $self->_do_something($entity, $ability)
}

method is_good_at()
{
    my @abilities =
        sort { $memory{$b} <=> $memory{$a} }
        grep { $memory{$_} > 0 }
        keys %memory;

    return wantarray() ? @abilities : \@abilities;
}

method is_bad_at()
{
    my @abilities =
        sort { $memory{$a} <=> $memory{$b} }
        grep { $memory{$_} < 0 }
        keys %memory;

    return wantarray() ? @abilities : \@abilities
}

method properties()
{
    # return qw(is_good_at is_bad_at)
}

method abilities()
{
    # return qw(
    #     do_something_random
    #     do_something_easy
    #     repeat_last_movement
    #     stand_around
    #     try_something_new
    #     walk_aimlessly
    # )
    return qw(
    repeat_last_movement
    stand_around
    walk_aimlessly
    )
}

apply Game::Role::Trait;

1;
