0000: 3E D8      -- MVI A, D8H      
0002: 0E 2A      -- MVI C, 2AH      
0004: A1         -- ANA C           
0005: D3 03      -- OUT 3           ;should be 00001000 or 0x08H
0007: 76         -- HLT             