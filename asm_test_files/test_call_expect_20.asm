0000: 0E 10             -- MVI C, 10H 
0002: 06 02             -- MVI B, 2H
0004: 3E 00             -- MVI A, 0H
0006: CD 20 00   -- loop:  CALL :addb   
0009: 0D                -- DCR c
000A: CA 10 00          -- JZ :end 
000D: C3 06 00          -- JMP :loop
0010: D3 03     --  end:   OUT 3              expect 20
0012: 76                -- HLT
0013: 00 00 00 00 00 00 00 00 00 00 00 00 00 00
0020: 80        -- addb:   ADD B
0021: C9                -- RET  
