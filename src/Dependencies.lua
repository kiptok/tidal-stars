-- push is a library that will allow us to draw our game at a virtual
-- resolution, instead of however large our window is; used to provide
-- a more retro aesthetic
--
-- https://github.com/Ulydev/push
push = require 'lib/push'

-- the "Class" library we're using will allow us to represent anything in
-- our game as code, rather than keeping track of many disparate variables and
-- methods
--
-- https://github.com/vrld/hump/blob/master/class.lua
Class = require 'lib/class'

require 'lib/tick'

lume = require 'lib/lume'

-- Timer = require 'lib/knife.timer'

require 'src/constants'

require 'src/Ocean'
require 'src/Moon'
require 'src/OceanMaker'
require 'src/Player'
require 'src/Point'
require 'src/Song'
require 'src/Star'
require 'src/Wave'

-- gSounds['loop'] = {
-- 	[1] = love.audio.newSource('sounds/loop1.wav'),
-- 	[2] = love.audio.newSource('sounds/loop2.wav'),
-- 	[3] = love.audio.newSource('sounds/loop3.wav'),
-- 	[4] = love.audio.newSource('sounds/loop4.wav')
-- }

-- gSounds['star'] = {
-- 	[1] = love.audio.newSource('sounds/star1.wav', 'static'),
-- 	[2] = love.audio.newSource('sounds/star2.wav', 'static'),
-- 	[3] = love.audio.newSource('sounds/star3.wav', 'static'),
-- 	[4] = love.audio.newSource('sounds/star4.wav', 'static')
-- }

starSounds = {
	[1] = 'sounds/star1.wav',
	[2] = 'sounds/star2.wav'
	-- [3] = 'sounds/star3.wav',
	-- [4] = 'sounds/star4.wav'
	-- [1] = 'sounds/test1.wav', -- testing purposes
	-- [2] = 'sounds/test2.wav',
	-- [3] = 'sounds/test3.wav',
	-- [4] = 'sounds/test4.wav'
}