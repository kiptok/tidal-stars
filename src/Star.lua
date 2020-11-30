Star = Class{}

function Star:init(x, y, s, n, c)
	self.x = x -- center of points
	self.y = y
	self.radius = s -- maximum radius of points from center
	self.number = n -- # of points
	self.color = c -- principal color
	self.dcolor = 0.1 -- some # indicating how much the color can change
	self.dtwinkle = self.dcolor / 10
	self.points = {} -- collection of points that aggregate around the center
	self.collected = false
	self.next = false
	-- self.note
	for k = 1, self.number do
		table.insert(self.points, Point(0, 0, self.color))
	end
end

function Star:update(dt)
	if self.collected then -- trail the player or something
		
	end

	self:twinkle(dt)
end

-- distribute points around the center, creating a semi-cohesive body
function Star:make()
	for k, point in pairs(self.points) do
		local x = round(math.random(-self.radius, self.radius) * math.random(-self.radius, self.radius))
		local y = round(math.random(-self.radius, self.radius) * math.random(-self.radius, self.radius))
		local c = {} -- 
		for i = 1, 3 do
			point.light[i] = point.light[i] + math.random(-self.dcolor, self.dcolor)
		end
		point.x = x + self.x
		point.y = y + self.y
	end
end

-- slightly adjust colors of points within range
function Star:twinkle(dt)
	for k, point in pairs(self.points) do
		for i = 1, 3 do
			local dc = point.light[i] - self.color -- first the current color deviation
			dc = dc + math.random(-self.dtwinkle, self.dtwinkle) -- add more
			if dc < -self.dcolor or dc > self.dcolor then
				dc = (dc + self.dcolor) % (self.dcolor * 2) - self.dcolor
			end
			point.light[i] = self.color + dc
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