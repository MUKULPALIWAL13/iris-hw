# **AXI-Based Top Module Simulation**

## **Overview**
This project implements an AXI-based top module consisting of several submodules:
- **axi_ram**: Stores incoming data and outputs processed results.
- **top_module_full**: Integrates LFSR, FIFO, Histogram, and RAM.
- **Testbench (`top_module_tb`)**: Simulates and verifies functionality.

The project supports an **AXI-Lite interface** for LFSR configuration and an **AXI-Stream interface** for data flow between modules.

---

## **Module Descriptions**

### **1. AXI RAM (`axi_ram.v`)**
- Stores data received via AXI-Stream.
- Computes memory addresses dynamically using a base address and counter.
- Outputs stored values along with metadata.

#### **Output Packet Format:**  

```{ 4'b0000, bin_count (8 bits), final_storage_addr (12 bits), stored_value (8 bits) } ``` 


---

### **2. LFSR (`lfsrnew.v`)**
- Implements a **Linear Feedback Shift Register (LFSR)** for generating pseudo-random numbers.
- Configurable via AXI-Lite interface.
- Used for generating test data that is stored in RAM.

#### **Features:**
- Can be initialized with a **seed value**.
- Generates **8-bit pseudo-random numbers**.
- Uses **XOR feedback** with predefined taps for randomness.

#### **AXI-Lite Control Signals:**
- `s_axi_awaddr`: Write address for configuration.
- `s_axi_wdata`: Data to be written (seed, enable, etc.).
- `s_axi_rdata`: Read output.

---

### **3. Histogram Processor (`histnew.v`)**
- Categorizes incoming values into **8 bins**.
- Maintains a **counter** for each bin.
- Computes bin **address offsets** dynamically.

#### **Functionality:**
- Takes **input values from LFSR** and assigns them to **bins**.
- Increments **counters** corresponding to each bin.
- Sends bin index, counter address, storage address, and value to RAM.

#### **Output Format:**  
```{ 4'b0000, bin_count (8 bits), base_storage_addr (12 bits), stored_value (8 bits) }  ```


---

### **4. FIFO Buffer (`fifonew.v`)**
- Implements a **First-In-First-Out (FIFO)** buffer for intermediate data storage.
- Used for **smoothing data flow** between modules.
- Operates on the **AXI-Stream** interface.

#### **Features:**
- Handles **AXI-Stream transactions**.
- Provides **temporary storage** for histogram data before sending it to RAM.
- Ensures **data consistency and prevents data loss** in high-speed streaming.

#### **Signals:**
- `s_axis_tdata`: Input data to FIFO.
- `s_axis_tvalid`: Data valid signal.
- `m_axis_tdata`: Output data from FIFO.
- `m_axis_tvalid`: Output data valid signal.

---

### **5. FIFO to Text Logger (`fifototxt.v`)**
- Captures **FIFO output data** and writes it to a **text file**.
- Used for debugging and verifying data flow.

#### **Functionality:**
- Reads data from the **FIFO output stream**.
- Writes values to a **log file (`fifo_output.txt`)**.
- Useful for **analyzing system performance** and debugging.

---

### **6. Top-Level Module (`top_module_full.v`)**
- Integrates **LFSR, FIFO, Histogram, and RAM** into a single pipeline.
- Handles **AXI-Lite control** for configuring LFSR.
- Routes data through the **processing pipeline**.

#### **Modules Integrated:**
- **LFSR** (Linear Feedback Shift Register)
- **FIFO Buffer**
- **Histogram Processor**
- **RAM Storage**
- **FIFO Logger** (Writes FIFO output to a text file)

#### **Output Packet Format:**  

```{ 4'b0000, bin_count (8 bits), storage_addr (12 bits), processed_value (8 bits) }  ```


---

## **Testbench (`top_module_tb.v`)**
- Simulates the **full system**.
- Configures **LFSR via AXI-Lite**.
- Monitors **RAM outputs via AXI-Stream**.
- Validates expected results.

### **Test Process:**
1. **Reset system** (`aresetn` low, then high).
2. **Configure LFSR** via AXI-Lite writes.
3. **Start LFSR** and enable streaming.
4. **Capture and analyze AXI-Stream outputs**.
5. **Stop LFSR** and verify output cessation.

---

## **Running the Simulation**
### **Steps to Run in Verilog Simulator**
1. *Compile all Verilog files:*  
   *iverilog -o top_sim top_module_tb.v top_module_full.v axi_ram.v lfsrnew.v histnew.v fifonew.v fifototxt.v*
   
2. *Run the simulation:*  
   *vvp top_sim*
   
3. *View waveform (if applicable):*  
   *gtkwave top_module_tb.vcd*

---

## **Waveforms**

![Waveform Screenshot](lfsr.png)
![Waveform Screenshot](totaldetails.png)



| Signal Name       | Description                         |
|-------------------|-------------------------------------|
| **aclk**         | System clock                        |
| **aresetn**      | Active-low reset                    |
| **s_axi_awaddr** | AXI write address                   |
| **s_axi_wdata**  | AXI write data                      |
| **s_axi_rdata**  | AXI read data                       |
| **m_axis_tdata** | Output stream data                  |
| **m_axis_tvalid** | Output stream valid                |

---

## **Notes**
- Ensure to adjust **FIFO depth and LFSR seed/taps** as needed.
- The **FIFO Logger** writes output data to `fifo_output.txt`.


---

## **Author**
**Mukul Paliwal**  
**This project is part of IRIS LABS HARDWARE SUBMISSIONS**




