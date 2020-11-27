Beat = Class{__includes = Point}

-- visible entity that mixes color and triggers sounds
-- one beat can have multiple locations

function Beat:init(h0, h1, b, n)
	-- beats per minute
	self.bpm = b
	self.spb = 60 / self.bpm
	self.count = 0
	self.direction = true
	self.number = n
	self.h0 = h0
	self.h1 = h1
	self.points = {} -- represents 
	self.path = {}
	self.playMode = pm
	-- self.colors = {}
	-- self.x = {}
	-- self.y = {}
	for k = 1, self.number do
		-- table.insert(self.colors, {1, 1, 1, 1})
		table.insert(self.points, Point(0, 0, {1, 1, 1, 1}))
	end

	-- require motion function? i.e. speed on the wire
end

-- the beat(s) move(s) across the wire, visible
-- change color for its position between the hearts and maybe other factors
-- need to rewrite this esp w/r/t direction, position, start, finish

function Beat:update(dt)
	if self.playMode == 'play' then
		-- allow changing # of beats
		self.spb = 60 / self.bpm
		self.count = self.count + dt
		-- beat reverses direction when it reaches a heart
		if self.count >= self.spb then
			self.direction = not self.direction
			self.count = self.count % self.spb
		end
		-- sine function
		-- local position = math.abs(math.sin(math.pi / 2 * self.count / self.spb))
		-- position on wire based on count & seconds/beat

		local start = self.direction and self.h0 or self.h1
		local finish = self.direction and self.h1 or self.h0
		local root = self.count / self.spb

		for k = 1, self.number do

			-- position from 0 to 1 + offset from 0 to 2
			local offset = lerp(0, 2, (k - 1) / self.number)
			local position = root + offset
			-- adjust position to fit
			if position > 2 then
				position = position % 2
			elseif position > 1 then
				position = 2 - position
			end

			local x
			local y
			local color = {}
			-- local luminosity = math.random() / 20
			local luminosity = 0
			local alphaRange = {0, 1}

			-- if hearts are distant
			if #self.path > 0 then
				-- xy is part of the wire
				local xy = self.path[round(lerp(1, #self.path, position))]
				if not self.direction then
					xy = self.path[round(lerp(#self.path, 1, position))]
				end
				x = xy[1]
				y = xy[2]
			-- if hearts overlap
			else
				x = self.h0.x
				y = self.h0.y
				position = 0.5
			end	

			-- interpolate color
			for j = 1, 3 do
				table.insert(color, lerp(start.color[j], finish.color[j], position))
			end

			-- set alpha range
			-- based on distance
			-- frames per beat (approx.)
			local fpb = fps * self.spb
			alphaRange[1] = #self.path / fpb / 8 -- need a more complex function here
			-- alphaRange[2] = math.random() + 0.5
			alphaRange[2] = 1

			-- random alpha
			table.insert(color, math.random())
			self.points[k] = Point(x, y, color, alphaRange)
		end
	end
end

function Beat:loop()
	self.playMode = 'loop'
	for k = 1, self.number do
		table.remove(self.points, 1)
	end
end

function Beat:toTable()
	local points = {}
	for k = 1, self.number do
		table.insert(points, self.points[k])
	end
	return points
end

function Beat:render()
	if self.playMode == 'play' then
		for k = 1, self.number do
			self.points[k]:render()
		end
	end
end