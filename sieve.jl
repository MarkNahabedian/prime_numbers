# Find prime numbers using an unbounded Sieve of Eratosthenes approach.


MyInteger = Int64    # change to BigInt when we overflow


"""Sieve represents a single prime number in a 'Sieve of Eratosthenes'."""
mutable struct Sieve
  prime::MyInteger
  next_multiple::MyInteger
  multiplier::MyInteger
  function Sieve(prime::MyInteger)
    new(prime, prime, 1)
  end
end


"""upto advances the Sieve s to the greatest next_multiple that is
less than or equal to candidate.
Returns true if that next_multiple is equal to candidate.
"""
function upto(s::Sieve, candidate::MyInteger)
  while true
    next = s.next_multiple + s.prime
    if next < s.next_multiple
      error("Integer arithmetic wraparound", MyInteger)
    end
    if next > candidate
      break
    end
    s.multiplier += 1
    s.next_multiple = next
  end
  return s.next_multiple == candidate
end


"""find_primes continues the search for prime numbers using the Sieves
provided, appending to sieves as primes are found.
Any primes that are less than first_candidate should already be included
in sieves.
Returns after the integer stop_after has been considered.
"""
function find_primes(sieves::Vector{Sieve}, first_candidate::MyInteger, stop_after::MyInteger)
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
      n = parse(MyInteger, line)
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
function find_and_save_primes(filepath::String, progresspath::String)
  sieves = Sieve[]
  load_sieves(sieves, filepath)
  
  # Start with 1 more than the biggest prime already found
  local candidate::MyInteger
  local last_saved_index::MyInteger = 0
  if length(sieves) > 0
    candidate = sieves[length(sieves)].prime + 1
  else
    # Never consider 1
    candidate = 2
  end

  last_saved_index = length(sieves)

  function checkpoint()
    # Save primes
    open(filepath, append = true, create = true) do f
      while true
        if last_saved_index >= length(sieves)
          break
        end
        last_saved_index += 1
        println(f, sieves[last_saved_index].prime)
      end
    end
    # Update progress:
    open(progresspath, "w") do f
      println(f, "$(length(sieves)) primes found")
      println(f, "largest so far: $(sieves[end].prime)")
    end
  end

  batch = 1000
  while true
    stop_after = candidate + batch
    try
        find_primes(sieves, candidate, stop_after)
    catch e
        checkpoint()
        println("\nCheckpointed after exception")
        if !isa(e, InterruptException)
           rethrow()
        end
        return
    end
    checkpoint()
    candidate = stop_after + 1
  end
end


# Allow handling of keyboard interrupt.
ccall(:jl_exit_on_sigint, Nothing, (Cint,), 0)


find_and_save_primes("PRIMES", "PROGRESS")

