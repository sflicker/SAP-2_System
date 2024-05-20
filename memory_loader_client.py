import serial
import time
import sys
import numpy as np

if len(sys.argv) != 2:
    print("Usage: python3 memory_loader_client.py <filename>")
    sys.exit(1)

filename = sys.argv[1]

ser = serial.Serial(
    port='/dev/ttyUSB1',
    baudrate=115200,
    parity=serial.PARITY_NONE,
    stopbits=serial.STOPBITS_ONE,
    bytesize=serial.EIGHTBITS
)

if not ser.isOpen():
    ser.open()

binary_numbers = []

try:
    with open(filename, 'r') as file:
        for line in file:
            columns = line.strip().split() # splits line into columns by whitespace

            if columns:
                binary_number = int(columns[0], 2)
                binary_numbers.append(binary_number)

except IOError:
    print(f"Could not read file: {filename}")
    sys.exit(1)

binary_numbers_array = np.array(binary_numbers)     


#print("Sending LOAD message")
#ser.write(b'LOAD')
print("Sending L")
ser.write(b'L')
time.sleep(0.1)

print("sending O")
ser.write(b'O')
time.sleep(0.1)

print("Sending A")
ser.write(b'A')
time.sleep(0.1)

print("Sending D")
ser.write(b'D')
time.sleep(0.1)

print("Waiting for READY response")
while True:
    if ser.in_waiting > 0:
        response = ser.read(ser.in_waiting).decode('ascii')
        if "READY" in response:
            print("Received READY response. Proceeding with data transmission.")
            break
        else:
            print("Unexpected response:", response)
    time.sleep(0.1)  # Polling delay

checksum = 0

num_bytes = binary_numbers_array.size + 4
num_bytes_formatted_to_send = num_bytes.to_bytes(4, byteorder='little')

print(f"num_bytes: {num_bytes}, num_bytes_formatted_to_send: {num_bytes_formatted_to_send}")

for byte in num_bytes_formatted_to_send:
    checksum = checksum ^ byte
    hex_byte = byte.to_bytes(1, byteorder='little');
    print(f"Sending  {hex_byte}")
    ser.write(hex_byte)
    time.sleep(0.1)

addr = 0
addr_formatted_to_send = addr.to_bytes(2, byteorder='little')

for byte in addr_formatted_to_send:
    checksum = checksum ^ byte
    hex_byte = byte.to_bytes(1, byteorder='little')
    print(f"Sending {hex_byte}")
    ser.write(hex_byte)
    time.sleep(0.1)

#ser.write(addr_formatted_to_send)

for number in binary_numbers_array:
    checksum = checksum ^ number

    pyint = int(number)
    hex_byte = pyint.to_bytes((pyint.bit_length() + 7) // 8, byteorder = 'little')
    print(f"number: {number}, pyint: {pyint}, hex_byte: {hex_byte}")
    ser.write(hex_byte)
    time.sleep(0.1)
    print(f"sent: {hex_byte.hex()}")

print(f"Checksum: {checksum}")
print("Waiting for CHECKSUM response")
while True:
    if ser.in_waiting > 0:
        response = ser.read(ser.in_waiting)
        print(f"Checksum Response - {response}")
        break
        # if "READY" in response:
        #     print("Received READY response. Proceeding with data transmission.")
        #     break
        # else:
        #     print("Unexpected response:", response)
    time.sleep(0.1)  # Polling delay



ser.close()


                               
          

