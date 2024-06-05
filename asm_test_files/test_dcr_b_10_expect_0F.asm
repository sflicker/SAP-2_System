0000: 06 10       -- MVI B, 10H
0002: 05          -- DCR B
0003: 78          -- MOV A,B      
0004: D3 03       -- OUT 3         ;expect 0FH
0006: 76          -- HLT 