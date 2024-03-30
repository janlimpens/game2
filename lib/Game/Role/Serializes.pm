use v5.38;

use Object::Pad;

role Game::Role::Serializes
{
    method serialize();
    method deserialize($data);
}
