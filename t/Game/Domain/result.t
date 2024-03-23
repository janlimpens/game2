#! /usr/bin/env perl
no warnings qw(experimental::builtin);
use Test2::V0;
use Test2::Tools::Exception qw(dies lives);
use local::lib;
use lib 'lib';
use builtin qw(true false);
use Data::Printer;
use Game::Domain::Result;

subtest 'Game::Domain::Result' => sub
{
    my $e_res = Game::Domain::Result->new( error => 'error' );

    is $e_res->error(), 'error', 'error()';

    is $e_res->some(), undef, 'some()';

    my $s_res = Game::Domain::Result->new( some => 'some' );

    is $s_res->error(), undef, 'error()';

    is $s_res->some(), 'some', 'some()';

    # like( dies { die 'xxx' }, qr/xxx/, "Got exception" );

    like( dies {
            Game::Domain::Result->new(
                error => 'error',
                some  => 'some' );
        },
        qr/Some or Error required, not both/
      );

    like( dies {
            Game::Domain::Result->new();
        },
        qr/Either some or error required required/
      );
};

done_testing();
