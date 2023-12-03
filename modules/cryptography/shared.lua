zlib.cryptography = {}


local MOD = 2^32

local function memoize(f)
  local mt = {}
  local t = setmetatable({}, mt)
  function mt:__index(k)
    local v = f(k); t[k] = v
    return v
  end
  return t
end

local function make_bitop_uncached(t, m)
  local function bitop(a, b)
    local res,p = 0,1
    while a ~= 0 and b ~= 0 do
      local am, bm = a%m, b%m
      res = res + t[am][bm]*p
      a = (a - am) / m
      b = (b - bm) / m
      p = p*m
    end
    res = res + (a+b)*p
    return res
  end
  return bitop
end

local function make_bitop(t)
  local op1 = make_bitop_uncached(t,2^1)
  local op2 = memoize(function(a)
    return memoize(function(b)
      return op1(a, b)
    end)
  end)
  return make_bitop_uncached(op2, 2^(t.n or 1))
end

local bxor = make_bitop {[0]={[0]=0,[1]=1},[1]={[0]=1,[1]=0}, n=4}

local function bit32_bxor(a, b, c, ...)
    local z
    if b then
        a = a % MOD
        b = b % MOD
        z = bxor(a, b)
        if c then
        z = bit32_bxor(z, c, ...)
        end
        return z
    elseif a then
        return a % MOD
    else
        return 0
    end
end

local insert, concat = table.insert, table.concat
local char = string.char
local key = 34

local function xor_cipher(arg)
  local ret = {}
  for c in arg:gmatch('.') do
    insert(ret, char(bit32_bxor(c:byte(), key)))
  end
  return concat(ret)
end

function zlib.cryptography.xor_encrypt(arg)
  local input_type = type(arg)

  if input_type == "number" then
    return xor_cipher(tostring(arg) .. "3")
  elseif input_type == "string" then
    return xor_cipher(arg .. "4")
  end
end

function zlib.cryptography.xor_decrypt(arg)
  local encrypted_type_flag = string.sub(arg, -1)

  if encrypted_type_flag == "3" then
    return tonumber(xor_cipher(arg:sub(1, -2)))
  elseif encrypted_type_flag == "4" then
    return xor_cipher(arg:sub(1, -2))
  end
end

return zlib.cryptography