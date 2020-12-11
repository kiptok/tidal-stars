Moon = Class{}

-- the heart/beat

function Moon:init(params, colors)
	self.x = VIRTUAL_WIDTH / 2 -- middle of the moon
	self.y = VIRTUAL_HEIGHT / 2
	self.period = params.period -- time to pass through all moon phases
	self.accel = params.acceleration
	self.radius = params.radius -- moon radius
	self.colors = colors
	self.day = self.period * INITIAL_PHASE
	self.phase = INITIAL_PHASE
	self.dp = 0 -- speed of change of day
	self.points = {} -- points
	self.shader = love.graphics.newShader('shaders/moon_shader.vs')
	self:make()
end

function Moon:update(dt)
	if love.keyboard.isDown('space') then
		if gameX < VIRTUAL_WIDTH / 2 then
			self.dp = self.dp + self.accel * (1 - gameX / VIRTUAL_WIDTH * 2)
		elseif gameX >= VIRTUAL_WIDTH / 2 then
			self.dp = self.dp - self.accel * (gameX / VIRTUAL_WIDTH * 2 - 1)
		end
	end
	-- make speed limits?

	-- maybe let these ramp up/down
	self:updatePhase(dt)
end

function Moon:make() -- initialize points; don't need this now?
	self.points[0] = {}
	self.points[0][0] = Point(self.x, self.y, self.colors)
	for j = 1, self.radius do -- middle row of points
		self.points[0][j] = Point(j+self.x, self.y, self.colors)
		self.points[0][-j] = Point(-j+self.x, self.y, self.colors)
	end
	for i = 1, self.radius do
		self.points[i] = {}
		self.points[-i] = {}
		self.points[i][0] = Point(self.x, i+self.y, self.colors) -- middle column of points
		self.points[-i][0] = Point(self.x, -i+self.y, self.colors)
		for j = 1, self.radius do -- create points that are within the radius from center
			local d = math.sqrt(j*j+i*i)
			if d <= self.radius then
				self.points[i][j] = Point(j+self.x, i+self.y, self.colors)
				self.points[i][-j] = Point(-j+self.x, i+self.y, self.colors)
				self.points[-i][j] = Point(j+self.x, -i+self.y, self.colors)
				self.points[-i][-j] = Point(-j+self.x, -i+self.y, self.colors)
			end
		end
	end
end

function Moon:shine() -- cast light on the playing ocean?

end

function Moon:updatePhase(dt)
	self.day = (self.day + self.dp * dt) % self.period
	self.phase = self.day / self.period
	local left = (self.phase - 0.25) % 1 -- gradient end positions
	-- local right = (self.phase + 0.25) % 1
	local x = self.radius
	local pct = left -- value for interpolation between colors
	local increment = 0.25 / x -- increment to pct
	for j = -x, x do -- middle row
		self.points[0][j].light = lerpColor(self.colors[1], self.colors[2], pct)
		pct = (pct + increment) % 1
	end
	for i = 1, self.radius do
		x = math.floor(math.sqrt(self.radius*self.radius - i*i))
		pct = left
		increment = 0.25 / x
		self.points[i][0].light = lerpColor(self.colors[1], self.colors[2], self.phase)
		self.points[-i][0].light = lerpColor(self.colors[1], self.colors[2], self.phase)
		for j = -x, x do
			self.points[i][j].light = lerpColor(self.colors[1], self.colors[2], pct)
			self.points[-i][j].light = lerpColor(self.colors[1], self.colors[2], pct)
			pct = (pct + increment) % 1
		end
	end
end

function Moon:getPhase()
	return self.phase
end

function Moon:render()
	love.graphics.push()
	love.graphics.setColor(1, 1, 1, 1)
	-- love.graphics.setColor(0, 0, 0, 1)

	love.graphics.setShader(self.shader) -- shader for the water
	self.shader:send('moonRadius', self.radius)
	self.shader:send('moonCenter', {self.x, self.y})
	self.shader:send('moonPhase', self.phase)
	self.shader:send('color1', self.colors[1])
	self.shader:send('color2', self.colors[2])

	for k, row in pairs(self.points) do
		for l, point in pairs(row) do
			point:render()
		end
	end

	love.graphics.pop()
	love.graphics.setShader()
end