Field = Class{}

function Field:init(d)
	-- points with color values
	self.map = {} -- matrix
	self.points = {} -- 
	self.stars = {}
	self.duration = d or 9999
	self.bg = {0, 0, 0, 1}
	self:clear()
end

function Field:update(dt)
	for k, star in pairs(self.stars) do
		if star then
			star:update(dt)
		end
	end

	for k, point in pairs(self.points) do
		if point then
			point:update(dt)
		end
	end
end

function Field:fill()
	
end

function Field:clear()
	self.map = {}
	-- might have to change this matrix-based indexing of points to a stack?
	for y = 1, VIRTUAL_HEIGHT do
		local row = {}
		for x = 1, VIRTUAL_WIDTH do
			table.insert(row, false)
		end
		table.insert(self.map, row)
	end
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
function Field:loop()
	self.playMode = 'loop'
	while not self.points[1] do
		table.remove(self.points, 1)
	end
	for k, point in pairs(self.points) do
		point.playMode = 'loop'
	end
end

function Field:mapToMatrix()
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
function Field:pointsToCells()
	local cells = {} -- {cells{xyrgba}}
		for k, point in pairs(self.points) do
			table.insert(cells, point:xyrgba())
		end
	return cells
end

function Field:render()
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