0000: 3E 90      -- MVI A, 90H
0002: 06 28      -- MVI B, 28H
0004: 90         -- SUB B
0005: D3 03      -- OUT 3           ;expect 68H
0007: 76         -- HLT