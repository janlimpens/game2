#! /usr/bin/env perl
use v5.38;
use Test2::V0;
use local::lib;
use lib qw(lib);
use builtin qw(true false);
use Game::Entity;
use Game::Trait::Body;
no warnings qw(experimental::builtin);

subtest 'Game::Entity initialization' => sub
{
    my $entity = Game::Entity->new();

    is [$entity->abilities()], [], 'get_abilities()';

    my $trait = Game::Trait::Body->new(
        height => 2,
        width => 1,
        depth => 1);

    $entity->add_trait($trait);

    is [$entity->abilities()], [sort qw(
        get_depth
        fits_inside
        fits_through
        get_body
        get_height
        get_volume
        get_width )], 'get_abilities()';

    $entity->remove_trait('Game::Trait::Body');

    is [$entity->abilities()], [], 'get_abilities()';
};

done_testing();
