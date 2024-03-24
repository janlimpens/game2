#! /usr/bin/env perl
use v5.38;
use Test2::V0;
use local::lib;
use lib 'lib';
use Game::Domain::Direction;

subtest 'Game::Domain::Direction' => sub
{
    is (Game::Domain::Direction->named('north')->key(), 'n', 'named()');

    is Game::Domain::Direction->direction('n')->name(), 'north', 'name()';

    is Game::Domain::Direction->names()->[0], 'north', 'names()';

    is Game::Domain::Direction->direction('n')->offset(), [0,1], 'offset()';
};

done_testing();
