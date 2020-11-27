Song = Class{}

-- plays music, holds wires and draws points

function Song:init(d)
	-- points with color values
	self.map = {} -- matrix
	self.points = {} -- 
	self.wires = {}
	self.duration = d or 9999999 -- 2777.7775 hours
	self.bg = {0, 0, 0, 1}
	self.playMode = pm
	self:clear()
end

function Song:update(dt)
	if self.playMode == 'play' then
		-- add the beat point if it would be on screen
		for k, point in pairs(beat.points) do
			if point.x >= 0 and point.x < VIRTUAL_WIDTH and point.y >= 0 and point.y < VIRTUAL_HEIGHT then
				self.map[point.y + 1][point.x + 1] = point
				table.insert(self.points, point)
			end
		end

		-- remove dead points from table
		while not self.points[1] do
			table.remove(self.points, 1)
		end

		-- update points
		-- for k, row in pairs(self.map) do
		-- 	for j, point in pairs(row) do
		-- 		if point then
		-- 			point:update(dt)
		-- 		end
		-- 	end
		-- end
		for k, point in pairs(self.points) do
			if point then
				point:update(dt)
			end
		end
	elseif self.playMode == 'loop' then
		for k, point in pairs(self.points) do
			if point then
				point:update(dt)
			end
		end
	end
end

function Song:clear()
	self.map = {}
	-- might have to change this matrix-based indexing of points to a stack?
	for y = 1, VIRTUAL_HEIGHT do
		local row = {}
		for x = 1, VIRTUAL_WIDTH do
			table.insert(row, false)
		end
		table.insert(self.map, row)
	end
	self.wires = {}
	if math.random(2) == 1 then
		-- day
		self.bg = {1, 1, 1, 1}
	else
		-- night
		self.bg = {0, 0, 0, 1}
	end
	love.graphics.setColor(self.bg)
    love.graphics.rectangle('fill', 0, 0, VIRTUAL_WIDTH, VIRTUAL_HEIGHT)
end

-- loop?
function Song:loop()
	self.playMode = 'loop'
	while not self.points[1] do
		table.remove(self.points, 1)
	end
	for k, point in pairs(self.points) do
		point.playMode = 'loop'
	end
end

function Song:mapToMatrix()
	local matrix = {} -- {rows{cells{values}}}
	for k, row in pairs(self.map) do
		local r = {}
		for j, point in pairs(row) do
			local cell -- x, y, r, g, b, a
			if point then
				cell = point:xyrgba()
			else
				cell = {j-1, k-1, 0, 0, 0, 1}
			end
			table.insert(r, cell)
		end
		table.insert(matrix, r)
	end
	return matrix
end

-- for Max: return string of form 'point# x y r g b a [count] [period]'
function Song:pointsToCells()
	local cells = {} -- {cells{xyrgba}}
		for k, point in pairs(self.points) do
			table.insert(cells, point:xyrgba())
		end
	return cells
end

function Song:render()
	for k, row in pairs(self.map) do
		for j, point in pairs(row) do
			if point then -- remove/unanimate point
				if point.life > self.duration then
					love.graphics.setColor(0, 0, 0, 1)
					love.graphics.points(point.x, point.y)
					point = false
				else
					point:render()
				end
			end
		end
	end

	for k, wire in pairs(self.wires) do
		wire:render()
	end
end