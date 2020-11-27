require 'src/Dependencies'


-- local entity -- entity is what we'll be controlling
 
local world = {} -- the empty world-state
local t

local name = string.format('%f.txt', os.time())
-- local file = love.filesystem.newFile(name)

function love.load()

  t = 0

	love.graphics.setDefaultFilter('nearest', 'nearest')
    love.window.setTitle('Wires x <3')

	math.randomseed(os.time())

	push:setupScreen(VIRTUAL_WIDTH, VIRTUAL_HEIGHT, WINDOW_WIDTH, WINDOW_HEIGHT, {
        vsync = true,
        -- fullscreen = true,
        fullscreen = false,
      	resizable = true
    })

    font = love.graphics.newFont('fonts/font.ttf', 16)

    success, message = love.filesystem.write(name, '')

    -- global values
    pm = 'play'
    -- beats per minute
    bpm = 120
    -- seconds per beat
    spb = 60 / bpm
    -- initial period of a point
    pulse = spb
    -- frames per second
    fps = love.timer.getFPS()
    -- hertz
    freq = 1
    -- amplitude
    amp = 0.5
    -- # of beat locations
    local no = 1
    -- point lifetime
    local dur = 480
    -- free, orbit, binary, gravity
    local mode = 'binary'
    -- the song
    song = Song (dur)
    local oxxy = {0, 0}
    local xoxy = {0, 0}
    local radius = 0
    local theta = 0
    -- two hearts; maybe move all of these into Hearts.lua
    if mode == 'free' then
        oxxy[1], oxxy[2] = math.random(VIRTUAL_WIDTH - HEART_WIDTH),
            math.random(VIRTUAL_HEIGHT - HEART_HEIGHT)
        xoxy[1], xoxy[2] = math.random(VIRTUAL_WIDTH - HEART_WIDTH),
            math.random(VIRTUAL_HEIGHT - HEART_HEIGHT)
        -- ox is left
        if oxxy[1] > xoxy[1] then
            oxxy, xoxy = xoxy, oxxy
        end
    elseif mode == 'binary' then
        local close = false
        while not close do
            oxxy[1], oxxy[2] = math.random(VIRTUAL_WIDTH - HEART_WIDTH),
                math.random(VIRTUAL_HEIGHT - HEART_HEIGHT)
            xoxy[1], xoxy[2] = math.random(VIRTUAL_WIDTH - HEART_WIDTH),
                math.random(VIRTUAL_HEIGHT - HEART_HEIGHT)
            radius = math.sqrt((xoxy[1] - oxxy[1])^2 + (xoxy[2] - oxxy[2])^2) * 0.5
            theta = math.atan2((xoxy[2] - oxxy[2]), (xoxy[1] - oxxy[1]))
            if radius <= MAX_RADIUS then
                close = true
            end
        end
    else

    end
    ox = Heart (oxxy[1], oxxy[2], radius, theta + math.pi)
    xo = Heart (xoxy[1], xoxy[2], radius, theta)
    -- one beat; rename?
    beat = Beat (ox, xo, bpm, no)
    -- their wire
    wire = Wire (ox, xo, beat, freq, amp)
    -- two hearts
    hearts = Hearts (ox, xo, radius, wire, mode)
    -- the crosses
    crosses = {}

    song:clear()
    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.rectangle('fill', 0, 0, VIRTUAL_WIDTH, VIRTUAL_HEIGHT)

    love.mouse.setVisible(false)

    love.keyboard.keysPressed = {}
end

function love.resize(w, h)
    -- push:resize(w, h)
end

function love.update(dt)
    t = t + dt

    -- hearts
    hearts:update(dt)
    -- beat
    -- beat:update(dt)
    -- crosses
    for k, cross in pairs(crosses) do
        cross:update(dt)
    end
    song:update(dt)

    if love.keyboard.wasPressed('tab') or love.keyboard.wasPressed('\\') then
        pm = 'loop'
        song:loop()
        beat:loop()
        hearts:loop()
        writeCellsToFile()  
    end

    -- code for udp send
    -- if t > updaterate then
    --     -- Again, we prepare a packet payload using string.format,
    --     -- then send it on its way with udp:send. This is the move update mentioned above.
    --     -- local dg = string.format("%s %s %f %f", entity, 'move', x, y)
    --     -- local dg = string.format("%f", song:toMatrix()[1][1][1])
    --     local dg = string.format("%q %f %f", '/one/message', 1, 1)
    --     udp:send(dg)
    --     udp:send('message')
    --     udp:send(song:pointsToCells()[1][1])
    --     -- And again! This is a request that the server send us an update for the world state.

    --     writeCells()

    --     t = t - updaterate
    -- end

    -- if t > updaterate then
    --     writeCellsToFile()
    -- end

    -- reset keys pressed
    love.keyboard.keysPressed = {}
end

function love.draw()
    push:start()

    song:render()
    hearts:render()
    -- beat:render()
    -- wire:render()
    for k, cross in pairs(crosses) do
        cross:render()
    end
    push:finish()

    -- displayFPS()
end

function love.keypressed(key)
    -- add to our table of keys pressed this frame
    love.keyboard.keysPressed[key] = true
    if key == 'escape' then
      love.event.quit()
    end
end

function love.keyboard.wasPressed(key)
    if love.keyboard.keysPressed[key] then
        return true
    else
        return false
    end
end

function writeCellsToFile()
    local success
    local message
    local data
    local serialized
    for k, cell in pairs(song:pointsToCells()) do
        data = string.format('%d%s %d %d %f %f %f %f %s',
            k, ',', cell[1], cell[2], cell[3], cell[4], cell[5], cell[6], ';\n')
        success, message = love.filesystem.append(name, data)
    end
    -- local serialized = lume.serialize(song:pointsToCells())
    -- success, message = love.filesystem.write(name, serialized)
end

-- linear interpolation
function lerp(a, b, t)
    return a + t * (b - a)
end

-- round to nearest integer
function round(a)
    return math.floor(a + 0.5)
end

function diagonalDistance(p0, p1)
    local dx = p1.x - p0.x
    local dy = p1.y - p0.y
    return math.max(math.abs(dx), math.abs(dy))
end

function hypotenuse(p0, p1)

end

-- taken from https://www.cs.rit.edu/~ncs/color/t_convert.html
function RGBtoHSV(r, g, b)
    local min = math.min(r, g, b)
    local max = math.max(r, g, b)
    local delta = max - min

    local h
    local s
    local v = max

    if max ~= 0 then
        s = delta / max
    else
        s = 0
        h = -1
        return h, s, v
    end

    if r == max then
        h = (g - b) / delta
    elseif g == max then
        h = 2 + (b - r) / delta
    else
        h = 4 + (r - g) / delta
    end

    h = h * 60
    if h < 0 then
        h = h + 360
    end

    return h, s, v
end

function HSVtoRGB(h, s, v)
    if s == 0 then
        return v, v, v
    end

    local h = h / 60
    local i = math.floor(h)
    local f = h - i
    local p = v * (1 - s)
    local q = v * (1 - s * f)
    local t = v * (1 - s * (1 - f))

    local result = {
        [0] = function() return v, t, p end,
        [1] = function() return q, v, p end,
        [2] = function() return p, v, t end,
        [3] = function() return p, q, v end,
        [4] = function() return t, p, v end,
        [5] = function() return v, p, q end
    }

    return result[i]
end

function displayFPS()
    -- simple FPS display across all states
    love.graphics.setFont(font)
    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.print('FPS: ' .. tostring(love.timer.getFPS()), 10, 10)
end