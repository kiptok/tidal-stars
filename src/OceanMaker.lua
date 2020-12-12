OceanMaker = Class{}

function OceanMaker.generate(l, m, mc, bc)
	local level = l
	local moonParams = m
	local waveWidth = level * FRAME_WIDTH * 10
	local waveHeight = FRAME_HEIGHT
	local period = moonParams.period
	local radius = moonParams.radius
	local colors = bc or false
	local difference
	local stars = {}

	-- difficulty-adjustable settings
	local numStars = level * 40
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

	-- make wave
	waveParams = {
		width = level * FRAME_WIDTH * 10,
		height = FRAME_HEIGHT
	}

	-- make stars with random placement, size, density, interpolated color
	for i = 1, numStars do
		local starParams = {
		x = math.random(waveWidth), -- x
		y = math.random(waveHeight), -- y
		radius = math.random(STAR_RADIUS_MIN, STAR_RADIUS_MAX), -- radius
		numPoints = math.floor(math.random(r*r*0.125, r*r*0.5)) -- # of points
		-- class = 
		-- note = 
		}
		local starColor = {math.random(), math.random(), math.random(), 1} -- color
		-- local starColor = lerpColor(colors[1], colors[2], math.random())
		local star = Star(starParams, starColor)

		local cycles = math.random(12) + 9 -- scale with or replace numPoints
		for k = 1, cycles do
			local choice = math.random(6) -- not just random
			star.drawCycle(choice)
		end

		table.insert(stars, Star(starParams, starColor))
	end

	stars[math.random(numStars)].next = true

	local moon = Moon(moonParams, colors)
	local wave = Wave(waveParams, colors)
	local song = Song()

	local ocean = Ocean(moon, wave, stars, song)

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