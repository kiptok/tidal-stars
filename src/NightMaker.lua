NightMaker = Class{}

function NightMaker.generate(w, d, p, r)
	local waveWidth = w
	local difficulty = d
	local period = p
	local radius = r

	local waveHeight = FRAME_HEIGHT

	local colors = {}
	local stars = {}

	-- difficulty-adjustable settings
	local numStars = 40
	local minColorDiff = 1.6
	local duration = 60

	-- set colors randomly with minimum difference
	local dColor = 0
	while dColor < minColorDiff do
		dColor = 0
		colors[1] = {math.random(), math.random(), math.random(), 1} -- 'dark'
		colors[2] = {math.random(), math.random(), math.random(), 1} -- 'light'
		for i = 1, 3 do
			dColor = dColor + math.abs(colors[1][i] - colors[2][i])
		end
	end

	-- make stars with random placement, size, density, interpolated color
	for i = 1, numStars do
		local x = math.random(waveWidth)
		local y = math.random(FRAME_HEIGHT)
		local r = math.random(STAR_RADIUS_MIN, STAR_RADIUS_MAX)
		local n = math.floor(math.random(r*r*0.125, r*r*0.5))
		local c = lerpColor(colors[1], colors[2], math.random())
		table.insert(stars, Star(x, y, r, n, c))
	end

	stars[math.random(numStars)].next = true

	local moon = Moon(colors, period, radius)
	local wave = Wave(colors, waveWidth, waveHeight)
	local song = Song(duration)

	local field = Field(moon, wave, stars, song)
	moon.field = field
	wave.field = field
	song.field = field

	return field
end