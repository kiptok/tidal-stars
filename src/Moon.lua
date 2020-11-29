Moon = Class{}

-- the heart/beat

function Moon:init(x, y, w)
	self.x = x
	self.y = y
	self.phase = LUNA_PERIOD/4
	self.dp = 0
	self.period = LUNA_PERIOD
	self.radius = LUNA_RADIUS
	self.colors = {
		{
			math.random(), math.random(), math.random(), 1
		},
		{
			math.random(), math.random(), math.random(), 1
		}
	}
	self.points = {} -- points
	self.wave = Wave(self, self.colors[1], self.colors[2])
	-- self.points
	self:make()
end

function Moon:update(dt)
	-- phase left/right
	if love.keyboard.isDown('a') or love.keyboard.isDown('left') then
		self.dp = self.dp - MOON_ACCEL
	elseif love.keyboard.isDown('d') or love.keyboard.isDown('right') then
		self.dp = self.dp + MOON_ACCEL
	end
	-- stop
	if love.keyboard.wasPressed('space') then
		self.dp = 0
	end
	-- maybe let these ramp up/down
	self:phase(dt)
	self.wave:update(dt)
end

function Moon:make() -- initialize points
	self.points[0] = {}
	self.points[0][0] = Point(0, 0, self.colors)
	for j = 1, self.radius do -- middle points
		self.points[0][j] = Point(j, 0, self.colors)
		self.points[0][-j] = Point(-j, 0, self.colors)
	end
	for i = 1, self.radius do
		self.points[i] = {}
		self.points[-i] = {}
		for j = 1, self.radius do
			local d = math.sqrt(j*j+i*i)
			if d <= self.radius then
				self.points[i][j] = Point(j, i, self.colors)
				self.points[i][-j] = Point(-j, i, self.colors)
				self.points[-i][j] = Point(j, -i, self.colors)
				self.points[-i][-j] = Point(-j, -i, self.colors)
			end
		end
	end
end

function Moon:shine() -- cast light on the playing field?

end

function Moon:phase(dt) -- sweeping light/dark over the moon
	self.phase = (self.phase + self.dp * dt) % self.period
	local pct = self.phase % (self.period * 0.5) / (self.period * 0.5)
	local left = 1
	local right = 2
	if self.phase >= self.period*0.5 then
		left, right = right, left
	end

	for i = 1, self.radius do
		local maxX = math.floor(math.sqrt(self.radius*self.radius - i*i))
		local remaining = #self.points[i]
		for j = -maxX, maxX do
			if (remaining / #self.points[i]) > pct then
				self.points[i][j]:setLight(left)
				self.points[-i][j]:setLight(left)
			else
				self.points[i][j]:setLight(right)
				self.points[-i][j]:setLight(right)
			end
			remaining = remaining - 1
		end
	end
end

function Moon:render()
	for k, point in pairs(self.light) do
		point:render()
	end
	self.wave:render()
end