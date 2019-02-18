# Find prime numbers using an unbounded Sieve of Eratosthenes approach.


"""Sieve represents a single prime number in a 'Sieve of Eratosthenes'."""
mutable struct Sieve
  prime::Int
  next_multiple::Int
  multiplier::Int
  function Sieve(prime::Int)
    new(prime, prime, 1)
  end
end


"""upto advances the Sieve s to the greatest next_multiple that is
less than or equal to candidate.
Returns true if that next_multiple is equal to candidate.
Returns true if candidate is equal to that multiple."""
function upto(s::Sieve, candidate::Int)
  while (s.next_multiple + s.prime) <= candidate
    s.multiplier += 1
    s.next_multiple += s.prime
  end
  return s.next_multiple == candidate
end


"""find_primes continues the search for prime numbers using the Sieves
provided, appending to sieves as primes are found.
This function does not terminate."""
function find_primes(sieves::Vector{Sieve})
  # Start with 1 more than the biggest prime already found
  local candidate::Int
  if length(sieves) > 0
    candidate = sieves[length(sieves)].prime + 1
  else
    # Never consider 1
    candidate = 2
  end
  while true
    factored = false
    for s in sieves
      if upto(s, candidate)
        factored = true
        break
      end
    end
    if !factored
      println(candidate)
      push!(sieves, Sieve(candidate))
    end
    candidate += 1
  end
end


