use v5.38;
use local::lib;
use Object::Pad;
use lib qw(lib);

class Game::Trait::Visible;

no warnings qw(experimental::builtin experimental::for_list);
use builtin qw(true false);
use feature qw(say);
use Data::Printer;

field $my_description :param(description)='';
field $visible :param=1;

method description :common ($name='An entity with this trait')
{
    return "$name can define its visibility. Visible things have a description"
}

method stringify()
{
    return sprintf "Visible ($visible)";
}

method update($entity, $iteration)
{
    return
}

apply Game::Role::Trait;

ADJUST
{
    my %abilities = (
        get_description => method($entity) {
            return $my_description
        },
        is_visible => method($entity) {
            return $visible
        },
        toggle_visible => method($entity) {
            $visible = !$visible;
            $self->is_dirty(true);
            return $visible
        },
        get_random_fact => method($entity)
        {
            my $name = $entity->do('get_pronouns')
                // $entity->do('get_name')
                // $entity->id();

            my %factoids = (
                height => sub($entity) {
                    my $height = $entity->do('get_height');
                    return false unless $height;
                    return "$name stands $height units tall.";
                },
                width => sub($entity) {
                    my $width = $entity->do('get_width');
                    return false unless $width;
                    return "$name has a width of $width.";
                },
                depth => sub($entity) {
                    my $depth = $entity->do('get_depth');
                    return false unless $depth;
                    return "$name has a depth of $depth.";
                },
                volume => sub($entity) {
                    my $volume = $entity->do('get_volume');
                    return false unless $volume;
                    return "$name has a volume of $volume.";
                },
            );

            my ($factoid) = keys %factoids;

            return $factoids{$factoid}->($entity);
        },
    );

    for my ($ability, $method) (%abilities)
    {
        $self->add_ability($ability, $method);
    };
}

1;
