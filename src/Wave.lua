local shader_code = [[

extern vec4 color1;
extern vec4 color2;
extern vec2 waveResolution;
extern vec2 wavePosition;
extern vec2 offset;
extern float time;

#define PI 3.1415926535

float random (vec2 st) {
  return fract(sin(dot(st.xy, vec2(12.9898,78.233)))*43758.5453123);
}

float easeInOutCirc (float x) {
	return x < 0.5
  	? (1 - sqrt(1 - pow(2 * x, 2))) / 2
  	: (sqrt(1 - pow(-2 * x + 2, 2)) + 1) / 2;
}

float easeInOutCubic (float x) {
	return x < 0.5 ? 4 * x * x * x : 1 - pow(-2 * x + 2, 3) / 2;
}

vec4 effect(vec4 color, Image texture, vec2 tc, vec2 st) {
	st -= offset;
	st += wavePosition;
	st = st / waveResolution;

	vec2 wave; // wave is an offset
	float wave1 = sin(st.y*2.*PI+time*0.07)*0.005*cos(time*0.47);
	float wave2 = sin((st.y+0.031)*2.7*PI+time*0.061)*0.005*cos(time*0.39+0.117);
	float wave3 = cos((st.y+0.337)*3.7*PI+time*0.037)*0.005*sin(time*0.53+0.571);
	float wave4 = cos((st.y+0.829)*3.1*PI+time*0.051)*0.005*sin(time*0.21+0.883); // randomize the values here
	wave.x = wave1 + wave2 + wave3 + wave4;

	float waveX1 = sin(st.x*4.*PI+time*0.011)*0.5*cos(time*0.39);
	float waveX2 = cos(st.x*8.*PI+time*0.017)*0.5*sin(time*0.35);
	wave.y = wave.y + waveX1 + waveX2;

	float tide = cos(time*0.2)*0.05;
	st += wave;
  st.x += tide;

  float stepscale = 0.4;

	st.x = st.x - smoothstep(0.998, 1.002, st.x);
	st.x = st.x + smoothstep(0.998, 1.002, 1.-st.x);
	st.x = st.x - smoothstep(0.900, 1.000, st.x) * stepscale;
	st.x = st.x + smoothstep(0.900, 1.000, 1.-st.x) * stepscale;
	st.x = st.x - smoothstep(0.800, 0.900, st.x) * stepscale;
	st.x = st.x + smoothstep(0.800, 0.900, 1.-st.x) * stepscale;
	st.x = st.x - smoothstep(0.700, 0.800, st.x) * stepscale;
	st.x = st.x + smoothstep(0.700, 0.800, 1.-st.x) * stepscale;
	st.x = st.x - smoothstep(0.600, 0.700, st.x) * stepscale;
	st.x = st.x + smoothstep(0.600, 0.700, 1.-st.x) * stepscale;
	st.x = st.x - smoothstep(0.500, 0.600, st.x) * stepscale;
	st.x = st.x + smoothstep(0.500, 0.600, 1.-st.x) * stepscale;
	st.x = st.x - smoothstep(0.400, 0.500, st.x) * stepscale;
	st.x = st.x + smoothstep(0.400, 0.500, 1.-st.x) * stepscale;
	st.x = st.x - smoothstep(0.300, 0.400, st.x) * stepscale;
	st.x = st.x + smoothstep(0.300, 0.400, 1.-st.x) * stepscale;
	st.x = st.x - smoothstep(0.200, 0.300, st.x) * stepscale;
	st.x = st.x + smoothstep(0.200, 0.300, 1.-st.x) * stepscale;
	st.x = st.x - smoothstep(0.100, 0.200, st.x) * stepscale;
	st.x = st.x + smoothstep(0.100, 0.200, 1.-st.x) * stepscale;
	st.x = st.x - smoothstep(0.000, 0.100, st.x) * stepscale;
	st.x = st.x + smoothstep(0.000, 0.100, 1.-st.x) * stepscale;

	st.y = st.y - smoothstep(0.75, 1.25, st.y);
	st.y = st.y + smoothstep(0.75, 1.25, 1.-st.y);

	float pct = st.x*st.y;
	color = mix(color1, color2, pct);
	return color;
}

]]

Wave = Class{}

-- the wave is the play area that is only partially represented

function Wave:init(c, w, h)
	-- self.field = f
	self.x = 0 -- x position of wave on the left side
	self.y = 0
	self.camX = 0
	self.time = 0
	-- self.waveOffset = self.field.width / 2 -- offset to set the edge of the wave in the middle
	self.colors = c
	self.shader = love.graphics.newShader(shader_code)
	self.width = w or FRAME_WIDTH -- span of the wave. may grow bigger. scale w/ difficulty
	self.height = h or FRAME_HEIGHT
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

	self.lineX = math.floor(phase * self.width)

end

-- function Wave:reset()
-- 	local phase = self.field.moon:getPhase()


-- end

function Wave:render()
	love.graphics.push()
	love.graphics.setColor(1, 1, 1, 1)
	-- love.graphics.setColor(0, 0, 0, 1)

	love.graphics.setShader(self.shader) -- shader for the water
	-- self.shader:send('frameResolution', {self.field.width, self.field.height})
	self.shader:send('waveResolution', {self.width, self.height})
	self.shader:send('wavePosition', {self.x, self.y})
	self.shader:send('offset', {self.field.x, self.field.y})
	self.shader:send('time', self.time)
	self.shader:send('color1', self.colors[1])
	self.shader:send('color2', self.colors[2])


	-- self.shader:send('line', self.lineX) -- give coordinates adjusted for the wave
	-- self.shader:send('frameResolution', {self.field.width, self.field.height})
	-- self.shader:send('offset', {self.field.x, self.field.y})
	-- self.shader:send('color1', self.colors[1])
	-- self.shader:send('color2', self.colors[2])
	-- self.shader:send('leftPhase', self.x / self.width)
	-- self.shader:send('rightPhase', (self.x + self.field.width) / self.width) -- might be higher than 1
	-- self.shader:send('time', self.time)
	love.graphics.rectangle('fill', self.field.x, self.field.y, self.field.width, self.field.height)

	-- love.graphics.translate(-math.floor(self.camX), 0)

	love.graphics.pop()

	love.graphics.setShader()
end