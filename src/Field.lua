Field = Class{}

function Field:init(d, p, w, r)
	-- points with color values
	self.difficulty = 1
	self.width = w or FRAME_WIDTH
	self.period = p or LUNA_PERIOD
	self.radius = r or LUNA_RADIUS
	self.stars = {}
	self.colors = {}
	self.moon = Moon(self.colors, self.period, self.radius)
	self.wave = Wave(self.moon, self.colors, self.width)
	self.duration = d or 60
	self.bg = {1, 1, 1, 1}
	self:clear()
	self:fill()
end

function Field:update(dt)
	self.moon:update(dt)
	self.wave:update(dt)
	for k, star in pairs(self.stars) do
		if star then
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
		local x = math.random(self.width)
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
	love.graphics.rectangle('fill',  128, 96, FRAME_WIDTH, FRAME_HEIGHT)

	self.wave:render()
	for k, star in pairs(self.stars) do
		star:render()
	end
	self.moon:render()
end