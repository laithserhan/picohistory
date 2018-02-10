pico-8 cartridge // http://www.pico-8.com
version 15
__lua__
--picohistory: wumpus
--by david heyman
--=============
-- utils
--=============
-- 15 symbols for pick, plus three per call
-- 8 per call to inline
-- cheaper if used thrice
local function pick(list)
	return flr(rnd(#list))+1
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
-->8
--=============
-- the player
--=============
local player = {} -- singleton
-- todo
-->8
--=============
-- the wumpus
--=============
local wumpus = {} -- singleton
-- todo
-->8
--=============
-- the world
--=============
local palette = {} -- todo

local room = class()
function room:init(i,n,e,s,w)
	self.i = i
	self.conn = {n,e,s,w}
	self.moss = pick(palette)
	self.pit = false
	self.bat = false
end

function room:status()
	-- todo determine what warnings
	-- bats or pit within 1, wumpus within 2
end

function room:draw()
	-- first draw the bit that's always the same
	map(0,0,0,0,16,15)
	-- then place the doors
	local dir_args = {
		{1,16,4,56,8,3,3},
		{2,17,1,120,56,1,3},
		{3,16,0,56,112,3,1},
		{4,16,3,0,56,1,3}
	}
	palt(0, false)
	for i,mx,my,px,py,w,h in dir_args do
		if self.conn[i] ~= 0 then
			map(mx,my,px,py,w,h)
		end
	end
	-- and the pit
	if self.pit then
		palt(14, true)
		map(19,0,40,44,6,6)
	end
	palt()
	-- bats and wumpus move,
	-- so they get handled separately
end

local world = {
	room(1,0,6,13,10),
	room(2,7,3,0,8),
	room(3,2,11,0,9),
	room(4,10,5,8,0),
	room(5,15,0,7,4),
	room(6,8,9,0,1),
	room(7,0,20,2,5),
	room(8,0,2,6,4),
	room(9,0,3,19,6),
	room(10,4,1,0,17),
	room(11,0,20,16,3),
	room(12,13,18,17,0),
	room(13,1,19,0,12),
	room(14,0,15,18,20),
	room(15,5,17,0,14),
	room(16,19,11,18,0)
	room(17,0,10,12,15),
	room(18,16,0,14,12),
	room(19,9,0,16,13),
	room(20,7,14,0,11)
}
 
local function populate(rooms)
	-- place two bats and two pits, no overlap
	local avail = {}
	for i=1,20 do
		add(avail,i)
	end
	for key in {'bat', 'pit'} do
		for i=1,2 do
			local n = pick(avail)
			world[n][key] = true
			del(avail, n)
		end
	end
	-- return two unused locations, for player and wumpus
	local w = pick(avail)
	del(avail, w)
	return w, pick(avail)
end
-->8
--=============
-- the game hooks
--=============
__gfx__
0000000022222222222040222222210422222222001110000000011000010000100001100000000000000000000000009999999923299999999999440000011e
00000000292222222110b02222221104222922221111111111111111111111111111111109aa9aa9aa9aaa9aaa9aa9a09999999923294444499994220000001e
0070070022422222221101111111100122442222222222222222222222222222222222220a22222222222222222222a099999944222944444494442300000011
00077000222222221110000000100b0122222222aaaaaaaa9aaaaaaaaaaaaaa9aaaaaaaa0a21111111111111111112904999944429944444444442330000001e
000770002222221100044449900000b012222222111111114111111111111114111111110921101001010110110112a04499444224444222244442330000011e
00700700222222100944224444444400111222229999999929999999aaaa9992a99999990a21001000000000010012a04414442124222333324442330000011e
00000000222221009422222222222110001122229aa9999929999999a99999929999aa990a21000000000000000012902222222332422222222222320000111e
000000002212210442222222222221004001222299999994299a999999999999229999990921100000000000000112a0322332949949994992922a22000011ee
0000000011011104222222222222100444011222999999442999999999999999232999990a210100100100000001129029922290e11000002292aaaa00011eee
0000a00010b01004222222222221004422401122499994222449999999999999232944440a21000011100000000012a029992220e100000092922999000111ee
000aaa00100000442222222222210a9222240111449444232444449999999944222944440921000022110000000012a029992490e110000042922999000011ee
00004000009109422222999222210a9222210100444442332444444449999444299444440a211000a92110000001129029a922901110000092912999000111ee
000040000b010442222294422221094222210092244442332244444444994442244442220a2110000a211000000112a0299922201100000092912999100011ee
000040001011042222294222222109422221099232444233332442224414442124222333092100000a210000000012a029a42290100000004292244911111eee
0000400010000422222222222221144222210002222222323222223322222223322222220a21100009211000000112a02aa42490111000009292444911eeeeee
000a0a000bb04422222222222222004222210bb099922a22222aaa2232233322229aaa99092110000a2100000001129029942420e1000000924244441eeeeeee
00000000000b0222222222222221001122210b0b9992aaaa9999999229922299299999990a21000000000000000012a019442490000000002242444400000000
1110000022104422222222222210000022211b009a9229999999999929999999299999990a21000000000000000112a014442490000010009242244400000000
221100002210000042222222210094400222109299922999999999992999aa9929999aaa09211000010000010000129022222240001000109221122200000000
3331100021100bb00422222210094422022210029991299999a99999299aa999299999990a21011001011100110112a0a9a92491000110014221199900000000
42211000010991bb042222211019422202210040999129999aa9999929999999129999990a211111111111111111129099992490011111009291299911000000
5511100000044400004222210944222200210444999224499999944429944999299999990922222222222222222222a094492240111111d0929299a911100100
66d5100044442244404221100422222220100422999244499944444424444444244999990aa9aa9aa9aa9aa9aa9aa9a04449229111ddd1114242449411111111
776d10002222222222001100442222222100442299424444444444442444444424444999000000000000000000000000111111112222222111111111e11ee111
882210002222222222100002222222211044422294424444444444421444224422444449000012a00a21000000001001eeeee1eeeeeeeeeeeeeeeeeee1100000
942210002222222222210bb02200211004422222444224444422244214233324232224440000129aa921000000000111e11e11ee11111111eeeeeeeee1100000
a942100022222222222210b000bb01004422222222211222223322222222232222211222000111222211100000001122ee111ee11001110111eeeeeee1110000
bb33100022229222222210bb000b0004422222229921199992322999a99112999992229900000111111110000001129a11e1111110000000001eeee1ee110100
ccd510002222422222210b000990110422222222a9912999923299a999912999a992929a0000000110000000000112a0e111011000000000011eee11e1111110
dd51100022222222222100094444220042222292999299a999229999944299949992999a0000100000010000000012a0e1100000000000000011ee1eeeeeee11
ee421000222222222210b04222222210422229424442449444429444444294444442499400000000000000000001129011000000000000000000111eeeeeeee1
f9421000222222222210b0422222210422222222111111111111111111111111111111110000000000000000000012a0e1100000000000000000001eeeee1111
00000055500000000000005550000000000000001000000144444444444444444444444444444444000000000000000000000000000000000000000000000000
00000552550000000000055555000000000000001000000144444444444444444444444444444444000000000000000000000000000000000000000000000000
00005555555000000000555555500000001111001100001199999999999999999999999999999999000000000000000000000000000000000000000000000000
00000eddde00000000000eeeee000000018118101111111199999999999999999999999999999999000000000000000000000000000000000000000000000000
000000ddd0000000000000eee0000000111001111181181199999999999999999999999999999999000000000000000000000000000000000000000000000000
00000255520000000000022222000000100000010110011099999999999999999999999999999999000000000000000000000000000000000000000000000000
0000552525500000000055554a500000100000010000000099999999999999999999999999999999000000000000000000000000000000000000000000000000
04050552550500000005055444050400100000010000000099999999999999999999999999999999000000000000000000000000000000000000000000000000
04750555450500000005054455057400007000000000007099999999999999999999999999999999000000000000000000000000000000000000000000000000
0407022224050000000d0442220d0400007770000000777099999999999999999999999999999999000000000000000000000000000000000000000000000000
004d75555596900000969555557d4000000777000007770099999999999999999999999999999999000000000000000000000000000000000000000000000000
0004445559aaa90009aaa95554440000000077444447700099999999999999999999999999999999000000000000000000000000000000000000000000000000
00000550559a9000009a955055000000000044444444400099999999999999999999999999999999000000000000000000000000000000000000000000000000
00000550550900000009055055000000000444444444440099999999999999999999999999999999000000000000000000000000000000000000000000000000
0000055055000000000005505500000000044ff444ff440099999999999999999999999999999999000000000000000000000000000000000000000000000000
0000044044000000000004404400000000044ff444ff440099999999999999999999999999999999000000000000000000000000000000000000000000000000
00000055500000000000005550000000000444444444440099999999999999999999999999999999000000000000000000000000000000000000000000000000
00000255550000000000055552000000004444444444444077777777777770777777770777777777000000000000000000000000000000000000000000000000
00005555555000000000555555500000004449999999444077777777777770777777770777777777000000000000000000000000000000000000000000000000
000000dee0000000000000eed0000000004449777779444007777777777770777777770777777777000000000000000000000000000000000000000000000000
000000dde0000000000000edd0000000004449999999444000777777777700777777770777777777000000000000000000000000000000000000000000000000
00000024200000000000002240000000004444444444444000777777777700777777700777777777000000000000000000000000000000000000000000000000
0000005544000000000000a420000000004444000004444000077777777700777777700777777770000000000000000000000000000000000000000000000000
00000545540000000000044550000000004444000004444000007777777000777777700077777770000000000000000000000000000000000000000000000000
00005045500000000000045550000000000000000000000000007777770000077777000077777770000000000000000000000000000000000000000000000000
00005022200000000000005540000000000000000000000000000777700000077777000077777770000000000000000000000000000000000000000000000000
00096905500000000000002d40000000000000000000000000000777700000077777000007777700000000000000000000000000000000000000000000000000
009aaa95500000000000007d40000000000000000000000000000777700000077777000007777700000000000000000000000000000000000000000000000000
0009a905500000000000075400000000000000000000000000000077000000077770000007777700000000000000000000000000000000000000000000000000
00009005500000000000444500000000000000000000000000000077000000007770000007777000000000000000000000000000000000000000000000000000
00000005500000000000005500000000000000000000000000000077000000007770000000777000000000000000000000000000000000000000000000000000
00000044400000000000004440000000000000000000000000000070000000000700000000070000000000000000000000000000000000000000000000000000
__map__
3b05060708050607080506070805061a0b24093c3d3d3d3d3e00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1b1516171815161718151617181516192b29001d747474740f00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1b2526272825262728252627282526193303001d747474740f00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1b3536373835363738353637383536190b09001d747474740f00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1b0102030401020304010203040102190c0d0e1d747474740f00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1b1112131411121314111213141112191c001e3f2f2f2f2f1f00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1b2122232421222324212223242122192c2d2e00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1b31323334313233343132333431321900000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1b01020304010203040102030401021900000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1b11121314111213141112131411121900000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1b21222324212223242122232421221900000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1b31323334313233343132333431321900000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1b01020304010203040102030401021900000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1b11121314111213141112131411121900000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
390a0a0a0a0a0a0a0a0a0a0a0a0a0a3a00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
