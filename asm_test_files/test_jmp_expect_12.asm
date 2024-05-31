    00111110         -- 00H     MVI A, 11H      3EH
    00010001         -- 01H                     11H
    11000011         -- 02H     JMP 0008        C3H
    00001000         -- 03H                     08H
    00000000         -- 04H                     00H
    11010011         -- 05H     OUT 3           D3H     do not expected this output of 11H
    00000011         -- 06H                     03H
    01110110         -- 07H     HLT             76H
    00111100         -- 08H     INR A           3CH
    11010011         -- 09H     OUT 3           D3H     expect output 12H
    00000011         -- 0AH                     03H
    01110110         -- 0BH     HLT             76H
