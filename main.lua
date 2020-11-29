require 'src/Dependencies'

function love.load()
  love.graphics.setDefaultFilter('nearest', 'nearest')
  love.window.setTitle('we have the stars')
	math.randomseed(os.time())

	push:setupScreen(VIRTUAL_WIDTH, VIRTUAL_HEIGHT, WINDOW_WIDTH, WINDOW_HEIGHT, {
    vsync = true,
    fullscreen = false,
    -- fullscreen = true,
  	resizable = true
  })

  font = love.graphics.newFont('fonts/font.ttf', 16)

  -- gStateMachine = StateMachine {
  --   ['menu'] = function() return MenuState() end,
  --   ['play'] = function() return PlayState() end
  -- }
  -- gStateMachine:change('menu')

  gSounds['loop1']:setLooping(true)
  gSounds['loop1']:play()

  -- bpm = 120
  -- spb = 60 / bpm
  local dur = 60
  -- song = Song (dur)
  field = Field(dur)

  love.graphics.setColor(1, 1, 1, 1)
  love.graphics.rectangle('fill', 0, 0, VIRTUAL_WIDTH, VIRTUAL_HEIGHT)

  love.mouse.setVisible(false)

  love.keyboard.keysPressed = {}
end

function love.resize(w, h)
  push:resize(w, h)
end

function love.update(dt)
  t = t + dt



  love.keyboard.keysPressed = {}
end

function love.draw()
  push:start()
  field:render()
  push:finish()
  -- displayFPS()
end

function love.keypressed(key)
  love.keyboard.keysPressed[key] = true
  if key == 'escape' then
    love.event.quit()
  end
end

function love.keyboard.wasPressed(key)
  return love.keyboard.keysPressed[key]
end

-- function writeCellsToFile()
--   local success
--   local message
--   local data
--   local serialized
--   for k, cell in pairs(song:pointsToCells()) do
--       data = string.format('%d%s %d %d %f %f %f %f %s',
--           k, ',', cell[1], cell[2], cell[3], cell[4], cell[5], cell[6], ';\n')
--       success, message = love.filesystem.append(name, data)
--   end
--   -- local serialized = lume.serialize(song:pointsToCells())
--   -- success, message = love.filesystem.write(name, serialized)
-- end

-- linear interpolation
function lerp(a, b, t)
  return a + t * (b - a)
end

-- linear interpolation of RGB colors
function lerpColor(a, b, t)
  local newColor = {}
  for i = 1, 4 do
    newColor[i] = lerp(a[i], b[i], t)
  end
  return newColor
end

-- round to nearest integer
function round(a)
  return math.floor(a + 0.5)
end

-- diagonal distance between Points
function diagonalDistance(p0, p1)
  local dx = p1.x - p0.x
  local dy = p1.y - p0.y
  return math.max(math.abs(dx), math.abs(dy))
end

-- distance between Points
function hypotenuse(p0, p1)
  local dx = p1.x - p0.x
  local dy = p1.y - p0.y
  return math.sqrt(dx*dx + dy*dy)
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