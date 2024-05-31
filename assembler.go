package main

import "fmt"

func main() {
	mnemonicToOpcode := map[string]byte{
		"NOP": 0x00,
		"LDA": 0x3A,
		"STA": 0x32,
		"ADD": 0x87,
		"SUB": 0x90,
	}

	fmt.Println("Mnemonic to Opcode Map:")
	for mnemonic, opcode := range mnemonicToOpcode {
		fmt.Printf("%s : 0x%02X\n", mnemonic, opcode)
	}
}
