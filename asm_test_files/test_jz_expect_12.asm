0000: 3E 10      -- MVI A, 10H
0002: 3C         -- INR A         ;doing this will clear the equal flag
0003: 0E 01      -- MVI C, 01H    
0005: 0D         -- DCR C      
0006: CA 0C 00   -- JZ 000C
0009: D3 03      -- OUT 3          ;do not expected this output of 11H
000B: 76         -- HLT
000C: 3C         -- INR A
000D: D3 03      -- OUT 3           ;expect output 12H
000F: 76         -- HLT
