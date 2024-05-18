import serial
import time

ser = serial.Serial(
    port='/dev/ttyUSB1',
    baudrate=9600,
    parity=serial.PARITY_NONE,
    stopbits=serial.STOPBITS_ONE,
    bytesize=serial.EIGHTBITS
)

if not ser.isOpen():
    ser.open()

for number in range(10,-1,-1):

    hex_number = 16 if number == 10 else number 
    hex_byte = hex_number.to_bytes(1, byteorder='big')
    ser.write(hex_byte)
 #   ser.write(str(number).encode())
 #   ser.write(number)
    time.sleep(1)

    print(f"Sent: {number}")

ser.close()
