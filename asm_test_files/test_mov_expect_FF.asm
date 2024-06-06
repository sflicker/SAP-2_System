0000: 3E FF         -- MVI A, FF        -- A=FF
0002: 06 88         -- MVI B, 88        -- B=88
0004: 4F            -- MOV C, A         -- C=FF, 
0005: 78            -- MOV A, B         -- A=88
0006: 41            -- MOV B, C         -- B=FF
0007: 48            -- MOV C, B         -- C=FF
0008: 47            -- MOV B, A         -- B=88
0009: 79            -- MOV A, C         -- A=FF
000A: D3 03         -- OUT 3
000C: 76            -- HLT