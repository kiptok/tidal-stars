local shader_code = [[

extern vec4 color1;
extern vec4 color2;

vec4 effect(vec4 color, Image texture, vec2 tc, vec2 _) {


	return color;
}

]]

Wave = Class{}

function Wave:init(m, c1, c2)
	self.colors = {c1, c2}
	self.shader = love.graphics.newShader('shader_code')
	self.line = {} -- the bounding line that separates the extreme colors
	self.width = VIRTUAL_WIDTH -- span of the wave. may grow bigger
	self.moon = m
end

function Wave:update(dt) -- update the wave to follow the moon phase

end

function Wave:render()
	love.graphics.setShader(self.shader) -- shader for the water
	self.shader:send('field' ) -- give coordinates adjusted for the wave

	love.graphics.setShader()
end