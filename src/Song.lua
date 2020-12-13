Song = Class{}

-- local durWeights = {0, 0.25, 0.5, 0.25, 0} -- 1, 1/2, 1/4, 1/8, 1/16
-- local stepWeights = {1/15, 1/15, 1/15, 1/15, 1/15, 1/15, 1/15, 1/15, 1/15, 1/15, 1/15, 1/15, 1/15, 1/15, 1/15}
	-- -7, -6, .. 6, 7
-- local velWeights = {}

function Song:init(params)
	self.numBars = params.numBars
	self.key = params.key
	self.scale = params.scale
	self.bar = params.bar -- last bar of stars? then the stars add to the score
	self.score = {} -- table of stars
	self.count = 0
	-- self.tempo = t or 120
	self:clear()
end

function Song:update(dt)
	-- local x, y = 
	love.audio.setPosition(self.ocean.wave.x+self.ocean.width/2, self.ocean.height/2, 0)
end

-- function Song:fill()
	
-- end

function Song:addBar()
	local lastBar = self.bar
	for k, star in pairs(self.bar) do -- move the last bar to the score
		table.insert(self.score, star)
	end
	self.bar = {}
	local lastNote = lastBar[#lastBar].note -- only reference to last note rn

	local i = 0 -- beat count
	while i < 4 do
		local pitch, dur, vel

		-- pitch
		local stepChoice = math.random()
		local j = 0
		local step = -7
		while stepChoice > j do
			j = j + STEPWEIGHTS[step]
			step = step + 1
		end
		pitch = lastNote['pitch'] + step

		-- duration
		local durChoice = math.random()
		if durChoice < 0.25 then  -- adjust these values based on level etc.
			dur = 2 -- 1/2 note
		elseif durChoice < 0.75 then
			dur = 1 -- 1/4 note
		else
			dur = 1/2 -- 1/8 note
		end
		if i+dur > 4 then
			dur = 4-i -- make bar exactly 4 beats
		end

		-- velocity
		-- local velChoice = math.random()
		vel = math.random()*0.5+0.5 -- just do this for now

		local note = {
			['pitch'] = pitch,
			['dur'] = dur,
			['vel'] = vel
		}

		local starParams = {
			x = math.random(self.ocean.wave.width),
			y = math.random(self.ocean.wave.height),
			radius = math.random(STAR_RADIUS_MIN, STAR_RADIUS_MAX),
			cycles = math.random(12)+9,
			note = note,
			next = true
		}
		local starColor = {math.random(), math.random(), math.random(), 1}
		local star = Star(starParams, starColor)
		table.insert(self.bar, star)
		i = i+dur
	end
	self.count = self.count + 4
end

-- function Song:addStar()

-- end

function Song:playLastBar()

end

function Song:playEntire()

end

function Song:clear()
	self.score = {}
	self.count = 0
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

function Song:render() -- show collected stars

end