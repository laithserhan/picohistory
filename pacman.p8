pico-8 cartridge // http://www.pico-8.com
version 15
__lua__
-- picohistory: pacman
-- david heyman

--===========
-- debugging
--===========
reprdepth = 0
function _tablerepr(t)
	if reprdepth > 1 then
		return "<table>"
	end

	reprdepth += 1
	local first = true
	local ret = "{"
	for k, v in pairs(t) do
		if not first then
			ret = ret .. ", "
		end
		first = false
		local rv
		if v == t then
			rv = "<...>"
		else
			rv = repr(v)
		end
		ret = ret .. repr(k) .. ": " .. rv
	end
	reprdepth -= 1
	return ret .. "}"
end

function repr(t)
	if t == true then
		return "<true>"
	elseif t == false then
		return "<false>"
	elseif t == nil then
		return "<nil>"
	elseif type(t) == "function" then
		return "<function>"
	elseif type(t) ~= "table" then
		return "" .. t
	elseif t.__repr then
		return t:__repr()
	elseif t.__name then
		return "<object/" .. t.__name .. " " .. _tablerepr(t) .. ">"
	elseif t.new then
		return "<object " .. _tablerepr(t) .. ">"
	else
		return _tablerepr(t)
	end
end

function spew(arg)
	local out = ""
	for s in all(arg) do
		out = out .. repr(s) .. " "
	end
	printh(out)
end

-->8
--=============
-- utils
--=============
function sort(args, keyfunc)
	-- insertion, good enough
	local keys = {}
	keyfunc = keyfunc or function(v) return v end
	for i = 1, #keys do
		keys[i] = keyfunc(list[i])
	end
	for i = 2, #keys do
		local j = i
		while j > 1 and keys[j - 1] > keys[j] do
			keys[j], keys[j - 1] = keys[j - 1], keys[j]
			list[j], list[j - 1] = list[j - 1], list[j]
			j -= 1
		end
	end
end

-- list filtering
-- not in-place
function filter(list, condition)
	local t = {}
	for i=1,#list do
		local b = list[i]
		if condition(b) then
			t[#t+1] = list[i]
		end
	end
	return t
end

function any(list, condition)
	for i=1,#list do
		if condition(list[i]) then
			return true
		end
	end
	return false
end

-- classes
function class(base, proto)
	proto = proto or {}
	proto.__index = proto
	local meta = {__index = base}
	setmetatable(proto, meta)
	function meta:__call(...)
		local this = setmetatable({}, self)
		if this.init then
			this:init(...)
		end
		return this
	end
	return proto
end

-- for xy coordinates, etc
vec2 = class()
function vec2:init(x,y)
	self.x = x or 0
	self.y = y or 0
end

function vec2:copy()
	return vec2(self.x, self.y)
end

function vec2:__repr()
	return "<vec2 " .. self.x .. ", " .. self.y .. ">"
end

function vec2:__add(other)
	return vec2(
		self.x + other.x,
		self.y + other.y)
end

function vec2:__mul(n)
		return vec2(
		self.x * n,
		self.y * n)
end

function vec2:__sub(other)
	-- if performance is problem,
	-- can inline (cost: symcount)
	return self + other * -1
end

-- paired multiplication
function vec2:elemx(other)
	return vec2(
		self.x * other.x,
		self.y * other.y)
end

-- magnitude
function vec2:mag()
	return sqrt(self.x * self.x +
		self.y * self.y)
end

-- box at other, this size
function vec2:at(anchor)
	return box(
		anchor.x, anchor.y,
		self.x, self.y)
end

-- get unit vectors
function vec2:unit()
	local len = sqrt(
		self.x * self.x +
		self.y * self.y)
	return vec2(self.x / len,
		self.y / len)
end

-- round to integer
function vec2:round()
	return vec2(flr(self.x + 0.5), flr(self.y + 0.5))
end

-- random point on unit circle
function randir()
	local p
	repeat
	p = vec2(beta(3,3),
		beta(3,3)):unit()
	until(p.x > 0 or p.y > 0)
	return p
end

-- rectangles
box = class()

function box:init(l,t,w,h)
	if w < 0 then
		l += w
		w *= -1
	end
	if h < 0 then
		t += h
		h *= -1
	end
	self.l = l
	self.t = t
	self.w = w
	self.h = h
end

function box:__repr()
	return "<box at (" ..
		self.l .. "," .. self.t .. "), (" ..
		self.w .. " by " .. self.h .. ")>"
end

function box.__index(self, key)
	if key == "r" then
		return self.l + self.w
	elseif key == "b" then
		return self.t + self.h
	else
		return box[key]
	end
end

function box:center()
	return vec2(self.l + self.w/2,
		self.t + self.h/2)
end

-- adjust box location
function box:__add(offset)
	return box(self.l + offset.x,
		self.t + offset.y,
		self.w, self.h)
end

-- check for overlaps. note
-- that it must be more
-- than the very edge.
function box:overlaps(other)
	return self.l < other.r and
		self.r > other.l and
		self.t < other.b and
		self.b > other.t
end

-->8
--========
-- hooks and globals
--========
local ents
local level = 1
local win = false
local lose = false
local power = 0
local cur_timer = 0
local timers
local chase_mode = true
local mode_frame = false
local pac
local cam = box(0, 0, 16, 16)
local pelletcount

function _init()
	ents = {
		pacman(1,1),-- 13, 22.5),
		blinky(11.5, 14),
		pinky(12.5, 14),
		inky(13.5, 14),
		clyde(14.5, 14)
	}
	pac = ents[1]
	cur_timer = 0
	timers = {210, 600, 210, 600, 150, 600, 150}
	pelletcount = 0
	for x=0,27 do for y=0,30 do
		if mget(x,y,2) then
			pelletcount += 1
		end
	end end
end

function _update()
	if cur_timer <= 0 and #timers > 0 then
		cur_timer = timers[1]
		del(timers, cur_timer)
		chase_mode = not chase_mode
		mode_frame = true
	elseif power <= 0 then
		cur_timer -= 1
	else
		power -= 1
	end
	foreach(ents, function(t) return t:update() end)
	-- update the camera
	local ploc = pac.pos
	cam.l = mid(0, ploc.x - 8, 12)
	cam.t = mid(0, ploc.y - 8, 15)
	if win then
		level += 1
		win = false
		lose = false
		-- todo endgame stuff
	elseif lose then
		win = false
		lose = false
		-- todo endgame stuff
	end
	mode_frame = false
end

function _draw()
	cls()
	-- center the camera on the player
	-- but don't scroll past the edge
	camera(cam.l * 8, cam.t * 8)
	local x = flr(cam.l)
	local y = flr(cam.t)
	map(x, y, x * 8, y * 8, 17, 17)
	for e in all(ents) do
		e:draw()
	end
end
-->8
function wrap(pos)
	pos.x = pos.x % 224
end

-- directions are enumerated to match the buttons
-- but with 4 for not-moving
local directions = {
	[0] = vec2(-1, 0),
	[1] = vec2(1, 0),
	[2] = vec2(0, -1),
	[3] = vec2(0, 1),
	[4] = vec2(0, 0)
}
function revdir(num)
	if num == 4 then
		return 4
	elseif num % 2 == 1 then
		return num - 1
	else
		return num + 1
	end
end

-- maps sprite numbers for pellets
-- to no-pellet equivalents
-- (preserve ghost pathing info)
local pelletmap = {
	[16] = 47,
	[32] = 47,
	[48] = 49,
	[50] = 51
}

thing = class()
function thing:init(x, y)
	self.pos = vec2(x, y)
	self.anim = 1
	self.dir = 4
end

function thing:move(flag, vel)
	local center = self.pos
	local cell = center:round()
	local target = (center + (directions[self.dir] * 0.7)):round()
	-- check if we're within half a cell of hitting the wall
	if not fget(mget(target.x, target.y), flag) then
		self.pos += (directions[self.dir] * vel)
	end
end

function thing:draw(sp, flipx, flipy)
	local center = self.pos
	-- adjust coordinates because sprites draw from top-left
	spr(sp, (center.x - 1) * 8 + 4,
		(center.y - 1) * 8 + 4, 2, 2,
		flipx, flipy)
end

pacman = class(thing)
function pacman:init(x, y)
	thing.init(self, x, y)
	self.sprss = {
		{4, 6, 8, 10, 8, 6, 4},
		{4, 12, 14, 44, 14, 12, 4},
		{4, 12, 14, 44, 14, 12, 4},
		{4}
	}
	self.sprss[0] = {4, 6, 8, 10, 8, 6, 4}
end

function pacman:draw()
	local flipx = self.dir == 0
	local flipy = self.dir == 2
	local sprs = self.sprss[self.dir]
	self.anim = (self.anim + 0.4) % #sprs
	thing.draw(self, sprs[flr(self.anim)+1], flipx, flipy)
end

function pacman:update()
	-- check button inputs and set direction
	-- direction persists between frames
	for i=0,4 do
		if btn(i) then
			self.dir = i
			break
		end
	end
	-- todo match speed to level properly
	self:move(0, 0.25)
	self.pos.x = self.pos.x % 28
	-- clear pellets
	local cell = self.pos:round()
	local p = mget(cell.x, cell.y)
	if fget(p, 2) then
		mset(cell.x, cell.y, pelletmap[p])
		pelletcount -= 1
		if pelletcount == 0 then
			win = true
		end
	-- todo set power for big pellet
	end
end

ghost = class(thing)
function ghost:init(x, y)
	thing.init(self, x, y)
	self.sprs = {36, 38, 40, 40}
	self.sprs[0] = 36
	-- states are:
	-- 0: chase
	-- 1: scatter
	-- 2: fright
	-- 3: eyes
	-- 4: in cage
	self.state = 0
end

function ghost:draw()
	pal(8, self.color)
	local sp = self.state == 3 and 42 or self.sprs[self.dir]
	thing.draw(self, sp, self.dir == 0, false)
end

function ghost:update()
	local cell
	self.state, self.dir = self:path(self.pos:round())
	-- todo match speed to level and self.state properly
	self:move(1, 0.6)
	if self.state < 3 then
		-- todo check for pacman
	end
end

function ghost:path(cell)
	local state = self.state
	local dir = self.dir
	-- first check if pathing is to be reevaluated
	-- rules depend on state and global
	local ns, nd -- new state and dir
	if mode_frame and state < 2 then
		-- reverse state and direction
		ns = (state + 1) % 2
		nd = revdir(dir)
	else
		-- not doing a reversal, so only redirect on
		-- intersections, and state is the same
		ns = state
		local rule = mget(cell.x, cell.y)
		if fget(rule, 3) then
			-- flag 3 on current cell means intersection
			-- flag 4 means can't go up
			local options = fget(rule, 4) and {0, 1, 2, 3} or {0, 1, 3}
			-- filter out directions that lead to walls
			options = filter(options, function(d)
				local c = cell + directions[d]
				return not fget(mget(c.x, c.y), 1)
			end)
			-- can't go backwards unless hitting dead end
			if #options > 1 then del(options, revdir(dir)) end
			if state == 2 then
				-- frightened, select direction at random
				nd = options[flr(rnd(#options)+1)]
			else
				local t
				if state == 3 then
					-- eyes, target is ghost-independent
					-- set t to cage cells
					-- or change state if there
					-- todo
				elseif state == 4 then
					-- currently in cage.
					-- todo how to handle this
				else
					-- either chase or scatter,
					-- target depends on ghost either way
					t = self:target(state, cell)
				end
				-- choose the direction with the least
				-- straight-line distance to the target
				nd = sort(options, function(d)
					local c = cell + directions[d]
					return (c - t):mag()
				end)[1]
			end
		else
			-- not an intersection
			nd = dir
		end
	end
	return ns, nd
end

blinky = class(ghost)
function blinky:init(x, y)
	self.color = 8
	ghost.init(self, x, y)
end

function blinky:target()
	-- todo
end

pinky = class(ghost)
function pinky:init(x, y)
	self.color = 14
	ghost.init(self, x, y)
end

function pinky:target()
	-- todo
end

inky = class(ghost)
function inky:init(x, y)
	self.color = 12
	ghost.init(self, x, y)
end

function inky:target()
	-- todo
end

clyde = class(ghost)
function clyde:init(x, y)
	self.color = 9
	ghost.init(self, x, y)
end

function clyde:target()
	-- todo
end
__gfx__
0000000000000000000000000000000000000aaaaaa0000000000aaaaaa0000000000aaaaaa0000000000aaaaaa0000000000aaaaaa0000000000aaaaaa00000
00000000000011111111111111110000000aaaaaaaaaa000000aaaaaaaaaa000000aaaaaaaaaa000000aaaaaaaaaa000000aaaaaaaaaa000000aaaaaaaaaa000
0070070000011cccccccccccccc1100000aaaaaaaaaaaa0000aaaaaaaaaaaa0000aaaaaaaaaaaa0000aaaaaaaaaaaa0000aaaaaaaaaaaa0000aaaaaaaaaaaa00
000770000011cccccccccccccccc11000aaaaaaaaaaaaaa00aaaaaaaaaaaaaa00aaaaaaaaaaaaaa00aaaaaaaaaaaa0000aaaaaaaaaaaaaa00aaaaaaaaaaaaaa0
00077000011cc11111111111111cc1100aaaaaaaaaaaaaa00aaaaaaaaaaaaaa00aaaaaaaaaaaaa000aaaaaaaaaaa00000aaaaaaaaaaaaaa00aaaaaaaaaaaaaa0
0070070001cc1100000000000011cc10aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa0000aaaaaaaaaa000000aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa
0000000001cc1000000000000001cc10aaaaaaaaaaaaaaaaaaaaaaaaaaa00000aaaaaaaaa0000000aaaaaaaa00000000aaaaaaa00aaaaaaaaaaaaaa00aaaaaaa
0000000001cc1000000000000001cc10aaaaaaaaaaaaaaaaaaaaaa0000000000aaaaaa0000000000aaaaaa0000000000aaaaaaa00aaaaaaaaaaaaaa00aaaaaaa
0077770001cc1000000000000001cc10aaaaaaaaaaaaaaaaaaaaaa0000000000aaaaaa0000000000aaaaaa0000000000aaaaaaa00aaaaaaaaaaaaaa00aaaaaaa
0777777001cc1000000000000001cc10aaaaaaaaaaaaaaaaaaaaaaaaaaa00000aaaaaaaaa0000000aaaaaaaa00000000aaaaaaa00aaaaaaaaaaaaa0000aaaaaa
7777777701cc1000000000000001cc10aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa0000aaaaaaaaaa000000aaaaaaa00aaaaaaaaaaaaa0000aaaaaa
7777777701cc1000000000000001cc100aaaaaaaaaaaaaa00aaaaaaaaaaaaaa00aaaaaaaaaaaaa000aaaaaaaaaaa00000aaaaa0000aaaaa00aaaaa0000aaaaa0
7777777701cc1000777777770001cc100aaaaaaaaaaaaaa00aaaaaaaaaaaaaa00aaaaaaaaaaaaaa00aaaaaaaaaaaa0000aaaaa0000aaaaa00aaaa000000aaaa0
7777777701cc1000777777770001cc1000aaaaaaaaaaaa0000aaaaaaaaaaaa0000aaaaaaaaaaaa0000aaaaaaaaaaaa0000aaaa0000aaaa0000aaa000000aaa00
0777777001cc1000000000000001cc10000aaaaaaaaaa000000aaaaaaaaaa000000aaaaaaaaaa000000aaaaaaaaaa000000aaa0000aaa000000a00000000a000
0077770001cc1000000000000001cc1000000aaaaaa0000000000aaaaaa0000000000aaaaaa0000000000aaaaaa0000000000a0000a000000000000000000000
0000000001cc1000000000000001cc10000008888880000000000788887000000000088888800000000000000000000000000aaaaaa000000000000000000000
0000000001cc1000000000000001cc100008888888888000000117888871100000088888888880000000000000000000000aaaaaaaaaa0000000000000000000
0000000001cc1100000000000011cc10008888888888880000711788887117000088888888888800000000000000000000aaaaaaaaaaaa000000000000000000
00077000011cc11111111111111ccc1008888888888888800877778888777780088888888888888000000000000000000aaaaaaaaaaaaaa00000000000000000
000770000011ccccccccccccccccc11008888778888877800887788888877880088888888888888000007700007700000aaaaaaaaaaaaaa00000000000000000
0000000000011ccccccccccccccc11000888777788877770088888888888888008888888888888800007777007777000aaaaaaaaaaaaaaaa0000000000000000
000000000000111111111111111110008888771188877118888888888888888888887788887788880007117007117000aaaaaaa00aaaaaaa0000000000000000
000000000000000000000000000000008888771188877118888888888888888888877778877778880007117007117000aaaaaaa00aaaaaaa0000000000000000
000000000000000000000000000000008888877888887788888888888888888888877778877778880007777007777000aaaaaa0000aaaaaa0000000000000000
000000000000000000000000000000008888888888888888888888888888888888871178871178880000770000770000aaaaaa0000aaaaaa0000000000000000
000000000000000000000000000000008888888888888888888888888888888888881188881188880000000000000000aaaaa000000aaaaa0000000000000000
0007700000000000000000000007700088888888888888888888888888888888888888888888888800000000000000000aaaa000000aaaa00000000000000000
0007700000000000000000000007700088888888888888888888888888888888888888888888888800000000000000000aaa00000000aaa00000000000000000
00000000000000000000000000000000888088888888088888808888888808888880888888880888000000000000000000a0000000000a000000000000000000
00000000000000000000000000000000880008800880008888000880088000888800088008800088000000000000000000000000000000000000000000000000
00000000000000000000000000000000800008000080000880000800008000088000080000800008000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000011110000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000011cc11000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000011cccc1100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00011cc11cc110000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0001cc1111cc10000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0001cc1111cc10000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00011cc11cc110000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000011cccc1100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000011cc11000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000011110000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__gff__
0003030300000000000000000000000004030103000000000000000000000000040303030000000000000000000002000c08181c00000000000000000000000003030000000000000000000000000000030300000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__map__
0102020202020202020202020203010202020202020202020202020300000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1120202020203020202020202013112020202020203020202020201300000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1120402222412040222222412013112040222222412040222241201300000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1110130000112013000000112013112013000000112013000011101300000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1120500202512050020202512050512050020202512050020251201300000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1130202020203020203020203020203020202020203020202020301300000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1120402222412040412040222222222222412040412040222241201300000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1120500202512013112050020203010202512013112050020251201300000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1120202020203013112020202013112020202013113020202020201300000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
2122222222412013212222410013110040222223112040222222222300000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000112013010202510050510050020203112013000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000112013110000003200003200000013112013000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000112013110040222212122222410013112013000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0202020202512050510013000000000000110050512050020202020200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
2e2e2e2e2e2e300000311300000000000011310000302e2e2e2e2e2e00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
2222222222412040410013000000000000110040412040222222222200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000112013110050020202020202510013112013000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000112013113100000000000000003113112013000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000112013110040222222222222410013112013000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0102020202512050510050020203010202510050512050020202020300000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1120202020203020203020202013112020203020203020202020201300000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1120402222412040222222412013112040222222412040222241201300000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1120500203112050020202512050512050020202512013010251201300000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1110202013113020203020203300003320203020203013112020101300000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
2122412013112040412040222222222222412040412013112040222300000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0102512050512013112050020203010202512013112050512050020300000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1120203020202013112020202013112020202013112020203020201300000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1120402222222223212222412013112040222223212222222241201300000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1120500202020202020202512050512050020202020202020251201300000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1120202020202020202020203020203020202020202020202020201300000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
2122222222222222222222222222222222222222222222222222222300000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
