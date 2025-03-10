require("modules.FixedFloat")

Vector2D = {}
Vector2D.__index = Vector2D


function Vector2D.new(x, y)
    local isNumber = type(x) == 'number'
    return setmetatable({
        x = isNumber and FixedFloat.new(x, false) or x,
        y = isNumber and FixedFloat.new(y, false) or y
    }, Vector2D)
end

function Vector2D.__add(a, b)
    return Vector2D.new(a.x + b.x, a.y + b.y)
end

function Vector2D.__sub(a, b)
    return Vector2D.new(a.x - b.x, a.y - b.y)
end

function Vector2D.__mul(a, b)
    return Vector2D.new(a.x * b, a.y * b)
end

function Vector2D.__div(a, b)
    return Vector2D.new(a.x / b, a.y / b)
end

function Vector2D:len()
    return math.sqrt((self.x * self.x + self.y * self.y):toFloat())
end

function Vector2D:normalize()
    local len = self:len()
    if len < 0.01 then
        return Vector2D.new(1, 0) -- Return a default vector if the length is near zero
    end
    return Vector2D.new(self.x / len, self.y / len)
end

function Vector2D.__tostring(a)
    return table.concat({ "{", tostring(a.x), ",", tostring(a.y), "}" }, " ")
end

function Vector2D:toTable()
    return { x = self.x:toFloat(), y = self.y:toFloat() }
end

function Vector2D:toArray()
    return { self.x:toFloat(), self.y:toFloat() }
end
