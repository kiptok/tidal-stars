Wave = Class{}

-- the wave is the play area that is only partially represented

function Wave:init(c, w, h)
	-- self.ocean = f
	self.x = 0 -- x position of wave on the left side
	self.y = 0
	self.camX = 0
	self.time = 0
	self.colors = c
	self.shader = love.graphics.newShader('shaders/wave_shader.vs')
	self.width = w or FRAME_WIDTH -- span of the wave. may grow bigger. scale w/ difficulty
	self.height = h or FRAME_HEIGHT
	self.view = {} -- % positions of left & right sides of the view?
	self.line = {} -- the bounding line that separates the extreme colors
	self.lineX = 0 -- screen position of wave
	self.flow = {}
	self.tide = {}
	self.ripple = {}
	self.coefficients = {}
	self:setCoefficients()
end

function Wave:update(dt) -- update the wave to follow the moon phase
	-- adjust the position of the waves
	self.time = self.time + dt
	self:flow()
end

function Wave:flow()
	local phase = self.ocean.moon:getPhase()

	local fov = self.ocean.width / self.width -- % amount of the wave seen
	self.x = -(phase - fov / 2) % 1 * self.width

	self.lineX = math.floor(phase * self.width)

end

-- function Wave:reset()
-- 	local phase = self.ocean.moon:getPhase()


-- end

function Wave:setCoefficients(f, t, w)
	for i = 1, 3 do 
		table.insert(self.coefficients, {})
		for j = 1, 2 do
			table.insert(self.coefficients[i], {})
		end
	end

	-- flow - general direction of wave movement



	-- tide - long-period motion of wave
	for i = 1, 2 do -- tide.x[i] = sin/cos(time*[1]+[2])*[3]
		self.coefficients[2][1][i] = {}
		self.coefficients[2][1][i][1] = math.random()*0.2+0.1
		self.coefficients[2][1][i][2] = math.random()*math.pi
		self.coefficients[2][1][i][3] = 0.05
	end
	for i = 1, 2 do -- tide.y[i]

	end

	-- ripple - small wave motions
	for i = 1, 4 do -- wave.x[i] = sin/cos((st.y+[1])*[2]*PI+time*[3])*[4]*cos/sin(time*[5]+[6])
		self.coefficients[3][1][i] = {}
		self.coefficients[3][1][i][1] = math.random()
		self.coefficients[3][1][i][2] = math.random()*2+2
		self.coefficients[3][1][i][3] = math.random()*0.1+0.01
		self.coefficients[3][1][i][4] = 0.005
		self.coefficients[3][1][i][5] = math.random(1)*0.5+0.25
		self.coefficients[3][1][i][6] = math.random()
	end
	for i = 1, 2 do -- wave.y[i] = sin/cos((st.x+[1])*[2]*PI+time*[3])*[4]*cos(time*[5]+[6])
		self.coefficients[3][2][i] = {}
		self.coefficients[3][2][i][1] = math.random()
		self.coefficients[3][2][i][2] = math.random()*8+2
		self.coefficients[3][2][i][3] = math.random()*0.02+0.01
		self.coefficients[3][2][i][4] = 0.5
		self.coefficients[3][2][i][5] = math.random()*0.5+0.25
		self.coefficients[3][2][i][6] = math.random()
	end
end

function Wave:render()
	love.graphics.push()
	love.graphics.setColor(1, 1, 1, 1)
	-- love.graphics.setColor(0, 0, 0, 1)

	love.graphics.setShader(self.shader) -- shader for the water
	self.shader:send('waveResolution', {self.width, self.height})
	self.shader:send('wavePosition', {self.x, self.y})
	self.shader:send('flow', self.coefficients[1])
	self.shader:send('tide', self.coefficients[2])
	self.shader:send('ripple', self.coefficients[3])
	self.shader:send('offset', {self.ocean.x, self.ocean.y})
	self.shader:send('time', self.time)
	self.shader:send('color1', self.colors[1])
	self.shader:send('color2', self.colors[2])

	love.graphics.rectangle('fill', self.ocean.x, self.ocean.y, self.ocean.width, self.ocean.height)

	love.graphics.pop()

	love.graphics.setShader()
end