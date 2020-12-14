OceanMaker = Class{}

function OceanMaker.generate(l, m, mc, fc)
	local level = l
	local moonParams = m
	local waveWidth = level * FRAME_WIDTH * 10
	local waveHeight = FRAME_HEIGHT
	local period = moonParams.period
	local radius = moonParams.radius
	local colors = fc or false
	local difference

	-- difficulty-adjustable settings
	local numBars = level*4
	local minRGBDiff = 1.6

	-- set ocean colors randomly with minimum difference
	if not colors then
		colors = {}
		local dColor = 0
		while dColor < minRGBDiff do
			colors[1] = {math.random(), math.random(), math.random(), 1} -- 'dark'
			colors[2] = {math.random(), math.random(), math.random(), 1} -- 'light'
			dColor = colorDifference(colors[1], colors[2])[1]
		end
	end
	difference = colorDifference(colors[1], colors[2])

	-- make song
	local key = {math.random(12)-12, 'major'} -- just major for now
	local scale = {}
	for k, step in pairs(SCALES[key[2]]) do
		scale[k] = step + key[1]
	end

	-- make first bar of stars with random placement, size, density, interpolated color
	local bar = {}
	local pitch, dur, vel
	pitch = scale[1] -- always the tonic
	dur = 1
	vel = 1

	local note = {['pitch'] = pitch, ['dur'] = dur, ['vel'] = vel} -- first note

	local starParams = {
		-- sound = starSounds[1],
		x = math.random(waveWidth), -- x
		y = math.random(waveHeight), -- y
		radius = math.random(STAR_RADIUS_MIN, STAR_RADIUS_MAX), -- radius
		-- class = 
		cycles = math.random(12)+9, -- scale with or replace numPoints
		note = note,
		sound = starSounds[math.random(2)], -- vary this later
		attenuation = {waveWidth*0.05, waveWidth*0.175},
		next = true
	}
	local starColor = {math.random(), math.random(), math.random(), 1} -- color
	local star = Star(starParams, starColor)
	table.insert(bar, star)
	local lastNote = note

	local i = dur
	while i < 4 do
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
		note = {['pitch'] = pitch, ['dur'] = dur, ['vel'] = vel}

		starParams = {
			-- sound = starSounds[1],
			x = math.random(waveWidth), -- x
			y = math.random(waveHeight), -- y
			radius = math.random(STAR_RADIUS_MIN, STAR_RADIUS_MAX), -- radius
			-- class = 
			cycles = math.random(12)+9, -- scale with or replace numPoints
			note = note,
			sound = starSounds[math.random(2)], -- vary this later
			attenuation = {waveWidth*0.05, waveWidth*0.175},
			next = true
		}
		starColor = {math.random(), math.random(), math.random(), 1} -- change this later
		star = Star(starParams, starColor)
		table.insert(bar, star)
		lastNote = star.note
		i = i + dur
	end

	local songParams = {
		numBars = numBars,
		key = key,
		scale = scale,
		bar = bar
	}

	-- make wave
	local waveParams = {
		width = waveWidth,
		height = waveHeight
	}

	local moon = Moon(moonParams, colors)
	local wave = Wave(waveParams, colors)
	local song = Song(songParams, colors)
	local ocean = Ocean(moon, wave, song)

	if state == 'reset' then
		ocean.shifting[1] = true; -- shifting boolean
		ocean.shifting[2][1] = true; -- shifting color boolean
		ocean.shifting[2][2] = true;
		ocean.shifting[3] = mc; -- old colors
		ocean.shifting[4][1] = {math.random(), math.random(), math.random(), 1}; -- new colors
		ocean.shifting[4][2] = {math.random(), math.random(), math.random(), 1};
	end

	moon.ocean = ocean
	wave.ocean = ocean
	song.ocean = ocean

	return ocean
end