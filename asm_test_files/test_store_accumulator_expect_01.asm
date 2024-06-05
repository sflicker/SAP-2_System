0000: 3E 01             -- MVI A, 01H      -- move value 01H into accumulator
0002: 32 40 08          -- STA 0840H       -- store at address 0840H (2112 in dec)
0005: 3C                -- INC A           -- ACC shoudld 02H now
0006: 3A 40 08          -- LDA 0840H       -- ACC should be back to 01H
0009: D3 03             -- OUT 3           -- expect 01
000A: 76                -- HLT