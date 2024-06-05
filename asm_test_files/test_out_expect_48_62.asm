0000: 3E 48       -- MVI A, 48H      -- load 48H into accumulator
0002: D3 03       -- OUT 3           -- output accumulator to port 3
0004: 3E 62       -- MVI A, 62H      -- load 62H into accumulator  
0006: D3 04       -- OUT 4           -- output accumulator to port 4
0007: 76          -- HLT             -- stop program execution