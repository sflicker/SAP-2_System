0000: 3E 01        --  MVI A, 01H
0002: 06 02        --  MVI B, 02H
0004: 0E 03        --  MVI C, 03H
0006: 80           --  ADD B
0007: 81           --  ADD C
0008: 3C           --  INR A
0009: 04           --  INR B
000A: 0C           --  INR C
000B: 3D           --  DCR A
000C: 05           --  DCR B
000D: 0D           --  DCR C
000E: A0           --  ANA B
000F: A1           --  ANA C
0010: 90           --  SUB B
0011: 91           --  SUB C
0012: D3 03        --  OUT 3        ;EXPECT FD
0014: 76           --  HLT