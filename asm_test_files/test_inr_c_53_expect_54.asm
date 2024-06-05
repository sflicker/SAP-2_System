0000: 0E 53    -- MVI C, 53H  
0002: 0C       -- INR C       
0003: 79       -- MOV A,C     
0004: D3 03    -- OUT 3         ;expect 54H
0006: 76       -- HLT         