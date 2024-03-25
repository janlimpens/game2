#! /usr/bin/env perl
no warnings qw(experimental::builtin);
use Test2::V0;
use local::lib;
use lib qw(lib);
use builtin qw(true false);
use Game::Entity;
use Game::Trait::Interactive;

subtest 'Game::Trait::Interactive' => sub {
    plan tests => 1;

    my $entity = Game::Entity->new();

    my $trait = Game::Trait::Interactive->new();

    $entity->add_trait($trait);

    is [$entity->abilities()], [], 'get_abilities()';
};

done_testing();