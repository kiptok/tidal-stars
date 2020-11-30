Field = Class{}

function Field:init(d, w, p, r)
	-- points with color values
	self.width = w or FRAME_WIDTH
	self.height = FRAME_HEIGHT
	self.x = (VIRTUAL_WIDTH-self.width)/2
	self.y = (VIRTUAL_HEIGHT-self.height)/2
	self.difficulty = 1
	self.period = p or LUNA_PERIOD
	self.radius = r or LUNA_RADIUS
	self.duration = d or 60
	self.stars = {}
	self.colors = {}
	self.bg = {1, 1, 1, 1}
	self:clear()
	self:fill()
	self.moon = Moon(self.colors, self.period, self.radius, self)
	self.wave = Wave(self.colors, self.width, self)
	self.song = Song(self.duration)
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

function Field:fill()

	self:makeColors()
	self:makeStars(20)
end

function Field:clear()
	self.bg = {1, 1, 1, 1}
	love.graphics.setColor(self.bg)
	love.graphics.rectangle('fill',  128, 96, FRAME_WIDTH, FRAME_HEIGHT)
end

function Field:makeColors()
	local dColor = 0
	while dColor < 1 do
		self.colors[1] = {math.random(), math.random(), math.random(), 1} -- 'dark'
		self.colors[2] = {math.random(), math.random(), math.random(), 1} -- 'light'
		for i = 1, 3 do
			dColor = dColor + abs(self.colors[1][i] - self.colors[2][i])
		end
	end
end

function Field:makeStars(k)
	for i = 1, k do
		local x = math.random(self.wave.width)
		local y = math.random(self.height)
		local s = math.random(STAR_SIZE_MIN, STAR_SIZE_MAX)
		local n = math.round(math.random(s*s*0.25, s*s))
		local c = lerpColor(self.colors[1], self.colors[2], math.random())
		table.insert(self.stars, Star(x, y, s, n, c))
	end
end

-- -- loop?
-- function Field:loop()
-- 	self.playMode = 'loop'
-- 	while not self.points[1] do
-- 		table.remove(self.points, 1)
-- 	end
-- 	for k, point in pairs(self.points) do
-- 		point.playMode = 'loop'
-- 	end
-- end

function Field:render()
	-- draw frame border - image?

	-- draw frame inside
	self.bg = {1, 1, 1, 1}
	love.graphics.rectangle('fill', self.x, self.y, self.width, self.height)

	self.wave:render()
	for k, star in pairs(self.stars) do
		star:render()
	end
	self.moon:render()
end