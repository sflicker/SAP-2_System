00111110       -- 00H      MVI A, D8H      3EH
11011000       -- 01H                      D8H
00000110       -- 02H      MVI B, 2AH      06H
00101010       -- 03H                      2AH
10010000       -- 04H      SUB B           90H
11010011       -- 05H      OUT 3           D3H             -- should be 0010 or 0x2
00000011       -- 06H                      03H
01110110       -- 07H      HLT             76H