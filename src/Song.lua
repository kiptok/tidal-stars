Song = Class{}

function Song:init(d)
	-- points with color values
	self.duration = d or 9999
	self.stars = {}
	self.tempo = t or 120
	self:clear()
end

function Song:update(dt)

end

function Song:fill()
	
end

function Song:clear()

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

-- for Max: return string of form 'point# x y r g b a [count] [period]'

function Song:render() -- show collected stars

end