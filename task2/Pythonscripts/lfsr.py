

def lfsr_8bit(seed, taps, max_cycles=256):
    """
    Generates an 8-bit LFSR sequence.
    
    Parameters:
      seed (int): 8-bit seed value.
      taps (int): 8-bit tap mask (only bits set in the mask are used for feedback).
      max_cycles (int): Maximum number of cycles to generate.
      
    Returns:
      list of int: Generated sequence (each element is an 8-bit integer).
    """
    state = seed & 0xFF  # ensure seed is 8-bit
    sequence = []
    seen = set()
    
    for _ in range(max_cycles):
        if state in seen:
            # Sequence repeats, so break out
            break
        seen.add(state)
        sequence.append(state)
        
        # Compute feedback: XOR all tapped bits
        # This computes the reduction XOR of (state & taps)
        feedback = 0
        temp = state & taps
        while temp:
            feedback ^= (temp & 1)
            temp >>= 1
        
        # Shift left by one and insert feedback at LSB.
        # Alternatively, some designs shift right.
        state = ((state << 1) | feedback) & 0xFF  # ensure 8-bit result
    
    return sequence

def main():
    # Get seed and taps from user (in hex format)
    seed_str = input("Enter 8-bit seed (in hex, e.g., 42): ")
    taps_str = input("Enter 8-bit taps (in hex, e.g., B4): ")
    
    try:
        seed = int(seed_str, 16)
        taps = int(taps_str, 16)
    except ValueError:
        print("Invalid input. Please enter hex numbers.")
        return
    
    # Generate the LFSR sequence
    sequence = lfsr_8bit(seed, taps)
    
    # Write the sequence to a file, displaying both hex and decimal values
    filename = "lfsr_py_output.txt"
    with open(filename, "w") as f:
        f.write("LFSR Sequence (seed=0x{:02X}, taps=0x{:02X}):\n".format(seed, taps))
        for idx, num in enumerate(sequence):
            f.write("Cycle {:3d}: 0x{:02X} ({:3d})\n".format(idx, num, num))
    
    print("LFSR sequence written to '{}'".format(filename))

if __name__ == "__main__":
    main()
