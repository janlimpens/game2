#! /usr/bin/env perl
use v5.38;
use local::lib;
use lib './lib';
use builtin qw(true false blessed);
use feature qw(say);
no warnings qw(experimental::builtin experimental::class);

use Data::Printer;
use Game::Domain::Command;
use Game::Domain::Point;
use Game::Domain::Pronouns;
use Game::Domain::Task;
use Game::Entity;
use Game::Trait::Body;
use Game::Trait::Growth;
use Game::Trait::Interactive;
use Game::Trait::Mobile;
use Game::Trait::Named;
use Game::Trait::NPC;
use Game::Trait::Planning;
use Game::Trait::Position;
use Game::Trait::Sight;
use Game::Trait::Visible;
use Game::World;
## no critic (ProhibitSubroutinePrototypes)

use constant {
    Entity => 'Game::Entity',
    Body => 'Game::Trait::Body',
    Growth => 'Game::Trait::Growth',
    Interactive => 'Game::Trait::Interactive',
    Mobile => 'Game::Trait::Mobile',
    Named => 'Game::Trait::Named',
    NPC => 'Game::Trait::NPC',
    Planning => 'Game::Trait::Planning',
    Point => 'Game::Domain::Point',
    Position => 'Game::Trait::Position',
    Pronouns => 'Game::Domain::Pronouns',
    Sight => 'Game::Trait::Sight',
    Task => 'Game::Domain::Task',
    Visible => 'Game::Trait::Visible',
    World => 'Game::World',
    Command => 'Game::Domain::Command',
};

sub build_human(%args)
{
    my $description = delete $args{description} // "A human being.";
    my $depth = delete $args{depth}//1;
    my $height = delete $args{height}//2;
    my $name = delete $args{name};
    $args{id} //= lc $name;
    my $position = delete $args{position} // Point->origin();
    my $traits = delete $args{initial_traits} // [];
    my $width = delete $args{width}//1;

    my $body_trait =
        Body->new(height => $height, width => $width, depth => $depth);

    my $pronoun_name = delete $args{pronouns};
    my $pronoun = $pronoun_name ? Pronouns->$pronoun_name() : Pronouns->new();
    my %traits =
        map { blessed($_) => $_ }
        grep { $_ }
        (
            $body_trait,
            $name ? Named->new(name => $name) : (),
            Position->new(position => $position),
            Mobile->new(),
            Visible->new(description => $description),
            Sight->new(),
            Growth->new(
                min => Game::Domain::Body->new(height => 3, width => 1.2, depth => 1.2),
                max => Game::Domain::Body->new(height => 2.3, width => 1, depth => 1),
                increment => 0.01,
                body_trait => $body_trait,
            ),
            $traits->@*
        );
    my $e = Entity->new(%args);

    $e->add_trait($_) for values %traits;

    return $e
}

my $stop_me = false;

my $world = World->get_instance(heigh=>10, width=>10);

my $alice = build_human(
    name => 'Alice',
    description => 'Alice stands there, looking goofy. She wears a blue dress with a checkered apron.',
    position => Point->new(x=>10, y=>10, z=>0),
    initial_traits => [ NPC->new() ]
);

$world->add_entity($alice);

my $bob = build_human(
    name => 'Bob',
    description => 'Bob is a nice guy.',
    position => Point->new(x=>1, y=>1, z=>0),
    initial_traits => [ Interactive->new() ]
);

$world->add_entity($bob);

my $tree_body = Body->new(height => 10, width => 10, depth => 3);

my $tree = Entity->new(
    id => 'tree',
    initial_traits => [
        $tree_body,
        Named->new(name => 'a tree'),
        Position->new(position => [5,5,0]),
        Visible->new(
            description => 'It is full of leaves, that move in the wind.'),
        Growth->new(
            max => Game::Domain::Body->new(height => 12.3, width => 8, depth => 8),
            increment => 0.01,
            body_trait => $tree_body,
        ),
    ]);

$world->add_entity($tree);

my $cat = Entity->new(
    id => 'cat',
    initial_traits => [
        Body->new(height => 1, width => 1, depth => 1),
        Named->new(name => 'the Cheshire cat'),
        Position->new(position => [6,6,6]),
        Visible->new(
            visible => false,
            description => 'The cat smiles, but nobody can see it.'),
        Sight->new(distance => 5),
    ]);

$world->add_entity($cat);

$SIG{INT} = sub {
    say "Quitting.";
    $stop_me = true
};

my $loop = 0;

until($stop_me || $world->should_quit())
{
    $bob->do('look_around');
    $world->update($loop++);
}

1;
