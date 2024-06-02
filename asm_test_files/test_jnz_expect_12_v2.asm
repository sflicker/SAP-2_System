0000: 3E 11     -- MVI A, 11H
0002: 0E 04     -- MVI C, 04H
0004: 0D        -- DCR C
0005: C2 0B 00  -- JNZ 000B
0008: D3 03     -- OUT 3                ;do not expected this output of 11H
000A: 76        -- HLT
000B: 3C        -- INR A
000C: D3 03     -- OUT 3                ;expect output 12H
000E: 76        -- HLT
