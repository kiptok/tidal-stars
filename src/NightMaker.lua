NightMaker = Class{}

function NightMaker.generate(w, d, p, r)
	local width = w
	local difficulty = d
	local period = p
	local radius = r

	local colors = {}
	local stars = {}

	-- difficulty-adjustable settings
	local numStars = 20
	local minColorDiff = 1
	local duration = 60

	-- set colors randomly with minimum difference
	local dColor = 0
	while dColor < minColorDiff do
		colors[1] = {math.random(), math.random(), math.random(), 1} -- 'dark'
		colors[2] = {math.random(), math.random(), math.random(), 1} -- 'light'
		for i = 1, 3 do
			dColor = dColor + abs(colors[1][i] - colors[2][i])
		end
	end

	-- make stars with random placement, size, density, interpolated color
	for i = 1, numStars do
		local x = math.random(width)
		local y = math.random(FRAME_HEIGHT)
		local s = math.random(STAR_SIZE_MIN, STAR_SIZE_MAX)
		local n = math.round(math.random(s*s*0.25, s*s))
		local c = lerpColor(colors[1], colors[2], math.random())
		table.insert(stars, Star(x, y, s, n, c))
	end

	local moon = Moon(colors, period, radius)
	local wave = Wave(colors, width)
	local song = Song(duration)

	local field = Field(moon, wave, stars, song)
	moon.field = field
	wave.field = field
	song.field = field

	return field
end