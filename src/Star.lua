Star = Class{}

function Star:init(x, y, r, n, c)
	self.waveX = x -- center of points
	self.y = y
	self.radius = r -- maximum radius of points from center
	self.numPoints = n -- # of points
	self.color = c -- principal color
	self.dcolor = 0.25 -- some # indicating how much the color can change
	self.dtwinkle = self.dcolor / 2
	self.count = 0
	self.period = 0.3 + math.random() * 0.4
	self.points = {} -- collection of points that aggregate around the center
	self.collected = false
	self.next = false
	-- self.note
	for k = 1, self.numPoints do
		table.insert(self.points, Point(0, 0, self.color))
	end
	self:make()
end

function Star:update(dt)
	self.count = self.count + dt

	if self.count >= self.period then
		self:twinkle()
		self.count = self.count % self.period
	end

	if self.collected then -- trail the player or something
		
	end

end

-- distribute points around the center, creating a semi-cohesive body
function Star:make()
	for k, point in pairs(self.points) do
		local r = self.radius
		local x = round((math.random()-0.5) * (math.random()-0.5) * 4 * r)
		local y = math.random(-r, r) / x
		for i = 1, 3 do
			local dc = (math.random()-0.5) * 2 * self.dcolor
			point.light[i] = point.light[i] + dc
		end
		point.light[4] = 1
		point.x = x
		point.y = y
	end
end

-- slightly adjust colors of points within range
function Star:twinkle()
	for k, point in pairs(self.points) do
		for i = 1, 3 do
			local dc = point.light[i] - self.color[i] -- first the current color deviation
			dc = dc + (math.random()-0.5) * 2 * self.dtwinkle -- add more
			if dc < -self.dcolor then
				dc = dc + self.dcolor * 2
			end
			if dc > self.dcolor then
				dc = dc - self.dcolor * 2
			end
			point.light[i] = self.color[i] + dc
		end
	end
end

function Star:render()
	if not self.collected then
		if self.next then -- render in two places?

		end
		for k, point in pairs(self.points) do
			point:render()
		end
	end
end