0000: 3E 11              -- MVI A, 11H      
0002: C3 08 00           -- JMP 0008        
0005: D3 03              -- OUT 3           ;do not expected this output of 11H
0007: 76                 -- HLT             
0008: 3C                 -- INR A           
0009: D3 03              -- OUT 3           ;expect output 12H
000B: 76                 -- HLT             
