#! /usr/bin/env perl
use v5.38;
use local::lib;
use lib './lib';
use builtin qw(true false);
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
use Game::Command;

my $stop_me = false;

my $world = Game::World->get_instance(heigh=>10, width=>10);

my $alice = Game::Entity->new(
    id => 'alice',
    traits => [
        Game::Trait::Body->new(height => 2, width => 1, diameter => 1),
        Game::Trait::Named->new(name => 'Alice'),
        Game::Trait::NPC->new(),
        Game::Trait::Position->new(position => [10,10,0]),
        Game::Trait::Mobile->new(),
        Game::Trait::Visible->new(description =>'Alice stands there, looking goofy. She wears a blue dress with a checkered apron.'),
        Game::Trait::Sight->new(),
    ]);

$world->add_entity($alice);

my $bob = Game::Entity->new(
    id => 'bob',
    traits => [
        Game::Trait::Body->new(height => 2, width => 1, diameter => 1),
        Game::Trait::Interactive->new(),
        Game::Trait::Named->new(name => 'Bob'),
        Game::Trait::Position->new(position => [1,1,0]),
        Game::Trait::Mobile->new(),
        Game::Trait::Visible->new(description =>'Bob is a nice guy.'),
        Game::Trait::Sight->new(),
    ]);

$world->add_entity($bob);

my $tree = Game::Entity->new(
    id => 'tree',
    traits => [
        Game::Trait::Body->new(height => 10, width => 10, diameter => 3),
        Game::Trait::Named->new(name => 'a tree'),
        Game::Trait::Position->new(position => [5,5,0]),
        Game::Trait::Visible->new(
            description => 'It is full of leaves, that move in the wind.')
    ]);

$world->add_entity($tree);

my $cat = Game::Entity->new(
    id => 'cat',
    traits => [
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
