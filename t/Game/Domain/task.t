#! /usr/bin/env perl
use v5.38;
use Test2::V0;
use local::lib;
use lib 'lib';
use Object::Pad;
use Game::Domain::Command;
use Game::Domain::Task;
use Game::Entity;
use Game::Trait::Mobile;
use Game::Trait::Planning;
use Game::Trait::Position;

use constant {
    Command => 'Game::Domain::Command',
    Task => 'Game::Domain::Task',
    Entity => 'Game::Entity',
    Mobile => 'Game::Trait::Mobile',
    Position => 'Game::Trait::Position',
    Planning => 'Game::Trait::Planning',
};

class TestEntity
{
    field $r :reader = 1;
    method do($entity, $i) {
        $r++;
    }
}

subtest Task => sub
{
    my $task = Task->new(
        do => Command->new(
            actor => undef,
            action => 'go',
            params => ['n']),
        while => sub($entity, $i) { $i < 10 }
    );

    ok $task;
    ok !$task->done(), 'task is not done';

    my $entity = TestEntity->new();

    $task->update($entity, $_) for 1..10;

    ok $task->done(), 'task is done';

    is $entity->r(), 10, 'entity updated 10 times';
};

done_testing();
