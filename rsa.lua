-- Simple RSA algorithm in Lua - by Edii Knorand
--
--  RSA.keygen returns, respectively, modulus n, public key exponent, private key exponent
--
--  Usage example:
--    
--    local RSA = require('rsa')
--    local modulus,public,private = RSA.keygen()
--    local input = 42
--    assert(RSA.crypt(RSA.crypt(input, public, modulus), private, modulus) == input)
--

local RSA = {}

local NUMBER = require('number')

local function primegen(n0, nf, seed)
  if seed then
    math.randomseed(seed)
  end
  local n = math.random(n0, nf)
  while not NUMBER.isPrime(n) do
    n = math.random(n0, nf)
  end
  return n
end

RSA.keygen = function(safe)
  safe = safe or 3
  local s_min,s_max = 2^safe+1, 2^(2*safe)+1
  local p,q = primegen(s_min, s_max, os.time()),primegen(s_min, s_max)
  local n = p*q

  local t_n = (p-1)*(q-1)
  local e = math.random(2, t_n)
  while NUMBER.gcd(e,t_n) ~= 1 do
    e = math.random(2, t_n)
  end
  d = NUMBER.inv_mod(e, t_n)
  return n,e,d
end

RSA.crypt = function(m, e, n)
  local c = 1
  for i=1,e do
    c = (c*m)%n
  end
  return c
end

return RSA
