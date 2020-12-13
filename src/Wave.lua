Wave = Class{}

-- the wave is the play area that is only partially represented

function Wave:init(params, colors)
	-- self.ocean = f
	self.width = params.width -- span of the wave. may grow bigger. scale w/ difficulty
	self.height = params.height
	self.x = 0 -- x position of wave on the left side
	self.y = 0 -- y position of wave on the top side
	self.theta = math.pi
	self.colors = colors
	self.shader = love.graphics.newShader('shaders/wave_shader.vs')
	-- self.view = {} -- % positions of left & right sides of the view?
	-- self.line = {} -- the bounding line that separates the extreme colors
	-- self.lineX = 0 -- screen position of wave
	self.tide = {0, 0}
	self.vars = {}
	self:setVariables()
end

function Wave:update(dt) -- update the wave to follow the moon phase
	self:updateTide(dt)
	self:flow()
end

function Wave:flow() -- adjust the position of the waves
	-- local phase = self.ocean.moon.phase -- phase determines force of the wave
	-- local fov = self.ocean.width / self.width -- % amount of the wave seen
	-- self.x = -(phase+fov/2)%1*self.width

	-- move to tide instead
	self.x = lerp(0, self.width-self.ocean.width, self.tide[1])
end

-- function Wave:reset()
-- 	local phase = self.ocean.moon:getPhase()

-- end

function Wave:updateTide(dt) -- update the tide
	-- local tidesVars = self.vars[1]
	local force = -math.cos(self.ocean.moon.phase*math.pi*2) -- maybe change phase range to -1-1 in Moon.lua
	local tideVars = self.vars[1][1][1]
	local tide = {0, 0}
	local dtheta

	-- for i = 1, 2 do
	-- 	for k, tideVars in pairs(tidesVars[i]) do
	-- 		tide[i] = tide[i] + math.sin(self.time*tideVars[1]+tideVars[2])*tideVars[3]
	-- 	end
	-- end

	-- only doing 1 x tide for now
	dtheta = dt*force*tideVars[1]
	self.theta = (self.theta+dtheta)%(math.pi*2)
	tide[1] = math.sin(self.theta)
	tide[1] = (tide[1]+1)*0.5 -- adjustment to 0-1 range

	self.tide = tide
end

function Wave:setVariables(f, t, w)
	for i = 1, 2 do 
		table.insert(self.vars, {})
		for j = 1, 2 do
			table.insert(self.vars[i], {})
		end
	end

	-- tide - long-period motion of wave
	for i = 1, 2 do -- tide.x[i] = sin(time*[1]+[2])*[3]
		self.vars[1][1][i] = {}
		self.vars[1][1][i][1] = math.random()*0.1+0.05
		self.vars[1][1][i][2] = math.random()*math.pi*2
		self.vars[1][1][i][3] = 0.05
	end
	for i = 1, 2 do -- tide.y[i] = sin(time*[1]+[2])*[3]
		self.vars[1][2][i] = {}
		self.vars[1][2][i][1] = math.random()*0.15+0.05
		self.vars[1][2][i][2] = math.random()*math.pi*2
		self.vars[1][2][i][3] = 0.05
	end

	-- ripple - small wave motions
	for i = 1, 4 do -- ripple.x[i] = sin(st.y*[1]*2.*PI+[2]+time*[3])*[4]*cos(time*[5]+[6])
		self.vars[2][1][i] = {}
		self.vars[2][1][i][1] = math.random()+0.5
		self.vars[2][1][i][2] = math.random()*math.pi*2
		self.vars[2][1][i][3] = math.random()*0.1+0.01
		self.vars[2][1][i][4] = 0.002
		self.vars[2][1][i][5] = math.random()*0.5+0.25
		self.vars[2][1][i][6] = math.random()*math.pi*2
	end
	for i = 1, 2 do -- ripple.y[i] = sin(st.x*[1]*2.*PI+[2]+time*[3])*[4]*cos(time*[5]+[6])
		self.vars[2][2][i] = {}
		self.vars[2][2][i][1] = math.random(8)+2
		self.vars[2][2][i][2] = math.random()*math.pi*2
		self.vars[2][2][i][3] = math.random()*0.02+0.01
		self.vars[2][2][i][4] = 0.5
		self.vars[2][2][i][5] = math.random()*0.5+0.25
		self.vars[2][2][i][6] = math.random()*math.pi*2
	end
end

function Wave:render()
	love.graphics.push()
	love.graphics.setColor(1, 1, 1, 1)
	-- love.graphics.setColor(0, 0, 0, 1)


	local ripX = self.vars[2][1]
	local ripY = self.vars[2][2]

	love.graphics.setShader(self.shader) -- shader for the water
	self.shader:send('waveResolution', {self.width, self.height})
	self.shader:send('wavePosition', {self.x, self.y})
	self.shader:send('offset', {self.ocean.x, self.ocean.y})
	-- self.shader:send('tideX1', self.vars[1][1][1])
	-- self.shader:send('tideX2', self.vars[1][1][2])
	-- self.shader:send('tideY1', self.vars[1][2][1])
	-- self.shader:send('tideY2', self.vars[1][2][2])
	self.shader:send('tide', self.tide)
	self.shader:send('ripX1', ripX[1][1], ripX[1][2], ripX[1][3], ripX[1][4], ripX[1][5], ripX[1][6])
	self.shader:send('ripX2', ripX[2][1], ripX[2][2], ripX[2][3], ripX[2][4], ripX[2][5], ripX[2][6])
	self.shader:send('ripX3', ripX[3][1], ripX[3][2], ripX[3][3], ripX[3][4], ripX[3][5], ripX[3][6])
	self.shader:send('ripX4', ripX[4][1], ripX[4][2], ripX[4][3], ripX[4][4], ripX[4][5], ripX[4][6])
	self.shader:send('ripY1', ripY[1][1], ripY[1][2], ripY[1][3], ripY[1][4], ripY[1][5], ripY[1][6])
	self.shader:send('ripY2', ripY[2][1], ripY[2][2], ripY[2][3], ripY[2][4], ripY[2][5], ripY[2][6])
	self.shader:send('time', self.ocean.time)
	self.shader:send('color1', self.colors[1])
	self.shader:send('color2', self.colors[2])

	love.graphics.rectangle('fill', self.ocean.x, self.ocean.y, self.ocean.width, self.ocean.height)

	love.graphics.pop()

	love.graphics.setShader()
end