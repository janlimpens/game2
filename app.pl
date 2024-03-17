#! /usr/bin/env perl
use v5.38;
use local::lib;
use lib './lib';
use builtin qw(true false);
use feature qw(say);

use Data::Printer;
use Game::Entity;
use Game::Property::Named;
use Game::World;
use Game::Command;

my $stop_me = false;

my $world = Game::World->new();

my $entity = Game::Entity->new(
    id => 'bob',
    properties => [
        Game::Property::Named->new(
            name => 'Bob')]);

$world->add_entity($entity);

$SIG{INT} = sub { $stop_me = true };

my $loop = 0;

until($stop_me)
{
    $loop++;

    say "$loop. Enter a command:";

    my $command = <STDIN>;
    chomp $command;
    say $command;

    my ($actor, $action, @params) = split / /, $command;

    my @commands = $actor && $action ?
        Game::Command->new(
            actor => $actor,
            action => $action,
            params => \@params
        ) : ();

    $world->loop(@commands);
}

1;
