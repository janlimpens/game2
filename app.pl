#! /usr/bin/env perl
use v5.38;
use local::lib;
use lib './lib';
use builtin qw(true false);
use feature qw(say);
no warnings qw(experimental::builtin experimental::class);

use Data::Printer;
use Game::Entity;
use Game::Property::Mobile;
use Game::Property::Named;
use Game::Property::Position;
use Game::Property::Sight;
use Game::Property::Visible;
use Game::World;
use Game::Command;


my $stop_me = false;

my $world = Game::World->get_instance(heigh=>10, width=>10);

my $bob = Game::Entity->new(
    id => 'bob',
    properties => [
        Game::Property::Named->new(name => 'Bob'),
        Game::Property::Position->new(position => [1,1,0]),
        Game::Property::Mobile->new(),
        Game::Property::Visible->new(description =>'Bob is a nice guy.'),
        Game::Property::Sight->new(),
    ]);

$world->add_entity($bob);

my $tree = Game::Entity->new(
    id => 'tree',
    properties => [
        Game::Property::Named->new(name => 'a tree'),
        Game::Property::Position->new(position => [5,5,0]),
        Game::Property::Visible->new(
            description => 'This beautiful tree is full of leaves, moving in the wind.')
    ]);

my $ghost = Game::Entity->new(
    id => 'ghost',
    properties => [
        Game::Property::Named->new(name => 'Count Dracula'),
        Game::Property::Position->new(position => [6,6,6]),
        Game::Property::Visible->new(
            visible => false,
            description => 'Dracula is scarily invisible.'),
        Game::Property::Sight->new(distance => 5),
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
