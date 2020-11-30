local shader_code = [[

extern vec4 color1;
extern vec4 color2;
extern float line;

vec4 effect(vec4 color, Image texture, vec2 tc, vec2 _) {




	return color;
}

]]

Wave = Class{}

-- the wave is the play area that is only partially represented

function Wave:init(c, w)
	-- self.field = f
	-- self.x = self.field.x -- position to draw on screen
	-- self.y = self.field.y
	self.camX = 0
	self.camY = 0
	-- self.waveOffset = self.field.width / 2 -- offset to set the edge of the wave in the middle
	self.colors = c
	self.shader = love.graphics.newShader('shader_code')
	self.view = {} -- % positions of left & right sides of the view?
	self.line = {} -- the bounding line that separates the extreme colors
	self.width = w or VIRTUAL_WIDTH -- span of the wave. may grow bigger. scale w/ difficulty
	-- self.moon = self.field.moon
	-- self.lineX = self.moon:getPhase() * self.width -- position of wave
end

function Wave:update(dt) -- update the wave to follow the moon phase
	-- adjust the position of the waves
	self:flow()

end

function Wave:flow()
	local phase = self.field.moon:getPhase()

	local fov = self.field.width / self.width -- amount of the wave seen
	self.view[1] = (phase - (round(fov / 2))) % 1
	self.view[2] = (phase + (round(fov / 2))) % 1

	-- self.lineX = -self.moon:getPhase() % 1 * self.width
	self.lineX = math.floor(-phase * self.width)

	-- plus the offset this is where the middle of the wave is e.g. at 0 the wave is in the middle

	-- get the moon phase to determine the middle of the wave
	self.camX = math.floor(phase * self.width)


	-- draw 2 rectangles if view[2] < view[1] ? or something

end

function Wave:render()
	love.graphics.push()

	love.graphics.setShader(self.shader) -- shader for the water
	self.shader:send('lineX', self.lineX) -- give coordinates adjusted for the wave
	self.shader:send('color1')
	self.shader:send('color2')
	-- self.shader:send('time', )
	love.graphics.rectangle('fill', self.field.x, self.field.y, self.field.width, self.field.height)

	love.graphics.translate(-math.floor(self.camX), -math.floor(self.camY))

	love.graphics.pop()

	love.graphics.setShader()
end