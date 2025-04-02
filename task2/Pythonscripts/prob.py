
import matplotlib.pyplot as plt

def lfsr_8bit(seed, taps, max_cycles=38):
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
        
        # Compute feedback: reduction XOR of (state & taps)
        feedback = 0
        temp = state & taps
        while temp:
            feedback ^= (temp & 1)
            temp >>= 1
        
        # Shift left by one and insert feedback at LSB
        state = ((state << 1) | feedback) & 0xFF
        
    return sequence

def bin_value(value):
    """
    Categorize the 8-bit value into one of 8 bins.
    
    Bins:
      Bin 0: 1  - 32
      Bin 1: 33 - 64
      Bin 2: 65 - 96
      Bin 3: 97 - 128
      Bin 4: 129 - 160
      Bin 5: 161 - 192
      Bin 6: 193 - 224
      Bin 7: 225 - 255
    """
    if 1 <= value <= 32:
        return 0
    elif 33 <= value <= 64:
        return 1
    elif 65 <= value <= 96:
        return 2
    elif 97 <= value <= 128:
        return 3
    elif 129 <= value <= 160:
        return 4
    elif 161 <= value <= 192:
        return 5
    elif 193 <= value <= 224:
        return 6
    elif 225 <= value <= 255:
        return 7
    else:
        return None

def main():
    # Get user inputs
    seed_str = input("Enter 8-bit seed (in hex, e.g., 42): ")
    taps_str = input("Enter 8-bit taps (in hex, e.g., B4): ")
    
    try:
        seed = int(seed_str, 16)
        taps = int(taps_str, 16)
    except ValueError:
        print("Invalid input. Please enter hex numbers.")
        return
    
    # Generate LFSR sequence
    sequence = lfsr_8bit(seed, taps)
    
    # Bin the sequence
    bins = {i: [] for i in range(8)}
    for num in sequence:
        bin_idx = bin_value(num)
        if bin_idx is not None:
            bins[bin_idx].append(num)
    
    # Print the counts for each bin
    print("\nHistogram Binning:")
    total = len(sequence)
    for i in range(8):
        count = len(bins[i])
        percentage = (count / total * 100) if total else 0
        print("Bin {}: Count = {}, Percentage = {:.2f}%".format(i, count, percentage))
    
    # Create probability distribution data for plotting
    bin_labels = ["Bin {}".format(i) for i in range(8)]
    counts = [len(bins[i]) for i in range(8)]
    probabilities = [count/total for count in counts]
    
    # Plot probability distribution
    plt.figure(figsize=(8, 4))
    plt.bar(bin_labels, probabilities, color='skyblue')
    plt.xlabel("Bins")
    plt.ylabel("Probability")
    plt.title("Probability Distribution of LFSR Output Across Bins\n(seed=0x{:02X}, taps=0x{:02X})".format(seed, taps))
    plt.ylim([0, 1])
    plt.grid(axis='y', linestyle='--', alpha=0.7)
    plt.show()
    
    # Optionally, write detailed results to a file
    with open("lfsr_binned_distribution.txt", "w") as f:
        f.write("LFSR Sequence (seed=0x{:02X}, taps=0x{:02X}):\n".format(seed, taps))
        for idx, num in enumerate(sequence):
            f.write("Cycle {:3d}: 0x{:02X} ({:3d})\n".format(idx, num, num))
        f.write("\nHistogram Binning:\n")
        for i in range(8):
            count = len(bins[i])
            percentage = (count / total * 100) if total else 0
            f.write("Bin {} (Range {}-{}): Count = {} ({:.2f}%)\n".format(i, i*32+1, (i+1)*32, count, percentage))
            for num in bins[i]:
                f.write("  0x{:02X} ({:3d})\n".format(num, num))
            f.write("\n")
    print("Detailed results written to 'lfsr_binned_distribution.txt'")

if __name__ == "__main__":
    main()
