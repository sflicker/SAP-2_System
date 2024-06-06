0000: 3E D8      -- MVI A, D8H      
0002: 06 4A      -- MVI B, 4AH      
0004: A0         -- ANA B           
0005: D3 03      -- OUT 3           ;should be 0x48H
0007: 76         -- HLT             