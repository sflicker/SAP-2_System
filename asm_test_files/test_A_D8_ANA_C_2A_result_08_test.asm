00111110       -- 00H      MVI A, D8H      3EH
11011000       -- 01H                      D8H
00001110       -- 02H      MVI C, 2AH      0EH
00101010       -- 03H                      2AH
10100001       -- 04H      ANA C           A1H
11010011       -- 05H      OUT 3           D3H -- should be 00001000 or 0x08H
00000011       -- 06H                      03H
01110110       -- 07H      HLT             76H