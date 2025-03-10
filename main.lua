require('modules.Vector2D')
require("Ball")
require("data.data")

local CURRENT_ARTWORK = 0 -- default start at 0 but will be immediately incremented to 1
local ARTWORK_DATA, BALLS_COUNT, iters, balls
local COLOR_THEME = {
    { 0.05, 0.05, 0.05 },
    { 0.95, 0.95, 0.95 },
    { 0.8,  0.2,  0.2 },
    { 0.2,  0.8,  0.2 },
    { 0.2,  0.2,  0.8 },
    { 0.8,  0.8,  0.2 },
    { 0.2,  0.8,  0.8 },
    { 0.8,  0.2,  0.8 },
    { 0.8,  0.8,  0.8 }
}

DT = 1 / 60 -- DT is refresh rate
AREA_RADIUS = 384
CENTER = Vector2D.new(AREA_RADIUS, AREA_RADIUS)

BALLS_LOCALIZATION = {}
CELLS_SIZE = -1

local DRAW_MAIN_MENU_TEXT = true
local INNER_REITERATIONS = 3


-- init
local font = {}
function love.load()
    love.window.setTitle("L'ART DU 3.14: Un projet artistique")
    love.graphics.setBackgroundColor(0.05, 0.05, 0.08)
    font = {
        title = love.graphics.newFont("fonts/Audiowide/Audiowide-Regular.ttf", 80),
        body = love.graphics.newFont("fonts/Audiowide/Audiowide-Regular.ttf", 32),
        caption = love.graphics.newFont("fonts/Audiowide/Audiowide-Regular.ttf", 21),
    }
end

-- main loop
local iters_delay_until_next_artwork = 0

local function reset_artwork_data()
    CURRENT_ARTWORK = CURRENT_ARTWORK % #ALL_ARTWORKS + 1
    ARTWORK_DATA = ALL_ARTWORKS[CURRENT_ARTWORK]

    math.randomseed(ARTWORK_DATA.seed)
    BALLS_COUNT = #ARTWORK_DATA.data
    iters = 0
    balls = {}
    CELLS_SIZE = ARTWORK_DATA.cells_size

    BALLS_LOCALIZATION = {}
    for i = 0, math.ceil(AREA_RADIUS * 2 / CELLS_SIZE) do
        for j = 0, math.ceil(AREA_RADIUS * 2 / CELLS_SIZE) do
            BALLS_LOCALIZATION[i .. ';' .. j] = {}
        end
    end

    iters_delay_until_next_artwork = DRAW_MAIN_MENU_TEXT and 125 or 200
end
reset_artwork_data()

function love.update()
    for _ = 1, ARTWORK_DATA.playback_speed do
        if iters < ARTWORK_DATA.iterations then
            -- ball physics
            for _ = 1, INNER_REITERATIONS do
                for _, ball in ipairs(balls) do
                    ball:applyVerletIntegration(DT / INNER_REITERATIONS)
                    ball:applyConstraint()
                    ball:updateLocalization()
                    ball:applyGridCollisions()
                end
            end

            -- add more balls
            if #balls < BALLS_COUNT and iters % ARTWORK_DATA.ball_add_speed == 0 then
                local new_ball = Ball.new(
                    ARTWORK_DATA.spawn_point(iters).x,
                    ARTWORK_DATA.spawn_point(iters).y,
                    ARTWORK_DATA.random_size(CELLS_SIZE),
                    ARTWORK_DATA.initial_velocity,
                    ARTWORK_DATA.direction(iters),
                    ARTWORK_DATA.data[#balls + 1],
                    #balls
                )
                table.insert(balls, new_ball)
            end

            -- increase count
            iters = iters + 1
        else
            -- countdown before showing the next artwork
            iters_delay_until_next_artwork = iters_delay_until_next_artwork - (DRAW_MAIN_MENU_TEXT and 0.25 or 1)
        end
    end

    -- display next artwork
    if iters_delay_until_next_artwork <= 0 then
        reset_artwork_data()
        DRAW_MAIN_MENU_TEXT = false
    end
end

-- display
function love.draw()
    -- constraint
    love.graphics.setColor(0.2, 0.2, 0.3)
    love.graphics.circle("fill", AREA_RADIUS, AREA_RADIUS, AREA_RADIUS, AREA_RADIUS)
    -- draw each ball
    for _, ball in ipairs(balls) do
        local ball_pos = ball:getPos()
        love.graphics.setColor(COLOR_THEME[ball.color])
        love.graphics.circle("fill", ball_pos.x, ball_pos.y, ball.radius, 16)
    end

    -- draw fade-out if the artwork is over
    if iters >= ARTWORK_DATA.iterations then
        local i = math.min(iters_delay_until_next_artwork, 100) / 100
        love.graphics.setColor(0, 0, 0, 1 - i)
        love.graphics.rectangle("fill", 0, 0, AREA_RADIUS * 2, AREA_RADIUS * 2)

        -- draw main menu text during the first time artwork is over
        if DRAW_MAIN_MENU_TEXT then
            local ii
            if i > 0.1 then
                ii = 1 - i
            else
                ii = 1 + 9 * (i - 1 / 9)
            end
            love.graphics.setColor(1, 1, i, ii)
            love.graphics.setFont(font.title)
            love.graphics.printf("L'ART DU 3.14", 0, 64, AREA_RADIUS * 2, "center")
            love.graphics.setFont(font.body)
            love.graphics.printf("Ces animations sont calculées en temps réel", 0, 384 - font.body:getHeight() / 2,
            AREA_RADIUS * 2, "center")
            love.graphics.setFont(font.caption)
            love.graphics.printf("Projet Artistique", 0, 64 + font.title:getHeight(), AREA_RADIUS * 2, "center")
            love.graphics.printf("Junyi Z., programme science-info-math", 0, 668, AREA_RADIUS * 2, "center")
        end
    end
end
