0000: 3E 10       -- MVI A, 10H
0002: 3D          -- DCR A      
0003: D3 03       -- OUT 3         ;expect 0FH
0005: 76          -- HLT 