Ocean = Class{}

function Ocean:init(moon, wave, song)
	self.width = FRAME_WIDTH
	self.height = FRAME_HEIGHT
	self.x = (VIRTUAL_WIDTH - self.width) / 2
	self.y = (VIRTUAL_HEIGHT - self.height) / 2
	self.moon = moon
	self.wave = wave
	self.song = song
	self.frameColors = {}
	self.shader = love.graphics.newShader('shaders/frame_shader.vs')
	self.time = 0 -- overall time
	self.timer = 0 -- game timer
	self.harmony = 1 -- harmony relative to dissonance
	self.shifting = {}
	self.bar = {}
	self:clear()
end

function Ocean:update(dt)
	self.moon:update(dt)
	self.wave:update(dt)
	self.song:update(dt)
	self.time = self.time + dt

	if love.keyboard.wasPressed('space') then -- toggle playback
		if state == 'play' then
			state = 'playback'
			self.song.playing = 'bar'
		elseif state == 'playback' then
			state = 'play'
			self.song.playing = false
		end
	end

	local toMoon = 0
	if gameX and gameY then
		toMoon = math.sqrt((gameX-self.moon.x)^2+(gameY-self.moon.y)^2)
	end
	if toMoon <= self.moon.radius and love.mouse.wasPressed(1) then
		state = 'playback'
		self.song:restart()
		self.song.playing = 'bar'
	end

	if state == 'playback' and not self.song.playing then -- check end of playback
		state = 'play'
	end

	if state == 'start' then -- play song at start
		state = 'playback'
		self.song.playing = 'bar'
	end

	if state == 'play' then -- elapse time, collect stars
		self.timer = self.timer + dt
		if self.timer >= duration then
			state = 'reset'
		end
		self:size(dt)
		local shifting = false
		for i = 1, 2 do
			for j = 1, 2 do
				if self.shifting[i][j] then
					shifting = true
				end
			end
		end
		if shifting then
			self:shiftColors(dt)
		end
		local allCollected = true
		for k, star in pairs(self.song.bar) do
			star:update(dt)
			if star.x + star.radius >= self.wave.x - self.width and star.x - star.radius < self.wave.x + self.width*2 then
				if not star.nearby then
					star:play()
				end
				star.nearby = true
			else
				star.nearby = false
			end
			if star.x + star.radius >= self.wave.x and star.x - star.radius < self.wave.x + self.width then
				if star.next and not star.collected then -- star collection
					if gameX and gameY then
						if gameX < self.x + star.x - self.wave.x + star.radius and gameX > self.x + star.x - self.wave.x - star.radius then
							if gameY < self.y + star.y + star.radius and gameY > self.y + star.y - star.radius then
								if love.mouse.wasPressed(1) then -- successful shot
									self:collect(star)
								end
							end
						end
					end
				end
				star.onScreen = true
			else
				star.onScreen = false
			end
			if not star.collected then
				allCollected = false
			end
		end
		if allCollected then
			self.timer = 0
			self.song:recordBar(self.bar)
			if self.song.numBars == self.song.barCount then
				state = 'win'
				self.song.playing = 'score'
			else -- play last bar then next bar
				state = 'playnext'
				self.song.playing = 'bar'
			end
		end
	end

	if state == 'playnext' then
		if not self.song.playing then -- wait for end of playback then play
			state = 'playback'
			self.song:addBar()
			self.song.playing = 'bar'
		end
	end
	
	if state == 'reset' then
		state = 'start'
		local moonParams = {
			radius = self.moon.radius,
			acceleration = self.moon.accel,
			period = self.moon.period,
			inertia = self.moon.inertia,
			topSpeed = self.moon.topSpeed
		}
		reset(moonParams, self.moon.colors, self.frameColors)
	end
	
	if state == 'win' then -- enter win sequence
		-- replay song
		if not self.song.playing then
			state = 'reset'
		end
		-- player can choose to go to next level
		-- if love.keyboard.wasPressed('space')
	end
end

function Ocean:clear()
	self.frameColors[1] = {math.random(), math.random(), math.random(), 1}
	self.frameColors[2] = {math.random(), math.random(), math.random(), 1}
	self.shifting = {
		[1] = {{false, false}, self.moon.colors}, -- new colors, old colors
		[2] = {{false, false}, self.frameColors} -- [2] = frame colors
	}

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

function Ocean:collect(s) -- collecting star
	local star = s
	table.insert(self.bar, star)
	self.timer = math.max(self.timer - 10, 0)
	star.collected = true
	star:play()
	-- self.shifting[1] = true
	local index = math.random(2) -- start shifting colors to a new one
	local newColor = {math.random(), math.random(), math.random(), 1}
	local oldColor = self.shifting[1][1][index]
	self.shifting[1][1][index] = newColor
	self.shifting[2][1][index] = oldColor -- frame takes the moon's previous color
end

function Ocean:shiftColors(dt)
	local shifting = false
	for i = 1, 2 do
		for j = 1, 2 do
			if self.shifting[i][1][j] then
				local newColor = self.shifting[i][1][j]
				local oldColor = self.shifting[i][2][j]
				newColor = lerpColor(oldColor, newColor, dt*0.2)
				self.shifting[i][2][j] = newColor
				if i == 1 then
					self.moon.colors[j] = newColor
				else
					self.frameColors[j] = newColor
				end
				local dc = 0
				for k = 1, 3 do
					dc = dc + math.abs(self.shifting[i][1][j][k]-newColor[k])
				end
				if dc < 0.01 then
					self.shifting[i][1][j] = false
				end
			end
		end
	end
end

function Ocean:render()
	-- draw frame inside
	love.graphics.rectangle('fill', self.x, self.y, self.width, self.height)

	self.wave:render()

	for k, star in pairs(self.song.bar) do
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
	self.shader:send('color1', self.frameColors[1])
	self.shader:send('color2', self.frameColors[2])

	local bw = (VIRTUAL_WIDTH - self.width) / 2 -- border width
	local bh = (VIRTUAL_HEIGHT - self.height) / 2 -- border height

	love.graphics.rectangle('fill', self.x - bw, self.y - bh, self.width + bw * 2, bh)
	love.graphics.rectangle('fill', self.x - bw, self.y + self.height, self.width + bw * 2, bh)
	love.graphics.rectangle('fill', self.x - bw, self.y, bw, self.height)
	love.graphics.rectangle('fill', self.x + self.width, self.y, bw, self.height)
	love.graphics.setShader()

 --  love.graphics.setFont(font) -- for debug
 --  love.graphics.print('phase: ' .. tostring(self.moon.phase), 10, 10)
	-- love.graphics.print('dp: ' .. tostring(self.moon.dp), 10, 22)
 --  love.graphics.print('x: ' .. tostring(self.wave.x), 10, 34)
 --  love.graphics.print('tide: ' .. tostring(self.wave.tide[1]), 10, 46)
	-- love.graphics.print('time: ' .. tostring(self.wave.time), 10, 58)
end