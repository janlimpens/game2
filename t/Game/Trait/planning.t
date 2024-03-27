#! /usr/bin/env perl
use v5.38;
use Test2::V0;
use Test2::Tools::Exception qw(dies lives);
use local::lib;
use lib 'lib';
use builtin qw(true false);
use Data::Printer;
use Game::Entity;
use Game::Domain::Task;
use Game::Domain::Command;
use Game::Trait::Planning;
use Game::Trait::Mobile;
use Game::Trait::Position;
no warnings qw(experimental::builtin);

subtest 'Game::Trait::Planning' => sub
{
    my $trait = Game::Trait::Planning->new();

    my $entity = Game::Entity->new(
        initial_traits => [
            Game::Trait::Mobile->new(),
            Game::Trait::Position->new(),
            $trait
        ]
    );

    ok $entity->has_ability('go_to'), 'has ability go';

    my $position = $entity->do('get_position');

    ok $position, 'position is defined';

    # p $entity->abilities();

    ok $entity->has_ability('queue_task'), 'has ability queue_task';

    ok $entity->has_ability('current_task'), 'has ability current_task';

    is $entity->do('current_task'), undef, 'current_task is undef';

    my $task = Game::Domain::Task->new(
        do => Game::Domain::Command->new(
                actor => $entity,
                action => 'move',
                params => ['n']),
        while => sub($entity, $iteration)
        {
            my $pos = $entity->do('get_position');
            return $pos->y() <= $position->y() + 2
        });

    $entity->do('queue_task', $task);

    $entity->update(1);

    my $pos_after_1 = $entity->do('get_position');

    # p $pos_after_1, as => 'pos_after_1';

    is $pos_after_1->y(), $position->y()+1, 'moved north';

    $entity->update(2);

    my $pos_after_2 = $entity->do('get_position');

    is $pos_after_2->y(), $position->y()+2, 'moved north again';

    $entity->update(3);

    my $pos_after_3 = $entity->do('get_position');

    ok $pos_after_3, $pos_after_2, 'stopped moving';
};

done_testing();
