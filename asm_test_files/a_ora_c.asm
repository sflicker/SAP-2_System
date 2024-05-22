00111110       -- 00H      MVI A, D8H      3EH
11011000       -- 01H                      D8H
00001110       -- 02H      MVI C, 2AH      0EH
00101010       -- 03H                      2AH
10110001       -- 04H      ORA C           A1H
11010011       -- 05H      OUT 3           D3H -- should be 0xFA
00000011       -- 06H                      03H
01110110       -- 07H      HLT             76H