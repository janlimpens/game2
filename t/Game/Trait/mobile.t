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

    my %expected_abilities = (
        move => {
            params => ['n'],
            expected => true },
        go_to => {
            params => [Game::Domain::Point->new(x=>10, y=>10, z=>0)],
            expected => true
        },
    );

    is [$entity->abilities()], [sort keys %expected_abilities, $pos->abilities()], 'get_abilities()';

    for my ($ability) (keys %expected_abilities)
    {
        my $case = $expected_abilities{$ability};
        my @params = ($case->{params}//[])->@*;
        my $expected = $case->{expected};
        is $entity->do($ability, @params), $expected, "do($ability)->($params[0])";
    };
};

done_testing();
