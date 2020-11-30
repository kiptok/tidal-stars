local shader_code = [[

extern vec4 color1;
extern vec4 color2;

vec4 effect(vec4 color, Image texture, vec2 tc, vec2 _) {


	return color;
}

]]

Wave = Class{}

function Wave:init(c, w, f)
	self.field = f
	self.x = self.field.x
	self.y = self.field.y
	self.waveOffset = self.field.width / 2 -- offset to set the edge of the wave in the middle
	self.colors = c
	self.shader = love.graphics.newShader('shader_code')
	self.line = {} -- the bounding line that separates the extreme colors
	self.width = w or VIRTUAL_WIDTH -- span of the wave. may grow bigger. scale w/ difficulty
	self.moon = self.field.moon
	self.lineX = self.moon:getPhase() * self.width -- position of wave
end

function Wave:update(dt) -- update the wave to follow the moon phase
	-- adjust the position of the waves
	self:flow(phase)
	
end

function Wave:flow()
	-- get the moon phase to determine the middle of the wave
	self.lineX = self.moon:getPhase() * self.width

	-- plus the offset this is where the middle of the wave is e.g. at 0 the wave is in the middle

end

function Wave:render()
	love.graphics.setShader(self.shader) -- shader for the water
	self.shader:send('lineX', self.lineX) -- give coordinates adjusted for the wave
	-- self.shader:send('time', )

	love.graphics.setShader()
end