## A proposal for component architecture in Perl ##

This is my take to avoid the usual pitfalls that class/inheritance based architectures pose. 

Large inheritance trees become difficult to maintain and also the their inversion by the roles/traits concept becomes a burden, as traits aren't easily given or removed. It is sometimes difficult to plug extensions in the middle, without affecting toop much and thus creating new trees. This leads to very static objects that provide more than is necessary in the given situation and are unable to be extended during runtime.

This project proposes a differnt structure.

Here, objects are little more than an id to which diverse properties can be attached (and taken away). Traits, then provide abilities, which can be accessed by the object.

So, the typical animal -> cat relation could be described like this (not code):

```
  entity animal
    trait body => weight, size, can be composed of other traits
    trait sight => look_around, look_at
    trait mobile => move(dir), ...
    trait metabolize => eat, ...
    trait live => grow, die, decompose, ...
    ...

  animal->do(look_around) => "the animal can't see anything because it's night"
```
Now, we want this animal to become a cat
```
  animal->add_trait(cat::voice)
  animal->add_trait(night_sight)
  ...

  animal->do(look_around) => "there is a mouse!"
```
Some traits require others to work, but their relationship is always simple and always component-like.
For example, for an object to move, it needs a position. However this relation is true for every object which moves.
So few complex hierarchies are necessary. From what I see, there is a tendency for very fine grained traits that take care of only one aspect and little interdependcy.

This is Perl, because that's what I spend most time with, currently, however what I am learning holds true for most languages. 
