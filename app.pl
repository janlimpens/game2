#! /usr/bin/env perl
use v5.38;
use local::lib;
use lib './lib';
use builtin qw(true false);
use feature qw(say);
no warnings qw(experimental::builtin experimental::class);

use Data::Printer;
use Game::Entity;
use Game::Trait::Mobile;
use Game::Trait::Named;
use Game::Trait::Position;
use Game::Trait::Sight;
use Game::Trait::Visible;
use Game::World;
use Game::Command;


my $stop_me = false;

my $world = Game::World->get_instance(heigh=>10, width=>10);

my $bob = Game::Entity->new(
    id => 'bob',
    traits => [
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
        Game::Trait::Named->new(name => 'a tree'),
        Game::Trait::Position->new(position => [5,5,0]),
        Game::Trait::Visible->new(
            description => 'This beautiful tree is full of leaves, moving in the wind.')
    ]);

my $ghost = Game::Entity->new(
    id => 'ghost',
    traits => [
        Game::Trait::Named->new(name => 'Count Dracula'),
        Game::Trait::Position->new(position => [6,6,6]),
        Game::Trait::Visible->new(
            visible => false,
            description => 'Dracula is scarily invisible.'),
        Game::Trait::Sight->new(distance => 5),
    ]);

$world->add_entity($tree);

$bob->do('look_around');

$SIG{INT} = sub { $stop_me = true };

my $loop = 0;

until($stop_me)
{
    $loop++;

    say "$loop. Enter a command:";

    my $command = <STDIN>;
    chomp $command;

    my ($actor, $action, @params) = split / /, $command;

    my @commands = $actor && $action
        ? Game::Command->new(
            actor => $actor,
            action => $action,
            params => \@params
        )
        : ();

    $world->loop(@commands);
}

1;
