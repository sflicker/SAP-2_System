00111110    00H       MVI A, 15H    3EH
00010101    01H                     15H
00001110    02H       MVI C, C3H    0EH
11000011    03H                     C3H
10000001    04H       ADD C         81H
11010011    05H       OUT 3         D3H     -- expect D8H
00000011    06H                     03H
01110110    07H       HLT           76H