Ocean = Class{}

function Ocean:init(moon, wave, stars, song)
	self.width = FRAME_WIDTH
	self.height = FRAME_HEIGHT
	self.x = (VIRTUAL_WIDTH - self.width) / 2
	self.y = (VIRTUAL_HEIGHT - self.height) / 2
	self.moon = moon
	self.wave = wave
	self.stars = stars
	self.song = song
	self.borderColors = {}
	self.shader = love.graphics.newShader('shaders/frame_shader.vs')
	self.time = 0 -- overall time
	self.timer = 0 -- game timer
	self.shifting = {false, {false, false}, self.moon.colors, {}}
	self:clear()
end

function Ocean:update(dt)
	if state == 'play' then
		self.time = self.time + dt
		self.timer = self.timer + dt
		if self.timer >= duration then
			state = 'reset'
		end
		self:size(dt)
		if self.shifting[1] then
			self:shiftColors(dt)
		end
		self.moon:update(dt)
		self.wave:update(dt)
		local allCollected = true
		for k, star in pairs(self.stars) do
			if star.x + star.radius >= self.wave.x and star.x - star.radius < self.wave.x + self.width then
				if not star.onScreen then
					-- play its sound when it appears
				end
				star.onScreen = true
				if star.next and not star.collected then -- star collection
					if gameX < self.x + star.x - self.wave.x + star.radius and gameX > self.x + star.x - self.wave.x - star.radius then
						if gameY < self.y + star.y + star.radius and gameY > self.y + star.y - star.radius then
							if love.mouse.wasPressed(1) then -- successful shot
								self:collect(star)
							end
						end
					end
				end
				if star.alive then
					star:update(dt)
				end
			else
				star.onScreen = false
			end
			if not star.collected then
				allCollected = false
			end
		end
		if allCollected then
			state = 'win'
		end
	end
	if state == 'reset' then
		state = 'play'
		local moonParams = {radius = self.moon.radius, acceleration = self.moon.accel, period = self.moon.period}
		reset(moonParams, self.moon.colors, self.borderColors)
	end
	if state == 'win' then -- enter win sequence

	end
end

function Ocean:collect(star) -- collecting star
	self.timer = math.max(self.timer - 10, 0)
	star.collected = true
	local nextStar = false
	while not nextStar do
		local index = math.random(#self.stars)
		if not self.stars[index].collected then
			self.stars[index].next = true
			nextStar = true
		end
	end
	local index = math.random(2) -- start shifting colors to a new one
	self.shifting[1] = true
	self.shifting[2][index] = true
	self.shifting[3] = self.moon.colors
	self.shifting[4][index] = {math.random(), math.random(), math.random(), 1}
end

function Ocean:clear()
	self.borderColors[1] = {math.random(), math.random(), math.random(), 1}
	self.borderColors[2] = {math.random(), math.random(), math.random(), 1}
	love.graphics.setColor(1, 1, 1, 1)
	love.graphics.rectangle('fill', self.x, self.y, self.width, self.height)
end

function Ocean:size(dt)
	local nextWidth = math.min((1 - self.timer / duration) * VIRTUAL_WIDTH, FRAME_WIDTH)
	local dWidth = 0
	if nextWidth < self.width then
		dWidth = math.max(math.ceil(nextWidth - self.width), -2)
	elseif nextWidth > self.width then
		dWidth = math.min(math.floor(nextWidth - self.width), 2)
	end
	self.width = self.width + dWidth
	self.x = (VIRTUAL_WIDTH - self.width) / 2
	self.y = (VIRTUAL_HEIGHT - self.height) / 2
end

function Ocean:shiftColors(dt)
	local index = self.shifting[2]
	local oldColors = self.shifting[3]
	local targetColors = self.shifting[4]
	local shifting = false
	for i = 1, 2 do
		if index[i] then
			shifting = true
			local newColor = lerpColor(oldColors[i], targetColors[i], dt*0.2)
			self.moon.colors[i] = newColor
			local dc = 0
			for j = 1, 3 do
				dc = dc + math.abs(targetColors[i][j] - oldColors[i][j])
			end
			if dc < 0.01 then
				index[i] = false
			end
		end
	end
	self.shifting[1] = shifting
end

function Ocean:render()
	-- draw frame inside
	love.graphics.rectangle('fill', self.x, self.y, self.width, self.height)

	self.wave:render()

	for k, star in pairs(self.stars) do
		if star.onScreen then -- make sure the star is on screen, and translate to its location
			love.graphics.push()
			love.graphics.setColor(1, 1, 1, 1)
			love.graphics.translate(self.x + star.x - self.wave.x, self.y + star.y)
			star:render()
			love.graphics.pop()
		end
		if self.wave.x + self.width > self.wave.width then -- draw other side of the wave across border
			local right = (self.wave.x + self.width) % self.wave.width
			if star.x + star.radius >= 0 and star.x - star.radius < right then
				love.graphics.push()
				love.graphics.setColor(1, 1, 1, 1)
				love.graphics.translate(self.x + star.x + self.wave.width - self.wave.x, self.y + star.y)
				star:render()
				love.graphics.pop()
			end
		end -- this can be more concise. maybe
	end

	self.moon:render()

	-- draw frame border - image?
	love.graphics.setColor(1, 1, 1, 1)
	love.graphics.setShader(self.shader) -- shader for the water
	self.shader:send('time', self.time)
	self.shader:send('color1', self.borderColors[1])
	self.shader:send('color2', self.borderColors[2])

	local bw = (VIRTUAL_WIDTH - self.width) / 2 -- border width
	local bh = (VIRTUAL_HEIGHT - self.height) / 2 -- border height

	love.graphics.rectangle('fill', self.x - bw, self.y - bh, self.width + bw * 2, bh)
	love.graphics.rectangle('fill', self.x - bw, self.y + self.height, self.width + bw * 2, bh)
	love.graphics.rectangle('fill', self.x - bw, self.y, bw, self.height)
	love.graphics.rectangle('fill', self.x + self.width, self.y, bw, self.height)
	love.graphics.setShader()

  love.graphics.setFont(font) -- for debug
  love.graphics.print('x: ' .. tostring(self.wave.x), 10, 10)
end