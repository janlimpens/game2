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
use Game::Domain::Command;

no warnings qw(experimental::builtin);

subtest 'Game::Trait::Planning' => sub
{
    $DB::single=1;

    my $trait = Game::Trait::Planning->new();

    my $entity = Game::Entity->new(
        initial_traits => [
            Game::Trait::Mobile->new(),
            Game::Trait::Position->new(),
            $trait
        ]
    );

    ok $entity, 'entity is defined';

    ok $entity->can_do('go_to'), 'does_have ability go';

    my $position = $entity->get('position')->unwrap_or(undef);

    ok $position, 'position is defined';

    # p $entity->abilities();

    ok $entity->can_do('queue_task'), 'does_have ability queue_task';

    ok $entity->does_have('current_task'), 'does_have ability current_task';

    $DB::single=1;
    is $entity->get('current_task')->unwrap_or(undef), undef, 'current_task is undef';

    my $task = Game::Domain::Task->new(
        do => Game::Domain::Command->new(
                actor => $entity,
                action => 'move',
                params => ['n']),
        while => sub($entity, $iteration)
        {
            my $pos = $entity->get('position');
            return $pos->y() <= $position->y() + 2
        });

    ok $entity->do('queue_task', $task)->unwrap_or(false), 'queued task';

    $entity->update(1);

    my $pos_after_1 = $entity->get('position')->unwrap_or(undef);

    # p $pos_after_1, as => 'pos_after_1';

    is $pos_after_1->y(), $position->y()+1, 'moved north';

    $entity->update(2);

    my $pos_after_2 = $entity->get('position')->unwrap_or(undef);

    is $pos_after_2->y(), $position->y()+2, 'moved north again';

    $entity->update(3);

    my $pos_after_3 = $entity->get('position')->unwrap_or(undef);

    ok $pos_after_3, $pos_after_2, 'stopped moving';
};

done_testing();
