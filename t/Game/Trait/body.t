#! /usr/bin/env perl
use Test2::V0;
use local::lib;
use lib qw(lib);
use builtin qw(true false);
use Game::Entity;
use Game::Trait::Body;
no warnings qw(experimental::builtin);

subtest 'Game::Trait::Body' => sub
{
    my $body = Game::Trait::Body->new(
        height => 1,
        width => 2,
        diameter => 3
    );

    is $body->height(), 1, 'height()';

    is $body->width(), 2, 'width()';

    is $body->diameter(), 3, 'diameter()';

    is $body->volume(), 6, 'volume()';

    my $e = Game::Entity->new(
        initial_traits => [ $body ]);

    is $e->do('fits_inside', $e)->unwrap(), undef, 'fits_inside()';

    is $body->stringify(), 'Body (h: 1;w: 2; d: 3)', 'stringify()';

    ok $body->has('height'), 'has(height)';

    is $body->get('diameter')->unwrap(), 3, 'get_property(diameter)';
};

done_testing();
