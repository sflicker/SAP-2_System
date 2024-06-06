0000: 3E 02           -- MVI A, 02H
0002: 06 06           -- MVI B, 06H
0004: B0              -- ORA B
0005: D3 03           -- OUT 3           -- should be 0x02
0007: 76
