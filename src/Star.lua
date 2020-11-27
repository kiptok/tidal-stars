Star = Class{}

function Star:init(x, y, s, m, c)
	self.x = x
	self.y = y
	self.size = s
	self.number = n -- # of points
	self.colors = {c}
	self.points = {}
	self.collected = false
	for k = 1, self.number do
		table.insert(self.points, Point(0, 0, {1, 1, 1, 1}))
	end
end

function Star:update(dt)

end

function Star:make()	-- function to distribute points around the center, creating a semi-cohesive body
	for k, point in pairs(self.points) do

	end
end