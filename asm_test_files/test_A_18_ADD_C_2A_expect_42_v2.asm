0000: 3E 18      -- MVI A, 18H
0002: 0E 2A      -- MVI C, 2AH      
0004: 81         -- ADD C
0005: D3 03      -- OUT 3      -- should be 0x42H
0007: 76         -- HLT            