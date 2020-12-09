Star = Class{}

function Star:init(x, y, r, n, c)
	-- self.category
	-- self.class
	self.waveX = x -- center of points
	self.x = 0
	self.y = y
	self.radius = r -- maximum radius of points from center
	self.numPoints = n -- # of points
	self.color = c -- principal color
	self.dcolorMax = 0.05 -- some # indicating how much the color can change
	self.dcolor = self.dcolorMax * 0.4
	self.count = math.random() * 0.1
	self.period = 0.1 + math.random() * 0.1
	self.points = {} -- collection of points that aggregate around the center
	self.space = {}
	self.collected = false
	self.next = false
	self.onScreen = false
	self.alive = true
	-- self.note -- sound that plays
	-- for k = 1, self.numPoints do
	-- 	table.insert(self.points, Point(0, 0, self.color))
	-- end
	self:make()
end

function Star:update(dt)
	self.count = self.count + dt

	if self.count >= self.period then
		self:twinkle()
		self.count = self.count % self.period
	end

	if self.collected and self.alive then -- trail the player or something
		self:die(dt)
	end

end

-- distribute points around the center, creating a semi-cohesive body
function Star:make()
	for i = 1, 3 do -- initialize star color
		self.color[i] = self.color[i] + (math.random()-0.5) * 2 * self.dcolorMax
	end
	local newColor = self:newColor(self.color)

	for i = -self.radius, self.radius do
		self.points[i] = {}
		for j = -self.radius, self.radius do
			self.points[i][j] = false
		end
	end

	local cycles = math.random(12) + 9

	for k = 1, cycles do -- maybe rapidly switch between these per step?
		local choice = math.random(4)
		local r
		local theta
		local x
		local y
		if choice == 1 then -- circle
			local circles = math.random(8)
			for j = 1, circles do
				r = math.random() * self.radius
				for l = 1, 360 do
					theta = l*2*math.pi/360
					x = math.floor(r*math.cos(theta))
					y = math.floor(r*math.sin(theta))
					newColor = self:newColor(self.color)
					newColor[4] = 1 - (r / self.radius)
					if not self.points[y][x] then
						self.points[y][x] = Point(x, y, {newColor})
					end
				end
			end
		elseif choice == 2 then -- cardioid
			local a = (math.random()-0.5) * self.radius
			local trig = math.random(2)
			for l = 1, 360 do
				theta = l*2*math.pi/360
				if trig == 1 then
					r = a - a*math.sin(theta)
				else
					r = a + a*math.cos(theta)
				end
				x = math.floor(r*math.cos(theta))
				y = math.floor(r*math.sin(theta))
				newColor = self:newColor(self.color)
				newColor[4] = 1 - (r / self.radius)
				if not self.points[y][x] then
					self.points[y][x] = Point(x, y, {newColor})
				end
			end
		elseif choice == 3 then -- rose
			local a = (math.random()-0.5) * 2 * self.radius
			local b = math.random(8)
			local trig = math.random(2)
			for l = 1, 360 do
				theta = l*2*math.pi/360
				if trig == 1 then
					r = a*math.sin(b*theta)
				else
					r = a*math.cos(b*theta)
				end
				x = math.floor(r*math.cos(theta))
				y = math.floor(r*math.sin(theta))
				newColor = self:newColor(self.color)
				newColor[4] = 1 - (r / self.radius)
				if not self.points[y][x] then
					self.points[y][x] = Point(x, y, {newColor})
				end
			end
		elseif choice == 4 then -- random
			for l = 1, 360 do
				theta = l*2*math.pi/360
				r = math.random() * self.radius
				x = math.floor(r*math.cos(theta))
				y = math.floor(r*math.sin(theta))
				newColor = self:newColor(self.color)
				newColor[4] = 1 - (r / self.radius)
				if not self.points[y][x] then
					self.points[y][x] = Point(x, y, {newColor})
				end
			end
		end
	end
end

-- slightly adjust colors of points within range
function Star:twinkle()
	for k, row in pairs(self.points) do
		for l, point in pairs(row) do
			if point then
				local newColor = self:newColor(point.light)
				point.light = newColor
			end
		end
	end
end

-- find a new color within dcolor range
function Star:newColor(c)
	local lastColor = c
	local newColor = {}
	for i = 1, 3 do
		repeat
			local dc = (math.random()-0.5) * 2 * self.dcolor
			newColor[i] = lastColor[i] + dc
		until math.abs(newColor[i] - lastColor[i]) < self.dcolorMax
	end
	newColor[4] = lastColor[4]
	return newColor
end

function Star:die(dt)
	local da = 0
	for k, row in pairs(self.points) do
		for l, point in pairs(row) do
			if point then
				point.light = lerpColor(point.light, {1, 1, 1, 0}, dt)
				da = da + point.light[4]
			end
		end
	end
	if da < 0.001 then
		self.alive = false
		self.next = false
	end
end

function Star:render()
	if self.alive and self.onScreen then
		if self.next then -- right now only render next star
			for k, row in pairs(self.points) do
				for l, point in pairs(row) do
					if point then
						point:render()
					end
				end
			end
		end
	end
	-- render in two places?
end