Song = Class{}

-- local durWeights = {0, 0.25, 0.5, 0.25, 0} -- 1, 1/2, 1/4, 1/8, 1/16
-- local stepWeights = {1/15, 1/15, 1/15, 1/15, 1/15, 1/15, 1/15, 1/15, 1/15, 1/15, 1/15, 1/15, 1/15, 1/15, 1/15}
	-- -7, -6, .. 6, 7
-- local velWeights = {}

function Song:init(params, colors)
	self.numBars = params.numBars
	self.key = params.key
	self.scale = params.scale
	self.bar = params.bar -- last bar of stars? then the stars add to the score
	self.colors = colors
	self.score = {} -- table of stars
	self.barCount = 0
	self.count = 0
	self.playing = false
	-- self.tempo = t or 120
	self:clear()
end

function Song:update(dt)
	love.audio.setPosition(self.ocean.wave.x+self.ocean.width/2, self.ocean.height/2, 0)
	local db = dt / spb -- dt converted to beats
	if not self.playing then
		self.count = 0
	elseif self.playing == 'bar' then -- play current bar
		self:playBar(db)
	elseif self.playing == 'score' then -- play current score
		self:playScore(db)
	end
end

-- function Song:fill()
	
-- end

-- move current bar to score, add new bar
function Song:addBar()
	local lastBar = self.bar
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
		if durChoice < 0.2 then  -- adjust these values based on level etc.
			dur = 2 -- 1/2 note
		elseif durChoice < 0.4 then
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
			sound = starSounds[math.random(2)], -- vary this later
			attenuation = {self.ocean.wave.width*0.05, self.ocean.wave.width*0.175},
			next = true
		}
		local starColor = {math.random(), math.random(), math.random(), 1}
		local star = Star(starParams, starColor)
		table.insert(self.bar, star)
		lastNote = star.note
		i = i+dur
	end
	self.barCount = self.barCount + 1
end

function Song:recordBar(b)
	local bar = b
	for k, star in pairs(bar) do
		table.insert(self.score, star)
	end
end

function Song:playBar(db)
	local position = 0
	for k, star in pairs(self.bar) do
		if position >= self.count and position < self.count + db then -- if count is crossing the attack
			star:play(true)
		end
		position = position + star.note.dur
	end
	self.count = self.count + db
	if self.count >= 4 then
		self.count = 0
		self.playing = false
	end
end


function Song:playScore(db)
	local position = 0
	for k, star in pairs(self.score) do
		if position >= self.count and position < self.count + db then
			star:play(true)
		end
		position = position + star.note.dur
	end
	self.count = self.count + db
	if self.count >= self.barCount * 4 then
		self.count = 0
		self.playing = false
	end
end

function Song:clear()
	self.score = {}
	self.count = 0
end

function Song:restart()
	for k, star in pairs(self.score) do
		star.voice:stop()
	end
	for k, star in pairs(self.bar) do
		star.voice:stop()
	end
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