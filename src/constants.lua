WINDOW_WIDTH = 1280
WINDOW_HEIGHT = 720

VIRTUAL_WIDTH = 1280
VIRTUAL_HEIGHT = 720

-- WINDOW_WIDTH, WINDOW_HEIGHT = love.window.getDimensions
-- VIRTUAL_WIDTH, VIRTUAL_HEIGHT = love.window.getDimensions

FRAME_WIDTH = VIRTUAL_WIDTH*71/80
FRAME_HEIGHT = VIRTUAL_HEIGHT*4/5

INITIAL_PHASE = 0.25

LUNA = {radius = 48, acceleration = 0.08, period = 29.530587981, inertia = 0.5, topSpeed = 5}
EUROPA = {radius = 43, acceleration = 0.0227109826, period = 3.551181}
TITAN = {period = 15.945}
DEIMOS = {period = 1.263}
PHOBOS = {period = 0.31891023}

STAR_RADIUS_MIN = 32
STAR_RADIUS_MAX = 80

SCALES = {
	['major'] = {0, 2, 4, 5, 7, 9, 11},
	['minor'] = {0, 2, 3, 5, 7, 8, 10}
	-- add more later
}

STEPWEIGHTS = { -- bad way to do this
	[-7] = 1/15,
	[-6] = 1/15,
	[-5] = 1/15,
	[-4] = 1/15,
	[-3] = 1/15,
	[-2] = 1/15,
	[-1] = 1/15,
	[0] = 1/15,
	[1] = 1/15,
	[2] = 1/15,
	[3] = 1/15,
	[4] = 1/15,
	[5] = 1/15,
	[6] = 1/15,
	[7] = 1/15
}