Point = Class{}

-- points are visible
-- they have many properties

function Point:init(x, y, c)
	self.x = x
	self.y = y
	-- self:round()
	-- self.luminosity = l or 0 -- not using this right now. it's just a function of the light
	self.currentColor = 1 -- index
	self.colors = c -- table of intrinsic colors
	self.light = {c[1], c[2], c[3], c[4] or 1} -- visible color
	-- something like this
	-- or make the period a global 'drunk' value
	-- period = spb +/- (math.random() / 120)
	-- pulse = spb -- remove this?
	-- 2 colors for now	
	-- local ct = {} -- color interpolation amounts
	-- for i = 1, 3 do
	-- 	table.insert(ct, math.sqrt(math.random()))
	-- end
	-- self:addColor(ct)
end

function Point:update(dt)

end

-- -- fade colors
-- function Point:fade(dt)
-- 	local nextColor = self.currentColor + 1
-- 	if #self.colors > 1 then
-- 		if nextColor > #self.colors then
-- 			nextColor = 1
-- 		end
-- 		for i = 1, 3 do -- consider how to calculate t here
-- 			self.light[i] = lerp(self.light[i], self.colors[nextColor][i], self.count / self.period)
-- 		end
-- 	end
-- end

-- change colors
-- function Point:blink(s)
-- 	local step = s

-- 	if #self.colors > 1 then
-- 		self.currentColor = self.currentColor + step
-- 		if self.currentColor > #self.colors then
-- 			self.currentColor = self.currentColor % #self.colors
-- 		end
-- 		for i = 1, 3 do
-- 			self.light[i] = math.min(self.colors[self.currentColor][i], 1)
-- 		end
-- 		self.light[4] = self.colors[self.currentColor][4]
-- 	end
-- end

-- -- adjust alpha/(luminosity)
-- function Point:shine(dt)
-- 	local t = 0.2 * dt
-- 	-- make this adaptable to more colors
-- 	local a = lerp(self.colors[1][4], self.colors[2][4], t)
-- 	local b = lerp(self.colors[2][4], self.colors[1][4], t)
-- 	self.colors[1][4] = math.min(a, 1)
-- 	self.colors[2][4] = math.min(b, 1)

-- 	if math.abs(a - b) < MIN_ALPHA_DIFF then
-- 		self.colors[math.random(2)][4] = math.min(lerp(self.alphaRange[1], self.alphaRange[2], math.random()), 1)
-- 	end
-- end

function Point:setLight(c)
	self.light = self.colors[c]
end

-- interpolate from last color to its opposite
function Point:addColor(ct)
	local lastColor = self.colors[#self.colors]
	local newColor = {}
	for i = 1, 3 do
		table.insert(newColor, lerp(lastColor[i], 1 - lastColor[i], ct[i]))
	end
	table.insert(newColor, lastColor[4] or 1)
	table.insert(self.colors, newColor)
end

-- {x, y, light, colors, period, count, life}
function Point:toTable()
	return {self.x, self.y, self.light, self.colors, self.period, self.count, self.life}
end

-- {x, y, r, g, b, a}
-- or for Max: string of the form 'x y r g b a'
function Point:xyrgba()
	return {self.x, self.y, self.light[1], self.light[2], self.light[3], self.light[4]}
end

-- use hue shift to rotate colors of points
function Point:round()
	self.x = math.floor(self.x + 0.5)
	self.y = math.floor(self.y + 0.5)
end

-- function Point:toTable()
-- 	return {self.x, self.y, table.unpack(self.color)}
-- end
function Point:lerpXY(p0, p1, t)
	self.x = lerp(p0.x, p1.x, t)
	self.y = lerp(p0.y, p1.y, t)
	self:round()
end

-- maybe adjust for luminosity here?
function Point:render()
	love.graphics.setColor(self.light[1] % 1, self.light[2] % 1, self.light[3] % 1, self.light[4])
	love.graphics.points(self.x, self.y)
end