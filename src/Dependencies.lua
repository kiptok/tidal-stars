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

lume = require 'lib/lume'

require 'src/constants'

require 'src/Wire'
require 'src/Cross'
require 'src/Heart'
require 'src/Hearts'
require 'src/Beat'
require 'src/Song'
require 'src/Point'