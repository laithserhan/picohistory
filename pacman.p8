pico-8 cartridge // http://www.pico-8.com
version 15
__lua__
-- picohistory: pacman
-- david heyman

-- todo
-- collision/pathing table
-- read initial posns from map
-- 
__gfx__
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000aaaa0000aaaa0000aaaaa000aaaa000000000000000000000000000000000000000000000000000000000000000000
007007000000011111111111111000000aaaaaa00aaaaaa00aaaaaaa0aaaa0000000000000000000000000000000000000000000000000000000000000000000
00077000000011cccccccccccc110000aaaaaaaaaaaaaaaaaaaa0000aaaa00000000000000000000000000000000000000000000000000000000000000000000
0007700000011cccccccccccccc11000aaaaaaaaaaa00000aaa00000aaa000000000000000000000000000000000000000000000000000000000000000000000
007007000011cc111111111111cc1100aaaaaaaaaaaaaaaaaaaa0000aaaa00000000000000000000000000000000000000000000000000000000000000000000
00000000001cc11000000000011cc1000aaaaaa00aaaaaa00aaaaaaa0aaaa0000000000000000000000000000000000000000000000000000000000000000000
00000000001cc10000000000001cc10000aaaa0000aaaa0000aaaaa000aaaa000000000000000000000000000000000000000000000000000000000000000000
00777700001cc10000000000001cc10000aaa00000aaa00000aaa00000aaa0000000000000000000000000000000000000000000000000000000000000000000
07777770001cc10000000000001cc1000aaaaa000aaaaa000aaaaa000aaaaa000000000000000000000000000000000000000000000000000000000000000000
77777777001cc10000000000001cc100aaaaaaa0aaaaaaa0aaaaaaa0aaaaaaa00000000000000000000000000000000000000000000000000000000000000000
77777777001cc10077777777001cc100aaaaaaa0aaa0aaa0aaa0aaa0aaa0aaa00000000000000000000000000000000000000000000000000000000000000000
77777777001cc10077777777001cc100aaaaaaa0aaa0aaa0aa000aa0aa000aa00000000000000000000000000000000000000000000000000000000000000000
77777777001cc10000000000001cc100aaaaaaa0aaa0aaa0aa000aa0a00000a00000000000000000000000000000000000000000000000000000000000000000
07777770001cc10000000000001cc1000aaaaa000aa0aa00aa000aa0000000000000000000000000000000000000000000000000000000000000000000000000
00777700001cc10000000000001cc10000aaa00000a0a0000a000a00000000000000000000000000000000000000000000000000000000000000000000000000
00000000001cc11000000000001cc100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000001cc11100000000011cc100070000700700007000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000011cc111111111111ccc100717007177770077700000000000000000000000000000000000000000000000000000000000000000000000000000000
0007700000011ccccccccccccccc1100717007177710077100000000000000000000000000000000000000000000000000000000000000000000000000000000
00077000000011ccccccccccccc11000777007777710077100000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000001111111111111110000777007777770077700000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000070000700700007000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00888800008888000088880000888800008888000088880000000000000000000000000000000000000000000000000000000000000000000000000000000000
08888880088888800888888008888880088888800888888000000000000000000000000000000000000000000000000000000000000000000000000000000000
88188188881881888888888888888888888888888888888800000000000000000000000000000000000000000000000000000000000000000000000000000000
88788788887887888178178881781788887887888878878800000000000000000000000000000000000000000000000000000000000000000000000000000000
88888888888888888888888888888888881881888818818800000000000000000000000000000000000000000000000000000000000000000000000000000000
88888888888888888888888888888888888888888888888800000000000000000000000000000000000000000000000000000000000000000000000000000000
80888808888008888008800880888088808888088880088800000000000000000000000000000000000000000000000000000000000000000000000000000000
80088008808008080800880080088008800880088080080800000000000000000000000000000000000000000000000000000000000000000000000000000000
__map__
0122222222222222222222222203012222222222222222222222220300000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1320202020202020202020202011132020202020202020202020201100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1320010202032001020202032011132001020202032001020203201100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1310110000132011000000132011132011000000132011000013101100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1320212222232021222222232021232021222222232021222223201100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1320202020202020202020202020202020202020202020202020201100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1320010202032001032001020202020202032001032001020203201100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1320212222232011132021222203012222232011132021222223201100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1320202020202011132020202011132020202011132020202020201100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
2102020202032011210202030011130002020223132001020202022300000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000132011012222230021230022222203132011000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000132011130000000000000000000011132011000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
2222222222232021230001020212120202030021232021222222222200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000002000000011000030300000130000002000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0202020202032000000011000030300000130000002001020202020200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000132001030021222222222222230001032011000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000132011130000000000000000000011132011000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000132011130001020202020202030011132011000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0122222222232021230021222203012222230021232021222222220300000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1320202020202020202020202011132020202020202020202020201100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1320010202032001020202032011132001020202032001020203201100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1320212203132021222222232021232021222222232011012223201100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1310202011132020202020202004002020202020202011132020101100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
2102032011132001032001020202020202032001032011132001022300000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0122232021232011132021222203012222232011132021232021220300000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1120202020202011132020202011132020202011132020202020201100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1120010202020223210202032011132001020223210202020203201100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1120212222222222222222232021232021222222222222222223201100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1120202020202020202020202020202020202020202020202020201100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
2102020202020202020202020202020202020202020202020202022300000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
