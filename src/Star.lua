Star = Class{}

function Star:init(params, color)
	-- self.category = 
	self.class = params.class or 'A' -- star class
  self.note = params.note or {} -- note that plays -- table of pitch/dur/vel ?
	self.voice = love.audio.newSource(params.sound, 'static') -- sound
	self.x = params.x -- center of points (relative to the wave)
	self.y = params.y
	self.radius = params.radius -- maximum radius of points from center
	self.color = color -- principal color
	self.dcolorMax = 0.05 -- some # indicating how much the color can change
	self.dcolor = self.dcolorMax * 0.4
	self.count = math.random() * 0.1
	self.period = 0.1 + math.random() * 0.1 -- relate this to dur?
	self.points = {} -- collection of points that aggregate around the center
	self.space = {}
	self.collected = false
	self.next = params.next or false
	self.onScreen = true
	self.nearby = false
	self.alive = true
	self.voice:setPosition(self.x, self.y, 0)
	self.voice:setAttenuationDistances(params.attenuation[1], params.attenuation[2])
	self:make(params.cycles)
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

-- set up color and point table
function Star:make(c)
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

	local cycles = c
	for k = 1, cycles do
		local choice = math.random(6) -- not just random
		self:drawCycle(choice)
	end
	-- make note
end

-- add one cycle of points to the star; maybe rapidly switch between these per step?
function Star:drawCycle(choice) -- change this to a table of functions?
	local r, theta, x, y
	local a, b, c, d = 0
	local offset = {math.random()*2*math.pi, math.random()*2*math.pi}
	if choice == 1 then -- circle
		local circles = math.random(8)
		for j = 1, circles do
			r = math.random()*self.radius
			for l = 1, 360 do
				theta = l*2*math.pi/360
				self:addPoint(r, theta, 'polar')
			end
		end
	elseif choice == 2 then -- cardioids
		a = (math.random()-0.5)*self.radius
		b = math.random(17)-9
		local factors = math.random(4)
		for l = 1, 360 do
			theta = l*2*math.pi/360
			r = a
			for j = 1, factors do
				r = r*math.sin(b*theta+offset[1])
				offset[1] = math.random()*2*math.pi
				b = math.random(17)-9
			end
			r = r + a
			self:addPoint(r, theta, 'polar')
		end
	elseif choice == 3 then -- rose
		a = (math.random()-0.5)*2*self.radius
		b = math.random(17)-9 -- b might be 0 but oh well
		-- c = math.random(17)-9 -- add this in later as a denominator?
		for l = 1, 360 do
			theta = l*2*math.pi/360
			r = a*math.sin(b*theta+offset[1])
			self:addPoint(r, theta, 'polar')
		end
	elseif choice == 4 then -- butterfly
		a = (math.random()-0.5)*self.radius
		b = math.random(17)-9
		c = (math.random()-0.5)*self.radius
		-- c = self.radius-a
		d = math.random(17)-9
		for l = 1, 360 do
			theta = l*2*math.pi/360
			r = a*math.sin(b*theta+offset[1])+c*math.sin(d*theta+offset[2])
			self:addPoint(r, theta, 'polar')	
		end
	elseif choice == 5 then -- band
		a = math.random()*2
		b = (math.random()-0.5)*self.radius
		c = (math.random()-0.5)*self.radius
		d = (math.random()-0.5)*(self.radius-math.abs(a*c))
		for l = 1, 360 do
			theta = l*2*math.pi/360
			r = a*(b*(theta+offset[1])%c)+d
			self:addPoint(r, theta, 'polar')
		end
	elseif choice == 6 then -- cloud
		for l = 1, 360 do
			theta = l*2*math.pi/360
			r = math.random()*self.radius
			self:addPoint(r, theta, 'polar')
		end
	end
end

function Star:play(relative)
	self.voice:stop()
	if relative then
		self.voice:setRelative(true)
		self.voice:setPosition(0, 0, 0)
	else
		self.voice:setRelative(false)
		self.voice:setPosition(self.x, self.y, 0)
	end
	self.voice:setPitch(2^(self.note['pitch']/12))
	self.voice:play()
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

function Star:addPoint(a, b, mode)
	local x, y = a, b
	local newColor = {}
	if mode == 'polar' then
		x = math.floor(a*math.cos(b))
		y = math.floor(a*math.sin(b))
	end
	newColor = self:newColor(self.color) -- change color
	newColor[4] = 1 - (a / self.radius) -- alpha
	self.points[y][x] = Point(x, y, {newColor})
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