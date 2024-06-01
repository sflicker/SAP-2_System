00111110         -- 00H     MVI A, 10H      3EH
00010000         -- 01H                     10H
00111100         -- 02H     INR A           3CH     doing this will clear the equal flag
00001110         -- 03H     MVI C, 01H      0EH
00000001         -- 04H                     01H
00001101         -- 05H     DCR C           0DH
11001010         -- 06H     JZ 000C         CAH
00001100         -- 07H                     08H
00000000         -- 08H                     00H
11010011         -- 09H     OUT 3           D3H     do not expected this output of 11H
00000011         -- 0AH                     03H
01110110         -- 0BH     HLT             76H
00111100         -- 0CH     INR A           3CH
11010011         -- 0DH     OUT 3           D3H     expect output 12H
00000011         -- 0EH                     03H
01110110         -- 0FH     HLT             76H
