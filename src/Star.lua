Star = Class{}

function Star:init(x, y, r, n, c)
	self.waveX = x -- center of points
	self.x = 0
	self.y = y
	self.radius = r -- maximum radius of points from center
	self.numPoints = n -- # of points
	self.color = c -- principal color
	self.dcolorMax = 0.2 -- some # indicating how much the color can change
	self.dcolor = self.dcolorMax / 10
	self.count = math.random() * 0.1
	self.period = 0.1 + math.random() * 0.1
	self.points = {} -- collection of points that aggregate around the center
	self.space = {}
	self.collected = false
	self.next = false
	-- self.note
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

	if self.collected then -- trail the player or something
		
	end

end

-- distribute points around the center, creating a semi-cohesive body
function Star:make()
	for i = 1, 3 do -- initialize star color
		self.color[i] = self.color[i] + (math.random()-0.5) * 2 * self.dcolorMax
	end

	local newColor = self:newColor(self.color)

	for i = -self.radius, self.radius do
		for j = -self.radius, self.radius do
			local distance = math.sqrt(i*i+j*j)
			if math.random()*math.random()*self.radius >= distance then
				newColor[4] = 1 - (distance / self.radius)
				table.insert(self.points, Point(j, i, newColor))
			end
			newColor = self:newColor(self.color)
		end
	end

	-- local lastPoint = {}
	-- local lastColor = {}
	-- -- self.space[0][0] = true -- indicate that there is a point at j, i
	-- -- self.space[1][1] = true
	-- -- self.space[1][-1] = true
	-- -- self.space[-1][-1] = true
	-- -- self.space[-1][1] = true
	-- lastPoint[1] = {1, 1}
	-- lastPoint[2] = {-1, 1}
	-- lastPoint[3] = {-1, -1}
	-- lastPoint[4] = {1, -1}
	-- lastColor[1] = self:newColor(self.color)
	-- lastColor[2] = self:newColor(self.color)
	-- lastColor[3] = self:newColor(self.color)
	-- lastColor[4] = self:newColor(self.color)
	-- table.insert(self.points, Point(0, 0, self.color))
	-- table.insert(self.points, Point(1, 1, self:newColor(lastColor[1])))
	-- table.insert(self.points, Point(-1, 1, self:newColor(lastColor[2])))
	-- table.insert(self.points, Point(-1, -1, self:newColor(lastColor[3])))
	-- table.insert(self.points, Point(1, -1, self:newColor(lastColor[4])))

	-- for i = 6, self.numPoints do
	-- 	local quad = math.random(4)
	-- 	local newPoint = {}
	-- 	local newColor
	-- 	local dx
	-- 	local dy
	-- 	if quad == 1 then -- there must be a better way
	-- 		repeat
	-- 			dx = (math.random(2) - 1.5) * 2
	-- 			dy = (math.random(2) - 1.5) * 2
	-- 			newPoint[1] = lastPoint[quad][1] + dx -- new x coordinate
	-- 			newPoint[2] = lastPoint[quad][2] + dy -- new y coordinate
	-- 		until newPoint[1] >= 0 and newPoint[2] >= 0 and (dx+dy) >= -2
	-- 	elseif quad == 2 then
	-- 		repeat
	-- 			dx = (math.random(2) - 1.5) * 2
	-- 			dy = (math.random(2) - 1.5) * 2
	-- 			newPoint[1] = lastPoint[quad][1] + dx -- new x coordinate
	-- 			newPoint[2] = lastPoint[quad][2] + dy -- new y coordinate
	-- 		until newPoint[1] <= 0 and newPoint[2] >= 0 and (-dx+dy) >= -2
	-- 	elseif quad == 3 then
	-- 		repeat
	-- 			dx = (math.random(2) - 1.5) * 2
	-- 			dy = (math.random(2) - 1.5) * 2
	-- 			newPoint[1] = lastPoint[quad][1] + dx -- new x coordinate
	-- 			newPoint[2] = lastPoint[quad][2] + dy -- new y coordinate
	-- 		until newPoint[1] <= 0 and newPoint[2] <= 0 and (-dx-dy) >= -2
	-- 	elseif quad == 4 then
	-- 		repeat
	-- 			dx = (math.random(2) - 1.5) * 2
	-- 			dy = (math.random(2) - 1.5) * 2
	-- 			newPoint[1] = lastPoint[quad][1] + dx -- new x coordinate
	-- 			newPoint[2] = lastPoint[quad][2] + dy -- new y coordinate
	-- 		until newPoint[1] >= 0 and newPoint[2] <= 0 and (dx-dy) >= -2
	-- 	end
	-- 	newColor = self:newColor(lastColor[quad])
	-- 	-- self.space[newPoint[2]][newPoint[1]] = true
	-- 	lastPoint[quad] = newPoint
	-- 	lastColor[quad] = newColor
	-- 	table.insert(self.points, Point(newPoint[1], newPoint[2], newColor))
	-- end


	-- for k, point in pairs(self.points) do
	-- 	local r = self.radius
	-- 	local x = round((math.random()-0.5) * (math.random()-0.5) * 4 * r)
	-- 	local y = math.random(-r, r) / x
	-- 	for i = 1, 3 do
	-- 		local dc = (math.random()-0.5) * 2 * self.dcolorMax
	-- 		point.light[i] = point.light[i] + dc
	-- 	end
	-- 	local d = math.sqrt(x*x+y*y) / r
	-- 	point.light[4] = 1 - d * 0.5
	-- 	point.x = x
	-- 	point.y = y
	-- end
end

-- no do some procedural geometry

-- slightly adjust colors of points within range
function Star:twinkle()
	for k, point in pairs(self.points) do
		for i = 1, 3 do
			local dc = point.light[i] - self.color[i] -- first the current color deviation
			dc = dc + (math.random(5)-3) * 0.5 * self.dcolor -- add more
			if dc < -self.dcolorMax then
				dc = dc + self.dcolorMax * 2
			end
			if dc > self.dcolorMax then
				dc = dc - self.dcolorMax * 2
			end
			point.light[i] = self.color[i] + dc
		end
	end
end

-- find a new color within dcolor range
function Star:newColor(c)
	local color = c
	for i = 1, 3 do
		local dc = color[i] - self.color[i] -- first the current color deviation
		dc = dc + (math.random(5)-3) * 0.5 * self.dcolor -- discrete amount of color change
		if dc < -self.dcolorMax then
			dc = dc + self.dcolorMax * 2
		end
		if dc > self.dcolorMax then
			dc = dc - self.dcolorMax * 2
		end
		color[i] = self.color[i] + dc
	end
	return color
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