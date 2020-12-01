Wave = Class{}

-- the wave is the play area that is only partially represented

function Wave:init(c, w, h)
	-- self.field = f
	self.x = 0 -- x position of wave on the left side
	self.y = 0
	self.camX = 0
	self.time = 0
	self.colors = c
	self.shader = love.graphics.newShader('shaders/wave_shader.vs')
	self.width = w or FRAME_WIDTH -- span of the wave. may grow bigger. scale w/ difficulty
	self.height = h or FRAME_HEIGHT
	self.view = {} -- % positions of left & right sides of the view?
	self.line = {} -- the bounding line that separates the extreme colors
	self.lineX = 0 -- screen position of wave
end

function Wave:update(dt) -- update the wave to follow the moon phase
	-- adjust the position of the waves
	self.time = self.time + dt
	self:flow()

end

function Wave:flow()
	local phase = self.field.moon:getPhase()

	local fov = self.field.width / self.width -- % amount of the wave seen
	self.x = -(phase - fov / 2) % 1 * self.width

	self.lineX = math.floor(phase * self.width)

end

-- function Wave:reset()
-- 	local phase = self.field.moon:getPhase()


-- end

function Wave:render()
	love.graphics.push()
	love.graphics.setColor(1, 1, 1, 1)
	-- love.graphics.setColor(0, 0, 0, 1)

	love.graphics.setShader(self.shader) -- shader for the water
	self.shader:send('waveResolution', {self.width, self.height})
	self.shader:send('wavePosition', {self.x, self.y})
	self.shader:send('offset', {self.field.x, self.field.y})
	self.shader:send('time', self.time)
	self.shader:send('color1', self.colors[1])
	self.shader:send('color2', self.colors[2])

	love.graphics.rectangle('fill', self.field.x, self.field.y, self.field.width, self.field.height)

	love.graphics.pop()

	love.graphics.setShader()
end