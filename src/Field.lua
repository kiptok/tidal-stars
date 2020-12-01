Field = Class{}

function Field:init(moon, wave, stars, song)
	self.width = FRAME_WIDTH
	self.height = FRAME_HEIGHT
	self.x = (VIRTUAL_WIDTH-self.width)/2
	self.y = (VIRTUAL_HEIGHT-self.height)/2
	self.moon = moon
	self.wave = wave
	self.stars = stars
	self.song = song
	self.bg = {1, 1, 1, 1}
	self:clear()
end

function Field:update(dt)


	self.moon:update(dt)
	self.wave:update(dt)
	for k, star in pairs(self.stars) do
		if star then
			if star.next then
				if gameX < star.x + star.radius and gameX > star.x - star.radius then
					if gameY < star.y + star.radius and gameY > star.y - star.radius then
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

	local bw = (VIRTUAL_WIDTH - self.width) / 2 -- border width
	local bh = (VIRTUAL_HEIGHT - self.height) / 2 -- border height

	love.graphics.rectangle('fill', self.x - bw, self.y - bh, self.width + bw * 2, bh)
	love.graphics.rectangle('fill', self.x - bw, self.y + self.height, self.width + bw * 2, bh)
	love.graphics.rectangle('fill', self.x - bw, self.y, bw, self.height)
	love.graphics.rectangle('fill', self.x + self.width, self.y, bw, self.height)


	self.moon:render()
end