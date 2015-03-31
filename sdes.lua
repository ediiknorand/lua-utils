-- SDES (8 bits) - for Lua 5.1 - Implemented by Edii Knorand
-- 
-- Usage example:
--   local SDES = require('sdes')
--   local key = 0xf33 (10-bits key)
--   local input = 255 (8-bits input)
--   assert(SDES.decrypt(SDES.encrypt(input, key), key) == input)
--
--

local BIT = require('bit') -- luanumber module for bitwise operators (by David Manura)
                           -- (From https://github.com/davidm/lua-bit-numberlua/blob/master/lmod/bit/numberlua.lua)

local s0_matrix =
 { 1, 0, 3, 2,
   3, 2, 1, 0,
   0, 2, 1, 3,
   3, 1, 3, 2 }

local s1_matrix =
 { 0, 1, 2, 3,
   2, 0, 1, 3,
   3, 0, 1, 0,
   2, 1, 0, 3 }

local function bit_mv(input, mask, offset)
  if offset > 0 then
    return BIT.lshift(BIT.band(input, mask), offset)
  elseif offset < 0 then
    return BIT.rshift(BIT.band(input, mask), -offset)
  end
  return BIT.band(input, mask)
end

local function sdes_ip(input)
  local output = 0x0
  output = BIT.bor(output, bit_mv(input, 0x80, -3))
  output = BIT.bor(output, bit_mv(input, 0x40,  1))
  output = BIT.bor(output, bit_mv(input, 0x20,  0))
  output = BIT.bor(output, bit_mv(input, 0x10, -1))
  output = BIT.bor(output, bit_mv(input, 0x08, -2))
  output = BIT.bor(output, bit_mv(input, 0x04,  4))
  output = BIT.bor(output, bit_mv(input, 0x02, -1))
  output = BIT.bor(output, bit_mv(input, 0x01,  2))
  return output
end

local function sdes_rip(input)
  local output = 0x0
  output = BIT.bor(output, bit_mv(input, 0x10,  3))
  output = BIT.bor(output, bit_mv(input, 0x80, -1))
  output = BIT.bor(output, bit_mv(input, 0x20,  0))
  output = BIT.bor(output, bit_mv(input, 0x08,  1))
  output = BIT.bor(output, bit_mv(input, 0x02,  2))
  output = BIT.bor(output, bit_mv(input, 0x40, -4))
  output = BIT.bor(output, bit_mv(input, 0x01,  1))
  output = BIT.bor(output, bit_mv(input, 0x04, -2))
  return output
end

local function sdes_ep(input)
  local output = 0x0
  output = BIT.bor(output, bit_mv(input, 0x0e,  3))
  output = BIT.bor(output, bit_mv(input, 0x07,  1))
  output = BIT.bor(output, bit_mv(input, 0x08, -3))
  output = BIT.bor(output, bit_mv(input, 0x01,  1))
  output = BIT.bor(output, bit_mv(input, 0x01,  7))
  return output
end

local function sdes_s0(input)
  local r = 0x0
  local c = bit_mv(input, 0x6, -1)
  r = BIT.bor(r, bit_mv(input, 0x8, -2))
  r = BIT.bor(r, bit_mv(input, 0x1,  0))
  return s0_matrix[c + 4*r + 1]
end

local function sdes_s1(input)
  local r = 0x0
  local c = bit_mv(input, 0x6, -1)
  r = BIT.bor(r, bit_mv(input, 0x8, -2))
  r = BIT.bor(r, bit_mv(input, 0x1,  0))
  return s1_matrix[c + 4*r + 1]
end

local function sdes_p4(input0, input1)
  local output = 0x0
  output = BIT.bor(output, bit_mv(input0, 0x2, -1))
  output = BIT.bor(output, bit_mv(input0, 0x1,  3))
  output = BIT.bor(output, bit_mv(input1, 0x2,  0))
  output = BIT.bor(output, bit_mv(input1, 0x1,  2))
  return output
end

local function sdes_p8(input0, input1)
  local output = 0x0
  output = BIT.bor(output, bit_mv(input0, 0x04,  4))
  output = BIT.bor(output, bit_mv(input0, 0x02,  3))
  output = BIT.bor(output, bit_mv(input0, 0x01,  2))

  output = BIT.bor(output, bit_mv(input1, 0x10,  3))
  output = BIT.bor(output, bit_mv(input1, 0x08,  2))
  output = BIT.bor(output, bit_mv(input1, 0x04,  1))

  output = BIT.bor(output, bit_mv(input1, 0x02, -1))
  output = BIT.bor(output, bit_mv(input1, 0x01,  1))

  return output
end

local function sdes_p10(input)
  local output = 0x0
  output = BIT.bor(output, bit_mv(input, 0x200, -6))
  output = BIT.bor(output, bit_mv(input, 0x100, -1))
  output = BIT.bor(output, bit_mv(input, 0x080,  2))
  output = BIT.bor(output, bit_mv(input, 0x040, -1))
  output = BIT.bor(output, bit_mv(input, 0x020,  3))
  output = BIT.bor(output, bit_mv(input, 0x010, -4))
  output = BIT.bor(output, bit_mv(input, 0x008,  3))
  output = BIT.bor(output, bit_mv(input, 0x004, -1))
  output = BIT.bor(output, bit_mv(input, 0x002,  1))
  output = BIT.bor(output, bit_mv(input, 0x001,  4))
  return output
end

local function sdes_ls1(input)
  local output = 0x0
  output = BIT.bor(output, bit_mv(input, 0x1e0,  1))
  output = BIT.bor(output, bit_mv(input, 0x200, -4))
  output = BIT.bor(output, bit_mv(input, 0x00f,  1))
  output = BIT.bor(output, bit_mv(input, 0x010, -4))
  return output
end

local function sdes_ls2(input)
  local output = 0x0
  output = BIT.bor(output, bit_mv(input, 0x0e0,  2))
  output = BIT.bor(output, bit_mv(input, 0x300, -3))
  output = BIT.bor(output, bit_mv(input, 0x007,  2))
  output = BIT.bor(output, bit_mv(input, 0x018, -3))
  return output
end

local function sdes_key1(input)
  local k = sdes_ls1(sdes_p10(input))
  return sdes_p8(bit_mv(k, 0x3e0, -5), bit_mv(k, 0x1f, 0))
end

local function sdes_key2(input)
  local k = sdes_ls2(sdes_p10(input))
  return sdes_p8(bit_mv(k, 0x3e0, -5), bit_mv(k, 0x1f, 0))
end

-- API
local SDES = {}

SDES.encrypt = function(input, key)
  if not (input and key) then
    return nil
  end

  local l,r,m
  m = sdes_ip(input)
  l = bit_mv(m, 0xf0, -4)
  r = bit_mv(m, 0x0f,  0)

  m = BIT.bxor(sdes_ep(r), sdes_key1(key))
  m = BIT.bxor(sdes_p4( sdes_s0(bit_mv(m, 0xf0, -4)), sdes_s1(bit_mv(m, 0x0f, 0))), l)

  l = r
  r = m

  m = BIT.bxor(sdes_ep(r), sdes_key2(key))
  m = BIT.bxor(sdes_p4( sdes_s0(bit_mv(m, 0xf0, -4)), sdes_s1(bit_mv(m, 0x0f, 0))), l)
  l = m
  return sdes_rip(BIT.bor(bit_mv(l, 0x0f, 4), bit_mv(r, 0x0f, 0)))
end

SDES.decrypt = function(input, key)
  if not (input and key) then
    return nil
  end

  local l,r,m
  m = sdes_ip(input)
  l = bit_mv(m, 0xf0, -4)
  r = bit_mv(m, 0x0f,  0)

  m = BIT.bxor(sdes_ep(r), sdes_key2(key))
  m = BIT.bxor(sdes_p4( sdes_s0(bit_mv(m, 0xf0, -4)), sdes_s1(bit_mv(m, 0x0f, 0))), l)

  l = r
  r = m

  m = BIT.bxor(sdes_ep(r), sdes_key1(key))
  m = BIT.bxor(sdes_p4( sdes_s0(bit_mv(m, 0xf0, -4)), sdes_s1(bit_mv(m, 0x0f, 0))), l)
  l = m
  return sdes_rip(BIT.bor(bit_mv(l, 0x0f, 4), bit_mv(r, 0x0f, 0)))
end

return SDES
