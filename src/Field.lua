local shader_code = [[

extern vec4 color1;
extern vec4 color2;
extern float time;

#define PI 3.1415926535

float random (vec2 st) {
  return fract(sin(dot(st.xy, vec2(12.9898,78.233)))*43758.5453123);
}

vec4 effect(vec4 color, Image texture, vec2 tc, vec2 st) {
	st = st / love_ScreenSize.xy;

  float pct = smoothstep(0.0, 0.5, fract(st.x+time*0.04));
  pct += smoothstep(1.0, 0.5, fract(st.x+time*0.04));

	// st.x -= smoothstep(0.6, 0.8, st.x);

	color = mix(color1, color2, pct);
	return color;
}

]]

Field = Class{}

function Field:init(moon, wave, stars, song)
	self.width = FRAME_WIDTH
	self.height = FRAME_HEIGHT
	self.x = (VIRTUAL_WIDTH-self.width)/2
	self.y = (VIRTUAL_HEIGHT-self.height)/2
	self.borderColors = {}
	self.moon = moon
	self.wave = wave
	self.stars = stars
	self.song = song
	self.shader = love.graphics.newShader(shader_code)
	self.bg = {1, 1, 1, 1}
	self.time = 0
	self:clear()
end

function Field:update(dt)
	self.time = self.time + dt
	self.moon:update(dt)
	self.wave:update(dt)
	for k, star in pairs(self.stars) do
		if star then
			if star.next then
				if gameX < self.x + star.waveX - self.wave.x + star.radius and gameX > self.x + star.waveX - self.wave.x - star.radius then
					if gameY < self.y + star.y + star.radius and gameY > self.y + star.y - star.radius then
						if love.mouse.wasPressed(1) then
							star.collected = true
							star.next = false
							local nextStar = false
							while not nextStar do
								local index = math.random(#self.stars)
								if not self.stars[index].collected then
									self.stars[index].next = true
									nextStar = true
								end
							end
						end
					end
				end
			end
			star:update(dt)
		end
	end


end

function Field:clear()
	self.bg = {1, 1, 1, 1}
	self.borderColors[1] = {math.random(), math.random(), math.random(), 1}
	self.borderColors[2] = {math.random(), math.random(), math.random(), 1}
	love.graphics.setColor(self.bg)
	love.graphics.rectangle('fill',  128, 96, FRAME_WIDTH, FRAME_HEIGHT)
end


function Field:render()


	-- draw frame inside
	self.bg = {0, 0, 0, 1}
	love.graphics.rectangle('fill', self.x, self.y, self.width, self.height)

	self.wave:render()
	for k, star in pairs(self.stars) do
		-- make sure the star is on screen, and translate to its location
		if star.waveX + star.radius >= self.wave.x and star.waveX - star.radius < self.wave.x + self.width then 
			love.graphics.push()
			love.graphics.setColor(1, 1, 1, 1)
			love.graphics.translate(self.x + star.waveX - self.wave.x, self.y + star.y)
			star:render()
			love.graphics.pop()
		end
		if self.wave.x + self.width > self.wave.width then
			local right = (self.wave.x + self.width) % self.wave.width
			if star.waveX + star.radius >= 0 and star.waveX - star.radius < right then
				love.graphics.push()
				love.graphics.setColor(1, 1, 1, 1)
				love.graphics.translate(self.x + star.waveX + self.wave.width - self.wave.x, self.y + star.y)
				star:render()
				love.graphics.pop()
			end
		end -- this can be more concise
	end

	-- draw frame border - image?
	love.graphics.setColor(1, 1, 1, 1)
	love.graphics.setShader(self.shader) -- shader for the water
	self.shader:send('time', self.time)
	self.shader:send('color1', self.borderColors[1])
	self.shader:send('color2', self.borderColors[2])

	local bw = (VIRTUAL_WIDTH - self.width) / 2 -- border width
	local bh = (VIRTUAL_HEIGHT - self.height) / 2 -- border height

	love.graphics.rectangle('fill', self.x - bw, self.y - bh, self.width + bw * 2, bh)
	love.graphics.rectangle('fill', self.x - bw, self.y + self.height, self.width + bw * 2, bh)
	love.graphics.rectangle('fill', self.x - bw, self.y, bw, self.height)
	love.graphics.rectangle('fill', self.x + self.width, self.y, bw, self.height)
	love.graphics.setShader()


	self.moon:render()
end