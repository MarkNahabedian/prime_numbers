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
"""
function upto(s::Sieve, candidate::Int)
  while (s.next_multiple + s.prime) <= candidate
    s.multiplier += 1
    s.next_multiple += s.prime
  end
  return s.next_multiple == candidate
end


"""find_primes continues the search for prime numbers using the Sieves
provided, appending to sieves as primes are found.
Any primes that are less than first_candidate should already be included
in sieves.
Returns after the integer stop_after has been considered.
"""
function find_primes(sieves::Vector{Sieve}, first_candidate::Int, stop_after::Int)
  println("find_primes ", first_candidate, " ", stop_after)
  candidate = first_candidate
  while candidate <= stop_after
    factored = false
    for s in sieves
      if upto(s, candidate)
        factored = true  
        break
      end
    end
    if !factored
      push!(sieves, Sieve(candidate))
    end
    candidate += 1
  end
end


"""load_sieves reads prime nummbers from the specified file and adds them to sieves.
It is assumed that the contents of the file is a decimal representation of a complete
set of prime numbers up to some number."""
function load_sieves(sieves::Vector{Sieve}, filepath::String)
  local f = nothing
  try
    f = open(filepath, read = true)
    for line in eachline(f)
      n = parse(Int, line)
      push!(sieves, Sieve(n))
    end
  catch ex
    if !isa(ex, SystemError)
      rethrow(ex)
    end
  finally
    if f != nothing
      close(f)
    end
  end
end


"""find_and_save_primes searches for prime numbers, appending them to
filepath as they are found.
"""
function find_and_save_primes(filepath::String)
  sieves = Sieve[]
  load_sieves(sieves, filepath)
  
  # Start with 1 more than the biggest prime already found
  local candidate::Int
  local last_saved_index::Int = 0
  if length(sieves) > 0
    candidate = sieves[length(sieves)].prime + 1
  else
    # Never consider 1
    candidate = 2
  end

  last_saved_index = length(sieves)

  function checkpoint()
    f = open(filepath, append = true, create = true)
    while true
      if last_saved_index >= length(sieves)
        break
      end
      last_saved_index += 1
      println(f, sieves[last_saved_index].prime)
    end
    close(f)
  end

  batch = 100
  try
    while true
      stop_after = candidate + batch
      find_primes(sieves, candidate, stop_after)
      checkpoint()
      candidate = stop_after + 1
    end
  catch ex
    if isa(ex, InterruptException)
      f = open("sieve-primes", write = true, truncate = true, create = true)
        for s in sieves
          println(f, s.prime)
        end
      close(f)
    end
  end
end


# Enable catching of keyboard interrupts when not in the REPL:
ccall(:jl_exit_on_sigint, Nothing, (Cint,), 0)


find_and_save_primes("PRIMES")

