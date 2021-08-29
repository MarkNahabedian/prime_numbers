# prime_numbers

This was my very first Julia program.

It finds prime numbers using an algorithm
that I think of as Inverted Sieve of Eratosthenes.

To use Sieve of Eratosthenes, one must first pick
an upper bound for the search.

The algorithm here has no upper bound.

What it does not deal with yet is arithmetic overflow.
Julia just wraps around on overflow.
It would be ideal if this program could do
it's arithmetic as Int for as long as possible
and then use BigInt once the numbers got too big.
Something to ponder.
