local shader_code = [[

extern vec4 color1;
extern vec4 color2;
extern vec2 fieldResolution;
extern vec2 offset;
extern float leftPhase;
extern float rightPhase;
extern float time;
extern float line;

vec4 effect(vec4 color, Image texture, vec2 tc, vec2 st) {
	st -= offset;
	st = st / fieldResolution;
	float waveX = sin(st.y*10.+time)*0.03; // waveX is an offset
	float lineX = line - offset.x;
	lineX = lineX / fieldResolution.x;
	st.x += waveX;
	float pct = mix(leftPhase, rightPhase, st.x);
	if (lineX < 1.0 && st.x < lineX) {
		pct = mix (leftPhase, 1.0, st.x / lineX);
	}
	if (lineX < 1.0 && st.x > lineX) {
		pct = mix (1.0, rightPhase, (st.x - lineX) / 1.0 - lineX);
	}
	color = mix(color1, color2, pct);
	return color;
}

]]

Wave = Class{}

-- the wave is the play area that is only partially represented

function Wave:init(c, w)
	-- self.field = f
	self.x = 0 -- x position of wave on the left side
	self.camX = 0
	self.time = 0
	-- self.waveOffset = self.field.width / 2 -- offset to set the edge of the wave in the middle
	self.colors = c
	self.shader = love.graphics.newShader(shader_code)
	self.width = w or VIRTUAL_WIDTH -- span of the wave. may grow bigger. scale w/ difficulty
	self.view = {} -- % positions of left & right sides of the view?
	self.line = {} -- the bounding line that separates the extreme colors
	-- self.moon = self.field.moon
	self.lineX = 0 -- screen position of wave
end

function Wave:update(dt) -- update the wave to follow the moon phase
	-- adjust the position of the waves
	self.time = self.time + dt
	self:flow()

end

function Wave:flow()
	local phase = self.field.moon:getPhase()

	local fov = self.field.width / self.width -- % amount of the wave seen
	self.x = -(phase - fov / 2) % 1 * self.width

	-- self.view[1] = (phase - (round(fov / 2))) % 1 -- left & right % positions
	-- self.view[2] = (phase + (round(fov / 2))) % 1

	-- self.lineX = -self.moon:getPhase() % 1 * self.width
	self.lineX = math.floor(phase * self.width)

	-- plus the offset this is where the middle of the wave is e.g. at 0 the wave is in the middle

	-- get the moon phase to determine the middle of the wave
	self.camX = math.floor(phase * self.width)


	-- draw 2 rectangles if view[2] < view[1] ? or something

end

-- function Wave:reset()
-- 	local phase = self.field.moon:getPhase()


-- end

function Wave:render()
	love.graphics.push()
	love.graphics.setColor(1, 1, 1, 1)
	-- love.graphics.setColor(0, 0, 0, 1)

	love.graphics.setShader(self.shader) -- shader for the water
	self.shader:send('line', self.lineX) -- give coordinates adjusted for the wave
	self.shader:send('fieldResolution', {self.field.width, self.field.height})
	self.shader:send('offset', {self.field.x, self.field.y})
	self.shader:send('color1', self.colors[1])
	self.shader:send('color2', self.colors[2])
	self.shader:send('leftPhase', self.x / self.width)
	self.shader:send('rightPhase', (self.x + self.field.width) / self.width) -- might be higher than 1
	self.shader:send('time', self.time)
	love.graphics.rectangle('fill', self.field.x, self.field.y, self.field.width, self.field.height)

	-- love.graphics.translate(-math.floor(self.camX), 0)

	love.graphics.pop()

	love.graphics.setShader()
end