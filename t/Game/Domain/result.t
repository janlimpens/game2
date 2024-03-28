#! /usr/bin/env perl
use v5.38;
use Test2::V0;
use Test2::Tools::Exception qw(dies lives);
use local::lib;
use lib 'lib';
use builtin qw(true false);
use Data::Printer;
use Game::Domain::Result;

no warnings qw(experimental::builtin);

subtest 'Game::Domain::Result' => sub
{
    my $e_res = Game::Domain::Result->new( err => 'err' );

    is $e_res->err(), 'err', 'err()';

    is $e_res->ok(), undef, 'ok()';

    my $s_res = Game::Domain::Result->new( ok => 'ok' );

    is $s_res->err(), undef, 'err()';

    is $s_res->ok(), 'ok', 'ok()';

    # like( dies { die 'xxx' }, qr/xxx/, "Got exception" );

    like( dies {
            Game::Domain::Result->new(
                err => 'err',
                ok  => 'ok' );
        },
        qr/Some or Error required, not both/
      );

    like( dies {
            Game::Domain::Result->new();
        },
        qr/Either ok or err required required/
      );
};

subtest ok => sub
{
    my $res = Game::Domain::Result->new( ok => ['x', 'y'] );
    my @ok = $res->ok();
    is $ok[0], 'x', 'ok()0';
    is $ok[1], 'y', 'ok()1';
    my $ok = $res->ok();
    is $ok, ['x', 'y'], 'ok()';
    my ($x, $y) = $res->ok();
    is $x, 'x', 'ok()';
    is $y, 'y', 'ok()';

    my $single = Game::Domain::Result->new( ok => 'x' );
    my @single = $single->ok();
    is $single[0], 'x', 'single()';
    is $single->ok(), 'x', 'single()';

    my ($unwrapped) = $res->ok();
    is $unwrapped, 'x', 'unwrapped()';
};

done_testing();
