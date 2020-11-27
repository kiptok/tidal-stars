Player = Class{}

function Player:init(x, y, r)
	self.x = x
	self.y = y
	self.dx = 0
	self.dy = 0
	self.dtheta = math.random(-math.pi / 8, math.pi / 8)
	self.r = r or 0
end

function Player:update(dt)
	-- rotation
	if love.keyboard.isDown('k') then
		self.dtheta = self.dtheta - PLAYER_ACCEL
	elseif love.keyboard.isDown(';') then
		self.dtheta = self.dtheta + PLAYER_ACCEL
	end
	if love.keyboard.wasPressed('.') then
		self.dtheta = 0
	end

	-- reversals
	if love.keyboard.wasPressed('f') or love.keyboard.wasPressed('r') then
		self.dx = -self.dx
	end
	if love.keyboard.wasPressed('e') or love.keyboard.wasPressed('r') then
		self.dy = -self.dy
	end
	if love.keyboard.wasPressed('j') then
		self.dtheta = -self.dtheta
	end

	-- radius
	if love.keyboard.isDown('l') then
		self.hearts['xo'].r = self.hearts['xo'].r + HEART_SPEED * dt
		self.hearts['ox'].r = self.hearts['ox'].r + HEART_SPEED * dt
	elseif love.keyboard.isDown('o') then
		self.hearts['xo'].r = self.hearts['xo'].r - HEART_SPEED * dt
		self.hearts['ox'].r = self.hearts['ox'].r - HEART_SPEED * dt
	end
end

function Player:collides(target)
	if self.x > target.x + target.width or target.x > self.x + self.width then
		return false
	end

	if self.y > target.y + target.height or target.y > self.y + self.height then
		return false
	end

	return true
end

function Player:render()
	player:render()
end