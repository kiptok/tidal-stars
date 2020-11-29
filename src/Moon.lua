Moon = Class{}

-- the heart/beat

function Moon:init(c, p, r)
	self.period = p or LUNA_PERIOD -- time to pass through all moon phases
	self.day = self.period * 0.25 -- start at 1/4 moon
	self.phase = self.day / self.period
	self.dp = 0 -- speed of change of phase
	self.radius = r or LUNA_RADIUS -- moon size
	self.colors = c
	self.points = {} -- points
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
	-- make speed limits

	-- maybe let these ramp up/down
	self:phase(dt)
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

function Moon:phase(dt)
	self.day = (self.day + self.dp * dt) % self.period
	self.phase = self.day / self.period
	local left = (self.phase - 0.25) % 1 -- gradient end positions
	-- local right = (self.phase + 0.25) % 1
	local x = self.radius
	local pct = left
	local increment = 0.25 / x
	for j = -x, x do
		self.points[0][j]:setLight(lerpColor(self.colors[1], self.colors[2], pct))
		pct = (pct + increment) % 1
	end
	for i = 1, self.radius do
		x = math.floor(math.sqrt(self.radius*self.radius - i*i))
		pct = left
		increment = 0.25 / x
		for j = -x, x do
			self.points[i][j]:setLight(lerpColor(self.colors[1], self.colors[2], pct))
			self.points[-i][j]:setLight(lerpColor(self.colors[1], self.colors[2], pct))
			pct = (pct + increment) % 1
		end
	end
end

-- function Moon:phase(dt) -- sweeping light/dark over the moon
-- 	self.day = (self.day + self.dp * dt) % self.period
-- 	self.phase = self.day / self.period
-- 	local pct = self.phase * 2 % 1
-- 	local left = 1
-- 	local right = 2
-- 	if self.phase >= 0.5 then
-- 		left, right = right, left
-- 	end

-- 	for i = 1, self.radius do
-- 		local maxX = math.floor(math.sqrt(self.radius*self.radius - i*i))
-- 		local remaining = #self.points[i]
-- 		for j = -maxX, maxX do
-- 			if (remaining / #self.points[i]) > pct then
-- 				self.points[i][j]:setLight(left)
-- 				self.points[-i][j]:setLight(left)
-- 			else
-- 				self.points[i][j]:setLight(right)
-- 				self.points[-i][j]:setLight(right)
-- 			end
-- 			remaining = remaining - 1
-- 		end
-- 	end
-- end

function Moon:getPhase()
	return self.phase
end

function Moon:render()
	for k, point in pairs(self.light) do
		point:render()
	end
end