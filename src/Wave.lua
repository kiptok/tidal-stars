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
	self.offsetX = self.field.width / 2 -- offset to set the edge of the wave in the middle
	self.colors = c
	self.shader = love.graphics.newShader('shader_code')
	self.line = {} -- the bounding line that separates the extreme colors
	self.width = w or VIRTUAL_WIDTH -- span of the wave. may grow bigger. scale w/ difficulty
	self.moon = self.field.moon
	self.waveX = self.moon:getPhase() * self.width -- position of wave
end

function Wave:update(dt) -- update the wave to follow the moon phase
	-- adjust the position of the waves
	self:flow(phase)
	
end

function Wave:flow()
	-- get the moon phase
	self.waveX = self.moon:getPhase() * self.width

	-- plus the offset this is where the middle of the wave is

end

function Wave:render()
	love.graphics.setShader(self.shader) -- shader for the water
	self.shader:send('waveX' ) -- give coordinates adjusted for the wave

	love.graphics.setShader()
end