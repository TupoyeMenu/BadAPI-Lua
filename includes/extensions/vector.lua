-- Adds basic math operations for vec3
--#region vec3

---@param arg any
---@return boolean
function vec3:assert(arg)
    if (type(arg) == "table") or (type(arg) == "userdata") and type(arg.x) == "number" and type(arg.y) == "number" and type(arg.z) == "number" then
        return true
    else
        error(
            string.format("Invalid argument. Expected 3D vector, got %s instead", type(arg))
        )
    end
end

---@param b number|vec3
---@return vec3
function vec3:__add(b)
    if type(b) == "number" then
        return vec3:new(self.x + b, self.y + b, self.z + b)
    end

    self:assert(b)
    return vec3:new(self.x + b.x, self.y + b.y, self.z + b.z)
end

---@param b number|vec3
---@return vec3
function vec3:__sub(b)
    if type(b) == "number" then
        return vec3:new(self.x - b, self.y - b, self.z - b)
    end

    self:assert(b)
    return vec3:new(self.x - b.x, self.y - b.y, self.z - b.z)
end

---@param b number|vec3
---@return vec3
function vec3:__mul(b)
    if type(b) == "number" then
        return vec3:new(self.x * b, self.y * b, self.z * b)
    end

    self:assert(b)
    return vec3:new(self.x * b.x, self.y * b.y, self.z * b.z)
end

---@param b number|vec3
---@return vec3
function vec3:__div(b)
    if type(b) == "number" then
        return vec3:new(self.x / b, self.y / b, self.z / b)
    end

    self:assert(b)
    return vec3:new(self.x / b.x, self.y / b.y, self.z / b.z)
end

---@param b number|vec3
---@return boolean
function vec3:__eq(b)
    self:assert(b)
    return self.x == b.x and self.y == b.y and self.z == b.z
end

---@param b number|vec3
---@return boolean
function vec3:__lt(b)
    self:assert(b)
    return self.x < b.x and self.y < b.y and self.z < b.z
end

---@param b number|vec3
---@return boolean
function vec3:__le(b)
    self:assert(b)
    return self.x <= b.x and self.y <= b.y and self.z <= b.z
end

---@return vec3
function vec3:__unm()
    return vec3:new(-self.x, -self.y, -self.z)
end

---@return number
function vec3:length()
    return math.sqrt(self.x ^ 2 + self.y ^ 2 + self.z ^ 2)
end

---@param b vec3
---@return number
function vec3:distance(b)
    self:assert(b)
    local dist_x = (self.x - b.x) ^ 2
    local dist_y = (self.y - b.y) ^ 2
    local dist_z = (self.z - b.z) ^ 2

    return math.sqrt(dist_x + dist_y + dist_z)
end

---@return vec3
function vec3:normalize()
    local len = self:length()

    if len < 1e-8 then
        return vec3.zero()
    end

    return self / len
end

---@param b vec3
---@return vec3
function vec3:cross_product(b)
    self:assert(b)

    return vec3:new(
        self.y * b.z - self.z * b.y,
        self.z * b.x - self.x * b.z,
        self.x * b.y - self.y * b.x
    )
end

---@param b vec3
---@return number
function vec3:dot_product(b)
    self:assert(b)
    return self.x * b.x + self.y * b.y + self.z * b.z
end

---@param to vec3
---@param dt number Delta time
---@return vec3
function vec3:lerp(to, dt)
    return vec3:new(
        self.x + (to.x - self.x) * dt,
        self.y + (to.y - self.y) * dt,
        self.z + (to.z - self.z) * dt
    )
end

---@param includeZ? boolean
---@return vec3
function vec3:inverse(includeZ)
    return vec3:new(-self.x, -self.y, includeZ and -self.z or self.z)
end

function vec3:trim(atLength)
    local len = self:length()
    if len == 0 then
        return vec3.zero()
    end

    local s = atLength / len
    s = (s > 1) and 1 or s
    return self * s
end

---@return vec3
function vec3:copy()
    return vec3:new(self.x, self.y, self.z)
end

---@return float, float, float
function vec3:unpack()
    return self.x, self.y, self.z
end

---@return boolean
function vec3:is_zero()
    return (self.x == 0) and (self.y == 0) and (self.z == 0)
end

function vec3:heading()
    return math.atan(self.y, self.x)
end

---@param z float
function vec3:with_z(z)
    return vec3:new(self.x, self.y, z)
end

---@return vec2
function vec3:as_vec2()
    return vec2:new(self.x, self.y)
end

--
-- static
--

---@return vec3
function vec3.zero()
    return vec3:new(0, 0, 0)
end

--#endregion vec3


--#region vec2

---@class vec2
---@field x number
---@field y number
vec2 = {}
vec2.__index = vec2

-- Constructor
---@param x number?
---@param y number?
---@return vec2
function vec2:new(x, y)
	assert(type(x) == "number" and type(y) == "number")

	return setmetatable({
		x = x,
		y = y,
	},
    self)
end

---@param arg any
---@return boolean
function vec2:assert(arg)
    if (type(arg) == "table" or type(arg) == "userdata") and type(arg.x) == "number" and type(arg.y) == "number" then
        return true
    else
        error(
            string.format("Invalid argument! Expected 2D vector, got %s instead", type(arg))
        )
    end
end

function vec2:__tostring()
    return string.format(
        "(%.3f, %.3f)",
        self.x,
        self.y
    )
end

---@param b number|vec2
---@return vec2
function vec2:__add(b)
    if type(b) == "number" then
        return vec2:new(self.x + b, self.y + b)
    end

    self:assert(b)
    return vec2:new(self.x + b.x, self.y + b.y)
end

---@param b number|vec2
---@return vec2
function vec2:__sub(b)
    if type(b) == "number" then
        return vec2:new(self.x - b, self.y - b)
    end

    self:assert(b)
    return vec2:new(self.x - b.x, self.y - b.y)
end

---@param b number|vec2
---@return vec2
function vec2:__mul(b)
    if type(b) == "number" then
        return vec2:new(self.x * b, self.y * b)
    end

    self:assert(b)
    return vec2:new(self.x * b.x, self.y * b.y)
end

---@param b number|vec2
---@return vec2
function vec2:__div(b)
    if type(b) == "number" then
        return vec2:new(self.x / b, self.y / b)
    end

    self:assert(b)
    return vec2:new(self.x / b.x, self.y / b.y)
end

---@param b number|vec2
---@return boolean
function vec2:__eq(b)
    self:assert(b)
    return self.x == b.x and self.y == b.y
end

---@param b number|vec2
---@return boolean
function vec2:__lt(b)
    self:assert(b)
    return self.x < b.x and self.y < b.y
end

---@param b number|vec2
---@return boolean
function vec2:__le(b)
    self:assert(b)
    return self.x <= b.x and self.y <= b.y
end

---@return vec2
function vec2:__unm()
    return vec2:new(-self.x, -self.y)
end

---@return float, float
function vec2:unpack()
    return self.x, self.y
end

---@return number
function vec2:length()
    return math.sqrt(self.x ^ 2 + self.y ^ 2)
end

---@param b vec2
---@return number
function vec2:distance(b)
    self:assert(b)

    local dist_x = (self.x - b.x) ^ 2
    local dist_y = (self.y - b.y) ^ 2

    return math.sqrt(dist_x + dist_y)
end

---@return number
function vec2:cross_product(b)
    self:assert(b)
    return self.x * b.y - self.y * b.x
end

---@return number
function vec2:dot_product(b)
    self:assert(b)
    return self.x * b.x + self.y * b.y
end

---@return vec2
function vec2:normalize()
    local len = self:length()

    if len < 1e-8 then
        return vec2:new(0, 0)
    end

    return self / len
end

---@return vec2
function vec2:inverse()
    return self:__unm()
end

---@return vec2
function vec2:copy()
    return vec2:new(self.x, self.y)
end

---@return boolean
function vec2:is_zero()
    return (self.x == 0) and (self.y == 0)
end

---@return vec2
function vec2:perpendicular()
    return vec2:new(-self.y, self.x)
end

---@return number
function vec2:angle()
    return math.atan(self.y, self.x)
end

---@param b vec2
---@param dt number Delta time
---@return vec2
function vec2:lerp(b, dt)
    return vec2:new(
        self.x + (b.x - self.x) * dt,
        self.y + (b.y - self.y) * dt
    )
end

---@param n number
---@return vec2
function vec2:rotate(n)
    local a, b = math.cos(n), math.sin(n)

    return vec2:new(
        a * self.x - b * self.y,
        b * self.x + a * self.y
    )
end

---@param atLength number
---@return vec2
function vec2:trim(atLength)
    local len = self:length()

    if (len == 0) then
        return vec2.zero()
    end

    local s = atLength / len

    s = (s > 1) and 1 or s
    return self * s
end

---@return number, number
function vec2:to_polar()
    return math.atan(self.y, self.x), self:length()
end

--
-- static
--

---@return vec2
function vec2.zero()
    return vec2:new(0, 0)
end

---@param angle number
---@param radius? number
---@return vec2
function vec2.from_polar(angle, radius)
    radius = radius or 1
    return vec2:new(math.cos(angle) * radius, math.sin(angle) * radius)
end

--#endregion
