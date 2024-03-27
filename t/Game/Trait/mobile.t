#! /usr/bin/env perl

use Test2::V0;
use local::lib;
use lib qw(lib);
use builtin qw(true false);
use Data::Printer;
use Game::Entity;
use Game::Trait::Mobile;
use Game::Trait::Position;
use Game::Domain::Point;
no warnings qw(experimental::builtin experimental::for_list);

subtest 'Game::Trait::Mobile' => sub
{
    my $entity = Game::Entity->new();

    my $pos = Game::Trait::Position->new();
    my $trait = Game::Trait::Mobile->new();

    $entity->add_trait($trait);
    $entity->add_trait($pos);

    my @expected_abilities = (
        {   ability => 'move',
            params => ['n'],
            expected => true
        },
        {   ability => 'go_to',
            params => [Game::Domain::Point->new(x=>10, y=>10, z=>0)],
            expected => true
        });

    for my ($case) (@expected_abilities)
    {
        my $ability = $case->{ability};
        my @params = ($case->{params}//[])->@*;
        my $expected = $case->{expected};
        my $got = $entity->do($ability, @params);
        ok defined $got, "do($ability)->(@params) returns value";
        is $got, $expected, "do($ability)->($params[0])";
    };
};

done_testing();
