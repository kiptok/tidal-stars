Moon = Class{}

-- the heart/beat

function Moon:init()
	self.x = x
	self.y = y
	self.dx = 0
	self.dy = 0
	self.phase = 0
	self.colors = {
		{
			math.random(), math.random(), math.random(), 1
		},
		{
			math.random(), math.random(), math.random(), 1
		}
	}
	self.light = {} -- points per color
	self.dark = {}
	-- self.points
	self:make()
end

function Moon:update(dt)
	self:phase(dt)
end

function Moon:make() -- initialize points
	for i = 1, MOON_RADIUS do -- fill the moon
		for j = 1, MOON_RADIUS do
			local dx = MOON_RADIUS - j
			local dy = MOON_RADIUS - i
			local d = math.sqrt(dx*dx+dy*dy)
			if d <= MOON_RADIUS then -- add points here for all 4
				table.insert(self.light, {i-1, j-1})
				table.insert(self.light, {i-1, MOON_RADIUS*2-j})
				table.insert(self.light, {-i, j-1})
				table.insert(self.light, {-i, MOON_RADIUS*2-j})
			end
	end
	-- 4x the 1/4 arc
end

function Moon:shine() -- cast light on the playing field

end

function Moon:phase(dt) -- elapse time as the shadow moves on the moon
	self.phase = (self.phase + dt) % month
end

function Moon:render()
	love.graphics.circle("fill", self.x, self.y, MOON_RADIUS)
end