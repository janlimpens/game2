#! /usr/bin/env perl
no warnings qw(experimental::builtin);
use Test2::V0;
use Test2::Tools::Exception qw(dies lives);
use local::lib;
use lib 'lib';
use builtin qw(true false);
use Data::Printer;
use Game::Domain::Point;

subtest 'Game::Domain::Point' => sub
{
    my $p1 = Game::Domain::Point->new(x => 1, y => 2, z => 3);
    is $p1->x(), 1, 'x()';
    is $p1->y(), 2, 'y()';
    is $p1->z(), 3, 'z()';
};

subtest distance => sub
{
    my $p1 = Game::Domain::Point->new(x => 1, y => 2, z => 3);
    my $p2 = Game::Domain::Point->new(x => 1, y => 2, z => 3);
    is $p1->distance_to($p2), 0, 'distance_to()';

    my $p3 = Game::Domain::Point->new(x => 1, y => 5, z => 3);
    is $p1->distance_to($p3), 3, 'distance_to()';

    my $p4 = Game::Domain::Point->new(x => 1, y => 5, z => 5);
    is $p1->distance_to($p4), 3.60555127546399, 'distance_to()';
};

subtest equality => sub
{
    my $p1 = Game::Domain::Point->new(x => 1, y => 2, z => 3);
    my $p2 = Game::Domain::Point->new(x => 1, y => 2, z => 3);
    is $p1->equals_to($p2), true, 'equals_to()';

    my $p3 = Game::Domain::Point->new(x => 1, y => 5, z => 3);
    is $p1->equals_to($p3), false, 'equals_to()';
};

subtest new_from_values => sub
{
    my $p1 = Game::Domain::Point->new_from_values(1, 2, 3);
    is $p1->x(), 1, 'x()';
    is $p1->y(), 2, 'y()';
    is $p1->z(), 3, 'z()';
};

subtest approximate_direction_of => sub
{
    my $p1 = Game::Domain::Point->origin();
    my $p2 = Game::Domain::Point->new();
    is $p1->approximate_direction_of($p2), undef, 'approximate_direction_of()';

    my $p3 = Game::Domain::Point->new(y => 5);
    is $p1->approximate_direction_of($p3), 'north', 'approximate_direction_of()';

    my $p4 = Game::Domain::Point->new(x => 5, y => 5);
    is $p1->approximate_direction_of($p4), 'north east', 'approximate_direction_of()';
};

done_testing();
