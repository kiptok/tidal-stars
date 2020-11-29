Star = Class{}

function Star:init(x, y, s, m, c)
	self.x = x -- center of points
	self.y = y
	self.size = s -- maximum radius of points from center
	self.number = n -- # of points
	self.color = {c} -- principal color
	self.dcolor = 16 -- some # indicating how much the color changes
	self.points = {} -- collection of points that aggregate around the center
	self.collected = false
	self.next = false
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