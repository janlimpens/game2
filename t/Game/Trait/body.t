#! /usr/bin/env perl
use v5.38;
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
        depth => 3
    );

    is $body->height(), 1, 'height()';

    is $body->width(), 2, 'width()';

    is $body->depth(), 3, 'depth()';

    is $body->volume(), 6, 'volume()';

    my $e = Game::Entity->new(
        initial_traits => [ $body ]);

    is $e->do('fits_inside', $e)->is_error(), true,
        'does not fits_inside() (same body)';

    is $body->stringify(), 'Body (h: 1;w: 2; d: 3)', 'stringify()';

    ok $body->does_have('height'), 'does_have(height)';

    is $body->get('depth')->unwrap(), 3, 'get_property(depth)';
};

done_testing();
