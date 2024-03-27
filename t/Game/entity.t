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
        diameter => 1);

    $entity->add_trait($trait);

    is [$entity->abilities()], [sort qw(
        fits_inside
        fits_through
    )], 'get_abilities()';

    is [$entity->properties()], [sort qw(
        body height width diameter volume
    )], 'get_properties()';

    $entity->remove_trait('Game::Trait::Body');

    is [$entity->abilities()], [], 'get_abilities()';
};

done_testing();
