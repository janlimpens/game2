#! /usr/bin/env perl

use Test2::V0;
use local::lib;
use lib qw(lib);
use builtin qw(true false);
use Game::Entity;
use Game::Trait::Mobile;
no warnings qw(experimental::builtin experimental::for_list);

subtest 'Game::Trait::Mobile' => sub
{
    my $entity = Game::Entity->new();

    my $trait = Game::Trait::Mobile->new();

    $entity->add_trait($trait);

    my %expected_abilities = (
        move => { params => ['n'], expected => undef },
        walk => { params => ['ne'], expected => undef },
        go => { params => ['e'], expected => undef },
        run => { params => ['se'], expected => undef },
        tiptoe => { params => ['s'], expected => undef },
    );

    is [$entity->abilities()], [sort keys %expected_abilities], 'get_abilities()';

    for my ($ability) (keys %expected_abilities)
    {
        my $case = $expected_abilities{$ability};
        my @params = ($case->{params}//[])->@*;
        my $expected = $case->{expected};
        is $entity->do($ability, @params), $expected, "do($ability)";
    };
};

done_testing();
