local precision = 10e6

FixedFloat = {}
FixedFloat.__index = FixedFloat

function FixedFloat.new(value, fixed)
    if fixed then
        return setmetatable({ value = math.floor(value + 0.5) }, FixedFloat)
    else
        return setmetatable({ value = math.floor(value * precision + 0.5) }, FixedFloat)
    end
end

function FixedFloat.__add(a, b)
    return FixedFloat.new(a.value + b.value, true)
end

function FixedFloat.__sub(a, b)
    return FixedFloat.new(a.value - b.value, true)
end

function FixedFloat.__mul(a, b)
    return FixedFloat.new(a.value * (type(b) == "number" and b * precision or b.value) / precision, true)
end

function FixedFloat.__div(a, b)
    return FixedFloat.new(a.value / (type(b) == "number" and b * precision or b.value) * precision, true)
end

function FixedFloat.__tostring(a)
    return tostring(a.value / precision)
end

function FixedFloat:toFloat()
    return self.value / precision
end
