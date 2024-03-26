#! /usr/bin/env perl
use v5.38;
use Test2::V0;
use local::lib;
use lib 'lib';
use Game::Domain::Task;
use Game::Domain::Command;

subtest 'Game::Domain::Direction' => sub
{
    my $task = Game::Domain::Task->new(
        do => Game::Domain::Command->new( actor => undef, action => 'go'),
        while => sub($entity, $i) { $i > 10 }
    );

    ok $task;
};

done_testing();
