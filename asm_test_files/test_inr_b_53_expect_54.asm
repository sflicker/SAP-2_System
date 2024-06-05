0000: 06 53    -- MVI B, 53H  
0002: 04       -- INR B       
0003: 78       -- MOV A,B     
0004: D3 03    -- OUT 3            ;expect 54H
0006: 76       -- HLT         