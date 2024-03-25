## A proposal for component architecture in Perl ##

This is my take to avoid the usual pitfalls that class/inheritance based
architectures pose.

Classes are a bad abstraction of reality. Things change, classes don't. The
cannot acquire new abilities and for a good reason, objects are being **cast**
to classes. One you belong to a certain class it is impossible to get out of it
without losing your identity.

Large inheritance trees become difficult to maintain and also the their inversion by the roles/traits concept becomes a burden, as traits aren't easily given or removed. It is sometimes difficult to plug extensions in the middle, without affecting too much and thus creating new trees. This leads to very static objects that provide more than is necessary in the given situation and are unable to be extended during runtime.

This project proposes a different structure: a classless paradigm.

Here, objects are little more than an id to which diverse properties can be
attached (and taken away). Traits, then provide abilities (behavior) and
properties (data), which the object can make use of.

So, the typical animal -> cat relation could be described like this (easier to
read pseudo script language, not actual code):

```
  entity animal
    trait body => weight, size, can be composed of other traits
    trait sight => look_around, look_at
    trait mobile => move(dir), ...
    trait metabolize => eat, ...
    trait live => grow, die, decompose, ...
    ...

  animal->do(look_around) => "I can't see anything because it's night and my eyesight won't permit it."
```
Now, we want for this animal to become a cat:
```
  animal->add_trait(cat::voice)
  animal->add_trait(night_sight)

  animal->do(say_hello) => "Miaou!"
  animal->do(look_around) => "There is a mouse!"
```
Some traits require others to work, yet their relationship remains simple and component-like.
For example, for an object to move, it needs a position. However this relation is true for every object which moves.
So few complex hierarchies are necessary. From what I see, there is a tendency
for very fine grained traits, which take care of only one aspect and possess little
interdependency.

This is Perl, because that's what I spend most time with, currently, however
what I am learning, must hold true for most languages. Due to the primitive
dispatching mechanism, game2 uses, a flexible enough script language is a
logical choice, and so far, I cannot complain about speed. Of course, I wouldn't
write a device driver in it.

Cheers,

-Jan