require 'src/Dependencies'

local width = FRAME_WIDTH * 16 -- for now
local difficulty = 1
local period = LUNA_PERIOD
local radius = LUNA_RADIUS
local field

function love.load()
  love.graphics.setDefaultFilter('nearest', 'nearest')
  love.window.setTitle('tidal stars')
	math.randomseed(os.time())

	push:setupScreen(VIRTUAL_WIDTH, VIRTUAL_HEIGHT, WINDOW_WIDTH, WINDOW_HEIGHT, {
    vsync = true,
    fullscreen = false,
    -- fullscreen = true,
  	resizable = true
  })

  font = love.graphics.newFont('fonts/font.ttf', 16)

  -- gSounds['loop1']:setLooping(true)
  -- gSounds['loop1']:play()
  
  t = 0
  bpm = 120
  spb = 60 / bpm
  duration = 120

  field = NightMaker.generate(width, difficulty, period, radius)

  love.graphics.setColor(1, 1, 1, 1)
  love.graphics.rectangle('fill', 0, 0, VIRTUAL_WIDTH, VIRTUAL_HEIGHT)

  love.mouse.setVisible(true)

  love.keyboard.keysPressed = {}
  love.mouse.buttonsPressed = {}

  -- set cursor
  crosshair_cursor = love.mouse.getSystemCursor("crosshair")
  love.mouse.setCursor(crosshair_cursor)
  gameX, gameY = push:toGame(love.mouse.getPosition())
end

function love.resize(w, h)
  push:resize(w, h)
end

function love.update(dt)
  t = t + dt

  field:update(dt)

  love.keyboard.keysPressed = {}
  love.mouse.buttonsPressed = {}

  gameX, gameY = push:toGame(love.mouse.getPosition())
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

function love.mousepressed(x, y, button, istouch, presses)
    love.mouse.buttonsPressed[button] = true
end

function love.mouse.wasPressed(button)
    if love.mouse.buttonsPressed[button] then
        return true
    else
        return false
    end
end

function reset()
  field = false
  field = NightMaker.generate(width, difficulty, period, radius)
end

-- helper functions

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