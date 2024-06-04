0000: 0E 10            -- MVI C, 10H        -- store 10H in C
0002: 3E 00            -- MVI A, 00         -- store 00H in A
0004: 3C        -- loop:  INR A             -- A = A + 1
0005: 0D               -- DCR C             -- C = C - 1
0006: CA 0B 00         -- JZ 000BH          -- jump to end if c=0 (zero flag high)
0008: C3 04 00         -- JMP 0004H         -- other wise jump to beginning of loop
000B: D3 03     -- end:   OUT 3             -- expect 10
000D: 76               -- HLT               -- stop program execution