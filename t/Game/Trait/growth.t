#! /usr/bin/env perl
use Test2::V0;
use local::lib;
use lib qw(lib);
use builtin qw(true false);
use Game::Entity;
use Game::Trait::Body;
use Game::Trait::Growth;

no warnings qw(experimental::builtin);

subtest 'Game::Trait::Growth' => sub
{
    my $body = Game::Trait::Body->new(
        height => 1,
        width => 2,
        depth => 3
    );

    my $growth = Game::Trait::Growth->new(
        body_trait => $body
    );

    my $entity = Game::Entity->new(
        initial_traits => [ $body, $growth ]
    );

    my $height = $body->height();
    $growth->update($entity, 1);

    is $body->height(), $height + 1, 'update()';

};

done_testing();
