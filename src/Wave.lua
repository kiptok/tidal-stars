local shader_code = [[

extern vec4 color1;
extern vec4 color2;

vec4 effect(vec4 color, Image texture, vec2 tc, vec2 _) {


	return color;
}

]]

Wave = Class{}

function Wave:init(m, c, w)
	self.x = 0
	self.y = 0
	self.colors = c
	self.shader = love.graphics.newShader('shader_code')
	self.line = {} -- the bounding line that separates the extreme colors
	self.width = w or VIRTUAL_WIDTH -- span of the wave. may grow bigger
	self.moon = m
end

function Wave:update(dt) -- update the wave to follow the moon phase
	-- get the moon phase
	local phase = self.moon:getPhase()
	-- adjust the position of the waves
	
	
end

function Wave:render()
	love.graphics.setShader(self.shader) -- shader for the water
	self.shader:send('field' ) -- give coordinates adjusted for the wave

	love.graphics.setShader()
end