    00111110         -- 00H     MVI A, 11H      3EH
    00010001         -- 01H                     11H
    00001110         -- 02H     MVI C, 04H      0EH
    00000100         -- 03H                     04H
    00001101         -- 04H     DCR C           0DH
    11000010         -- 05H     JNZ 000B        C2H
    00001011         -- 06H                     08H
    00000000         -- 07H                     00H
    11010011         -- 08H     OUT 3           D3H     do not expected this output of 11H
    00000011         -- 09H                     03H
    01110110         -- 0AH     HLT             76H
    00111100         -- 0BH     INR A           3CH
    11010011         -- 0CH     OUT 3           D3H     expect output 12H
    00000011         -- 0DH                     03H
    01110110         -- 0EH     HLT             76H
