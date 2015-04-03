-- Useful function for numbers! -- by Edii Knorand

local NUMBER = {}

-- Util
local function is_integer(x)
  return math.ceil(x) == x
end

local function log_base(x, b)
  return math.log(x)/math.log(b)
end

-- API
NUMBER.inv_mod = function(a,n)
  local t,r,newt,newr = 0,n,1,a
  while newr ~= 0 do
    local quo = math.floor(r/newr)
    t,newt = newt,(t-quo*newt)
    r,newr = newr,(r-quo*newr)
  end
  if r > 1 then
    return nil
  end
  if t < 0 then
    t = t + n
  end
  return t
 end


NUMBER.gcd = function(a,b)
  if not(type(a) == 'number' and type(b) == 'number') or not(is_integer(a) and is_integer(b))  then
    return nil
  end
  local d = 0
  while a%2 == 0 and b%2 == 0 do
    a = math.floor(a/2)
    b = math.floor(b/2)
    d = d + 1
  end
  while a ~= b do
    if a%2 == 0 then
      a = math.floor(a/2)
    elseif b%2 == 0 then
      b = math.floor(b/2)
    elseif a > b then
      a = math.floor((a-b)/2)
    else
      b = math.floor((b-a)/2)
    end
  end
  return a * 2^d
end

NUMBER.isPrime = function(n)
  if type(n) ~= 'number' or not is_integer(n) then
    return false
  end
  if n <= 3 then
    return n > 1
  end
  if n%2 == 0 or n%3 == 0 then
    return false
  end
  for i = 5, math.sqrt(n), 6 do
    if n%i == 0 or n%(i+2) == 0 then
      return false
    end
  end
  return true
end

return NUMBER

