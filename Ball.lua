require('modules.Vector2D')
require('modules.FixedFloat')

-- initialization
Ball = {}
Ball.__index = Ball
function Ball.new(x, y, radius, velocity, dir, color, UID)
    local self = setmetatable({
        npos = Vector2D.new(x, y),
        pos = Vector2D.new(x - velocity * math.cos(dir), y - velocity * math.sin(dir)),
        gpos = Vector2D.new(math.floor(x / CELLS_SIZE), math.floor(y / CELLS_SIZE)),
        acceleration = Vector2D.new(0, 0),
        radius = radius,
        color = color,
        UID = UID
    }, Ball)
    -- update new localization
    BALLS_LOCALIZATION[table.concat(self.gpos:toArray(), ';')][self.UID] = self
    return self
end

-- getters
function Ball:getPos() return self.pos:toTable() end

-- physics
function Ball:applyVerletIntegration(dt)
    -- Verlet integration
    local vel = self.npos - self.pos
    self.pos = self.npos
    self.npos = self.npos + vel + self.acceleration * dt * dt
    -- reset acceleration and apply gravity
    self.acceleration = Vector2D.new(0, 1000)
end

function Ball:applyConstraint()
    -- check distance from center
    local vec_from_center = self.npos - CENTER
    local dist_from_center = vec_from_center:len()
    local correction_radius = AREA_RADIUS - self.radius
    if dist_from_center > correction_radius then
        -- out of range, pull it back
        self.npos = vec_from_center:normalize() * correction_radius + CENTER
    end
end

function Ball:updateLocalization()
    -- update with new localization
    local new_gpos_x = math.floor((self.npos.x / CELLS_SIZE):toFloat())
    local new_gpos_y = math.floor((self.npos.y / CELLS_SIZE):toFloat())
    -- if same localization, exit early
    if new_gpos_x == self.gpos.x and new_gpos_y == self.gpos.y then return end
    -- remove old localization and add new
    BALLS_LOCALIZATION[table.concat(self.gpos:toArray(), ';')][self.UID] = nil
    BALLS_LOCALIZATION[new_gpos_x .. ';' .. new_gpos_y][self.UID] = self
    self.gpos = Vector2D.new(new_gpos_x, new_gpos_y)
end

function Ball:applyGridCollisions()
    local gpos = self.gpos:toTable()
    for i = -1, 1 do
        for j = -1, 1 do
            local grid = BALLS_LOCALIZATION[gpos.x + i .. ';' .. gpos.y + j]
            if grid then
                for _, other in pairs(grid) do
                    if other ~= self then
                        local vec_from_other = self.npos - other.npos
                        local radius = other.radius + self.radius
                        if vec_from_other:len() < radius then
                            local correction = vec_from_other:normalize() * (radius - vec_from_other:len()) / 2
                            self.npos = self.npos + correction
                            other.npos = other.npos - correction
                        end
                    end
                end
            end
        end
    end
end
