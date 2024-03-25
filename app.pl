#! /usr/bin/env perl
use v5.38;
use local::lib;
use lib './lib';
use builtin qw(true false blessed);
use feature qw(say);
no warnings qw(experimental::builtin experimental::class);

use Data::Printer;
use Game::Entity;
use Game::Trait::Body;
use Game::Trait::Interactive;
use Game::Trait::Mobile;
use Game::Trait::Named;
use Game::Trait::NPC;
use Game::Trait::Position;
use Game::Trait::Sight;
use Game::Trait::Visible;
use Game::World;
use Game::Domain::Command;

sub build_human(%args)
{
    my $description = delete $args{description} // "A human being.";
    my $diameter = delete $args{diameter}//1;
    my $height = delete $args{height}//2;
    my $name = delete $args{name};
    my $position = delete $args{position} // Game::Domain::Point->origin();
    my $traits = delete $args{initial_traits} // [];
    my $width = delete $args{width}//1;
    my %traits =
        map { blessed($_) => $_ }
        grep { $_ }
        (
            Game::Trait::Body->new(height => $height, width => $width, diameter => $diameter),
            $name ? Game::Trait::Named->new(name => $name) : (),
            Game::Trait::Position->new(position => $position),
            Game::Trait::Mobile->new(),
            Game::Trait::Visible->new(description => $description),
            Game::Trait::Sight->new(),
            $traits->@*
        );
    my $e = Game::Entity->new(%args);

    $e->add_trait($_) for values %traits;

    return $e
}

my $stop_me = false;

my $world = Game::World->get_instance(heigh=>10, width=>10);

my $alice = build_human(
    name => 'Alice',
    description => 'Alice stands there, looking goofy. She wears a blue dress with a checkered apron.',
    position => Game::Domain::Point->new(x=>10, y=>10, z=>0),
    initial_traits => [ Game::Trait::NPC->new() ]
);

$world->add_entity($alice);

my $bob = build_human(
    name => 'Bob',
    description => 'Bob is a nice guy.',
    position => Game::Domain::Point->new(x=>1, y=>1, z=>0),
    initial_traits => [ Game::Trait::Interactive->new() ]
);

$world->add_entity($bob);

my $tree = Game::Entity->new(
    id => 'tree',
    initial_traits => [
        Game::Trait::Body->new(height => 10, width => 10, diameter => 3),
        Game::Trait::Named->new(name => 'a tree'),
        Game::Trait::Position->new(position => [5,5,0]),
        Game::Trait::Visible->new(
            description => 'It is full of leaves, that move in the wind.')
    ]);

$world->add_entity($tree);

my $cat = Game::Entity->new(
    id => 'cat',
    initial_traits => [
        Game::Trait::Body->new(height => 1, width => 1, diameter => 1),
        Game::Trait::Named->new(name => 'the Cheshire cat'),
        Game::Trait::Position->new(position => [6,6,6]),
        Game::Trait::Visible->new(
            visible => false,
            description => 'The cat smiles, but nobody can see it.'),
        Game::Trait::Sight->new(distance => 5),
    ]);

$world->add_entity($cat);

$SIG{INT} = sub {
    say "Quitting.";
    $stop_me = true
};

my $loop = 0;

until($stop_me || $world->should_quit())
{
    $bob->do('look_around');
    $world->update($loop++);
}

1;
