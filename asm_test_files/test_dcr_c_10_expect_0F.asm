0000: 0E 10       -- MVI C, 10H
0002: 0D          -- DCR C
0003: 79          -- MOV A, C      
0004: D3 03       -- OUT 3         ;expect 0FH
0006: 76          -- HLT 