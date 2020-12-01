Star = Class{}

function Star:init(x, y, r, n, c)
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

	if self.collected then -- trail the player or something
		
	end

end

-- distribute points around the center, creating a semi-cohesive body
function Star:make()
	for i = 1, 3 do -- initialize star color
		self.color[i] = self.color[i] + (math.random()-0.5) * 2 * self.dcolorMax
	end
	local newColor = self:newColor(self.color)

	-- rings
	for k = 1, self.radius do
		-- if math.random() * (1 - k / self.radius) > 0.5 then
		if math.random() > 0.8 or k / self.radius < 0.1 then
			for i = 1, k do
				local x = math.floor(math.sqrt(k*k-i*i))
				newColor = self:newColor(self.color)
				newColor[4] = 1 - (k / self.radius)
				table.insert(self.points, Point(x, i, {newColor}))
				table.insert(self.points, Point(-x, i, {newColor}))
				table.insert(self.points, Point(-x, -i, {newColor}))
				table.insert(self.points, Point(x, -i, {newColor}))
			end
		end
		if math.random() > 0.8 or k / self.radius < 0.1 then
			newColor = self:newColor(self.color)
			newColor[4] = 1 - (k / self.radius)
			table.insert(self.points, Point(k, 0, {newColor}))
			table.insert(self.points, Point(0, k, {newColor}))
			table.insert(self.points, Point(-k, 0, {newColor}))
			table.insert(self.points, Point(0, -k, {newColor}))
		end
		if math.random() > 0.8 or k / self.radius < 0.1 then
			newColor = self:newColor(self.color)
			newColor[4] = 1 - (k / self.radius)
			table.insert(self.points, Point(k, k, {newColor}))
			table.insert(self.points, Point(-k, k, {newColor}))
			table.insert(self.points, Point(-k, -k, {newColor}))
			table.insert(self.points, Point(k, -k, {newColor}))
		end
	end

	-- for i = -self.radius, self.radius do
	-- 	for j = -self.radius, self.radius do
	-- 		local distance = math.sqrt(i*i+j*j)
	-- 		if math.random()*math.random()*math.random()*math.random()*self.radius >= distance then
	-- 			newColor[4] = 1 - (distance / self.radius)
	-- 			table.insert(self.points, Point(j, i, {newColor})) -- more colors?
	-- 		end
	-- 		newColor = self:newColor(self.color)
	-- 	end
	-- end
end

-- no do some procedural geometry

-- slightly adjust colors of points within range
function Star:twinkle()
	for k, point in pairs(self.points) do
		local newColor = self:newColor(point.light)
		point.light = newColor
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
	-- for i = 1, 3 do
	-- 	local dc = color[i] - self.color[i] -- first the current color deviation
	-- 	dc = dc + (math.random()-0.5) * 2 * self.dcolor -- discrete amount of color change
	-- 	if dc < -self.dcolorMax then
	-- 		dc = dc + self.dcolorMax * 2
	-- 	end
	-- 	if dc > self.dcolorMax then
	-- 		dc = dc - self.dcolorMax * 2
	-- 	end
	-- 	color[i] = self.color[i] + dc
	-- end
	return newColor
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