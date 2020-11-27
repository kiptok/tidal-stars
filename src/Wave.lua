local shader_code = [[

extern vec4 color1;
extern vec4 color2;

vec4 effect(vec4 color, Image texture, vec2 tc, vec2 _) {


	return color;
}

]]

Wave = Class{}

function Wave:init(c1, c2)
	self.colors = {c1, c2}
	self.shader = love.graphics.newShader('shader_code')
	self.line = {} -- the wave that separates the extreme colors
end

function Wave:update(dt)

end

function Wave:render()
	love.graphics.setShader(self.shader) -- shader for the water
	self.shader:send('field' ) -- give coordinates adjusted for the wave

	love.graphics.setShader()
end