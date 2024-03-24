#! /usr/bin/env perl
no warnings qw(experimental::builtin);
use Test2::V0;
use Test2::Tools::Exception qw(dies lives);
use local::lib;
use lib 'lib';
use builtin qw(true false);
use Data::Printer;
use Game::Entity;
use Game::Domain::Task;
use Game::Trait::Planning;
use Game::Trait::Mobile;
use Game::Trait::Position;

subtest 'Game::Trait::Planning' => sub
{
    my $trait = Game::Trait::Planning->new();

    my $entity = Game::Entity->new(
        traits => [
            Game::Trait::Mobile->new(),
            Game::Trait::Position->new(),
            $trait
        ]
    );

    ok $entity->has_ability('go'), 'has ability go';

    my $position = $entity->do('get_position');

    ok $position, 'position is defined';

    # p $entity->abilities();

    ok $entity->has_ability('queue_task'), 'has ability queue_task';

    ok $entity->has_ability('current_task'), 'has ability current_task';

    is $entity->do('current_task'), undef, 'current_task is undef';

    ok my $r1 = $entity->do('queue_task', Game::Domain::Task->new(
        steps => [
            map { Game::Command->new(
                actor => $entity,
                action => 'go',
                params => ['n']
            )}
            (1..3)
        ]
    )), 'queue_task returns result';

    ok $r1->was_successful(), 'queue_task was successful';

    ok my $current_task = $entity->do('current_task'), 'current_task is defined';

    ok my $step = $current_task->current_step(), 'current_step is defined';

    is $step->action(), 'go', 'step action is go';

    $entity->update(1);

    my $position_after_update = $entity->do('get_position');

    my $direction_gone = $position->approximate_direction_of($position_after_update);

    is $direction_gone, 'n', 'direction gone is north';
};

done_testing();
