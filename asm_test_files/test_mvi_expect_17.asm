0000: 3E 11           -- 00H MVI A, 11H
0002: 06 02           -- MVI B, 02H
0004: 0E 04           -- MVI C, 04H
0006: 80              -- ADD B 
0007: 81              -- ADD C
0008: D3 03           -- OUT 3               -- expect 17
000B: 76              -- HLT
