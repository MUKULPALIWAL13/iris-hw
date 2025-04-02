

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
        
        # Compute feedback: XOR of all tapped bits
        feedback = 0
        temp = state & taps
        while temp:
            feedback ^= (temp & 1)
            temp >>= 1
        
        # Shift left by one and insert feedback at LSB.
        state = ((state << 1) | feedback) & 0xFF  # ensure 8-bit result
    
    return sequence

def bin_value(value):
    """
    Categorize the 8-bit value into one of 8 bins.
    
    Bin 0: 1 - 32
    Bin 1: 33 - 64
    Bin 2: 65 - 96
    Bin 3: 97 - 128
    Bin 4: 129 - 160
    Bin 5: 161 - 192
    Bin 6: 193 - 224
    Bin 7: 225 - 255
    """
    if value >= 1 and value <= 32:
        return 0
    elif value >= 33 and value <= 64:
        return 1
    elif value >= 65 and value <= 96:
        return 2
    elif value >= 97 and value <= 128:
        return 3
    elif value >= 129 and value <= 160:
        return 4
    elif value >= 161 and value <= 192:
        return 5
    elif value >= 193 and value <= 224:
        return 6
    elif value >= 225 and value <= 255:
        return 7
    else:
        return None

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
    
    # Categorize the sequence into bins
    bins = {i: [] for i in range(8)}
    for num in sequence:
        bin_idx = bin_value(num)
        if bin_idx is not None:
            bins[bin_idx].append(num)
    
    # Write results to a text file
    filename = "lfsr_binned_output.txt"
    with open(filename, "w") as f:
        f.write("LFSR Sequence (seed=0x{:02X}, taps=0x{:02X}):\n".format(seed, taps))
        for idx, num in enumerate(sequence):
            f.write("Cycle {:3d}: 0x{:02X} ({:3d})\n".format(idx, num, num))
        f.write("\nHistogram Binning:\n")
        for bin_idx in range(8):
            f.write("Bin {} (Range {}-{}): Count = {} \n".format(bin_idx, bin_idx*32+1, (bin_idx+1)*32, len(bins[bin_idx])))
            if bins[bin_idx]:
                # Write the numbers in this bin (both hex and decimal)
                for num in bins[bin_idx]:
                    f.write("  0x{:02X} ({:3d})\n".format(num, num))
            f.write("\n")
    
    print("LFSR sequence and binned output written to '{}'".format(filename))

if __name__ == "__main__":
    main()
