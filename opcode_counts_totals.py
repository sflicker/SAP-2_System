import re
from collections import defaultdict

# Input file containing the grep results
#input_file = "opcode_counts.txt"
input_file = "run.out"

# Dictionary to store the aggregated opcode counts
opcode_counts = defaultdict(int)

# Regular expression to match the opcode lines
opcode_pattern = re.compile(r"Opcode ([0-9A-F]+) : (\d+)")

# Read and process the input file
with open(input_file, "r") as file:
    for line in file:
        match = opcode_pattern.search(line)
        if match:
            opcode = match.group(1)
            count = int(match.group(2))
            opcode_counts[opcode] += count

# Print the aggregated results
for opcode, count in sorted(opcode_counts.items()):
    print(f"Opcode {opcode}: {count}")
