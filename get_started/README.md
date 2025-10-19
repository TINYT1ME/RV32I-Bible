# Get Started
> 🚨 **Prerequisite Software**
> Before starting, make sure you have all prerequisite software installed.
> See the [here](PREREQ.md) file for detailed instructions.

This get started section is used to demonstrate the development process using the tools found in [prereq. software](PREREQ.md). This section will show how to go from nothing to functional and tested hdl ready to be programmed onto an FPGA.

## **Project Overview**

This project demonstrates the development tools by building a **4-bit counter and memory system** with dual 7-segment displays.

**What we'll build:**
- A 4-bit counter (displayed on left 7-segment)
- A 3-word memory with auto-cycling addresses (current address value shown on right 7-segment)
- Ability to increment the counter and store values in memory

While this project has no practical application, it effectively showcases the the development process/testing process with the tools we will be using to create the RV32I CPU.


### **User Interface**

| **Control** | **Function** | **Description** |
|-------------|--------------|-----------------|
| **SW1** | Clock | Advances memory operations |
| **SW2** | Increment Counter | Increases counter value (0->1->2...->F->0) |
| **SW3** | Toggle Write Enable | Enable/disable memory writing |
| **SW4** | Toggle Address Increment | Enable/disable automatic address cycling |

| **Display** | **Shows** |
|-------------|-----------|
| **Left 7-Seg** | Current Counter |
| **Right 7-Seg** | Memory Data | 
| **LED1** | Write Enable | 
| **LED2** | Address Increment | 

### **Flow**

1. **Initialize**: Counter starts at 'A' (10), memory address cycling enabled
2. **Increment**: Press SW2 to increase counter (A->B->C...->F->0->1...)
3. **Clock**: Press SW1 to advance memory operations
4. **Store**: Toggle SW3 to enable writing, then clock to store counter in memory
5. **Navigate**: Toggle SW4 to control address auto-increment

### **Required Components**

We must create the following SystemVerilog modules:

- **`four_bit_memory.sv`** - 3-word memory with address cycling
- **`seven_segment.sv`** - Dual 7-segment display driver  
- **`main.sv`** - Top-level integration module

## 1.  Creating the project
> Make sure you are in the python venv
```bash
mkdir example && cd example
```
I am using the [Go-board](https://nandland.com/the-go-board/) and will continue the walkthrough targeting the [ICE40](https://www.latticesemi.com/ice40) chip. 
> Note: Apio currently supports the ICE40, ECP5, and GOWIN FPGA architectures

**List and Fetch example template with Apio**
```bash
# List all examples
apio examples list

# I am using the go-board so I will select go-board/template
apio examples fetch go-board/template

ls # apio.ini, go-board.pcf, main_tb.gtkw, main_tb.v, main.v

# Delete files as we will write our own
rm main_tb.v
rm main.v
```
> ❗Take a look at go-board.pcf
> This file is a map to our hardware, we will use the names found in this file to interface with our board(ie LED1, SW1...)

## 2. four_bit_memory.sv

Create a new file called `four_bit_memory.sv` - this will be our core memory component.

#### **Inputs**
- **Clock**
- **Write Enable** - Controls write operations (active high)
- **Increment Address** - When enabled, address automatically increments
- **Write Data** - 4-bit data to be written to memory

#### **Outputs**
- **Read Data** - 4-bit data read from current memory location

#### **Info**
- **Memory Size**: 3 words × 4 bits each
- **Address Range**: 0, 1, 2 (with automatic wrapping)
- **Data Width**: 4 bits
```sv
// ============================================================================
// Four-Bit Memory Module
// ============================================================================
//   - 3 memory locations (addresses 0, 1, 2)
//   - 4-bit data width
//   - Automatic address increment with wrapping
// ============================================================================

module four_bit_memory (
    input  logic       clk,              // System clock
    input  logic       write_enable,     // Write enable (active high)
    input  logic       increment_address,// Address increment enable
    input  logic [3:0] write_data,       // Data to write (4 bits)
    output logic [3:0] read_data         // Data read from memory (4 bits)
);

    // ========================================================================
    // Memory Declaration
    // ========================================================================
    reg [3:0] memory [0:2];  // 3 words of 4-bit data each
    
    // Initialize memory with test data
    initial begin
        memory[0] <= 4'b0001;  // Address 0: 1 decimal
        memory[1] <= 4'b0010;  // Address 1: 2 decimal
        memory[2] <= 4'b0011;  // Address 2: 3 decimal
    end

    // ========================================================================
    // Address Management
    // ========================================================================
    reg [1:0] current_address = 2'b00;  // Current memory address (0-2)
    
    // Address increment logic with write protection
    always @(posedge clk) begin
        if (increment_address && ~write_enable) begin
            // Increment address with wrapping
            if (current_address == 2'b10)      // At address 2
                current_address <= 2'b00;      // Wrap to address 0
            else
                current_address <= current_address + 1;  // Normal increment
        end
    end

    // ========================================================================
    // Write Logic
    // ========================================================================
    always @(posedge clk) begin
        if (write_enable) begin
            memory[current_address] <= write_data;  // Write data to current address
        end
    end

    // ========================================================================
    // Read Logic
    // ========================================================================
    always_comb begin
        read_data = memory[current_address];  // Combinational read from current address
    end

endmodule
```
### four_bit_memory.sv Memory Section in the works
## 3. seven_segment.sv

Create a new file called `seven_segment.sv` - this will handle our display output for the 7-seg displays


#### **Inputs**
- **Left Digit** - 4-bit input (0-15) for the left display
- **Right Digit** - 4-bit input (0-15) for the right display

#### **Outputs**
- **S1_A through S1_G** - 7-segment outputs for display 1 (right)
- **S2_A through S2_G** - 7-segment outputs for display 2 (left)

#### **Info**
- **Display Range**: 0-15 (0-9, A-F)

### seven_segment.sv Verification Section in the works

```sv
// ============================================================================
// Seven-Segment Display Driver Module
// ============================================================================
//   4-bit input range (0-15, displays 0-9, A-F)
//   Converts inputs to two 7-segment displays (left and right)
// ============================================================================

module seven_segment (
    input  wire [3:0] left_digit,        // 4-bit input for left display (0-15)
    input  wire [3:0] right_digit,       // 4-bit input for right display (0-15)
    output wire S1_A, S1_B, S1_C, S1_D, S1_E, S1_F, S1_G,  // Right display segments
    output wire S2_A, S2_B, S2_C, S2_D, S2_E, S2_F, S2_G   // Left display segments
);

    // ========================================================================
    // Internal Signal Declaration
    // ========================================================================
    reg [6:0] seg_pattern;   // 7-segment pattern for right display
    reg [6:0] seg_pattern2;  // 7-segment pattern for left display

    // ========================================================================
    // 7-Segment Pattern Generation
    // ========================================================================
    // Generate patterns for both displays based on input values
    always @(*) begin
        // Right display pattern generation
        case (left_digit)
            4'd0:  seg_pattern2 = 7'b1000000;  // 0
            4'd1:  seg_pattern2 = 7'b1111001;  // 1
            4'd2:  seg_pattern2 = 7'b0100100;  // 2
            4'd3:  seg_pattern2 = 7'b0110000;  // 3
            4'd4:  seg_pattern2 = 7'b0011001;  // 4
            4'd5:  seg_pattern2 = 7'b0010010;  // 5
            4'd6:  seg_pattern2 = 7'b0000010;  // 6
            4'd7:  seg_pattern2 = 7'b1111000;  // 7
            4'd8:  seg_pattern2 = 7'b0000000;  // 8
            4'd9:  seg_pattern2 = 7'b0010000;  // 9
            4'd10: seg_pattern2 = 7'b0001000;  // A
            4'd11: seg_pattern2 = 7'b0000011;  // b
            4'd12: seg_pattern2 = 7'b1000110;  // C
            4'd13: seg_pattern2 = 7'b0100001;  // d
            4'd14: seg_pattern2 = 7'b0000110;  // E
            4'd15: seg_pattern2 = 7'b0001110;  // F
            default: seg_pattern2 = 7'b1111111; // All segments off
        endcase

        // Left display pattern generation
        case (right_digit)
            4'd0:  seg_pattern = 7'b1000000;  // 0
            4'd1:  seg_pattern = 7'b1111001;  // 1
            4'd2:  seg_pattern = 7'b0100100;  // 2
            4'd3:  seg_pattern = 7'b0110000;  // 3
            4'd4:  seg_pattern = 7'b0011001;  // 4
            4'd5:  seg_pattern = 7'b0010010;  // 5
            4'd6:  seg_pattern = 7'b0000010;  // 6
            4'd7:  seg_pattern = 7'b1111000;  // 7
            4'd8:  seg_pattern = 7'b0000000;  // 8
            4'd9:  seg_pattern = 7'b0010000;  // 9
            4'd10: seg_pattern = 7'b0001000;  // A
            4'd11: seg_pattern = 7'b0000011;  // b
            4'd12: seg_pattern = 7'b1000110;  // C
            4'd13: seg_pattern = 7'b0100001;  // d
            4'd14: seg_pattern = 7'b0000110;  // E
            4'd15: seg_pattern = 7'b0001110;  // F
            default: seg_pattern = 7'b1111111; // All segments off
        endcase
    end

    // ========================================================================
    // Output Assignment - Right Display (S1)
    // ========================================================================
    assign S1_A = seg_pattern[0];  // Segment a
    assign S1_B = seg_pattern[1];  // Segment b
    assign S1_C = seg_pattern[2];  // Segment c
    assign S1_D = seg_pattern[3];  // Segment d
    assign S1_E = seg_pattern[4];  // Segment e
    assign S1_F = seg_pattern[5];  // Segment f
    assign S1_G = seg_pattern[6];  // Segment g

    // ========================================================================
    // Output Assignment - Left Display (S2)
    // ========================================================================
    assign S2_A = seg_pattern2[0]; // Segment a
    assign S2_B = seg_pattern2[1]; // Segment b
    assign S2_C = seg_pattern2[2]; // Segment c
    assign S2_D = seg_pattern2[3]; // Segment d
    assign S2_E = seg_pattern2[4]; // Segment e
    assign S2_F = seg_pattern2[5]; // Segment f
    assign S2_G = seg_pattern2[6]; // Segment g

endmodule
```

### seven_segment.sv Verification Section in the works

## 4. main.sv

Create a new file called `main.sv` - this will be our top-level module that connects everything together.

#### **Inputs**
- **SW1** - Clock input for memory operations
- **SW2** - Push button to increment the counter
- **SW3** - Push button to toggle write enable
- **SW4** - Push button to toggle increment enable

#### **Outputs**
- **LED1** - Write enable indicator LED
- **LED2** - Increment enable indicator LED
- **S1_A - S1_G** - Right 7-segment display segments
- **S2_A - S2_G** - Left 7-segment display segments


```sv
// ============================================================================
// Top-Level Main Module
// ============================================================================

module top (
    input  wire SW1,                    // Clock input for memory
    input  wire SW2,                    // Counter increment button
    input  wire SW3,                    // Write enable toggle button
    input  wire SW4,                    // Increment address toggle button
    output wire LED1,                   // Write enable indicator LED
    output wire LED2,                   // Increment address indicator LED
    output wire S1_A, S1_B, S1_C, S1_D, S1_E, S1_F, S1_G,  // Right 7-segment display
    output wire S2_A, S2_B, S2_C, S2_D, S2_E, S2_F, S2_G   // Left 7-segment display
);

    // ========================================================================
    // Internal Signal Declaration
    // ========================================================================
    logic [3:0] read_data;              // Data read from memory
    logic [3:0] count = 4'b1010;        // 4-bit counter value (Start at A)
    logic       write_enable = 1'b0;    // Write enable signal
    logic       increment_address = 1'b1; // Increment address signal

    // ========================================================================
    // Memory Module Instantiation
    // ========================================================================
    four_bit_memory four_bit_memory_inst (
        .clk(SW1),                      // Clock from SW1
        .write_enable(write_enable),    // Write enable control
        .increment_address(increment_address), // Increment address control
        .write_data(count),             // Write counter value to memory
        .read_data(read_data)           // Read data from memory
    );

    // ========================================================================
    // Counter Logic
    // ========================================================================
    always @(posedge SW2) begin
        count <= count + 1;             // Increment counter
    end

    // ========================================================================
    // Increment Address Toggle
    // ========================================================================
    always @(posedge SW4) begin
        increment_address <= ~increment_address; // Toggle increment address
    end

    // ========================================================================
    // Write Enable Toggle
    // ========================================================================
    always @(posedge SW3) begin
        write_enable <= ~write_enable;  // Toggle write enable
    end

    // ========================================================================
    // 7-Segment Display Module Instantiation
    // ========================================================================
    seven_segment seven_segment_inst (
        .left_digit(read_data),         // Left display shows memory data
        .right_digit(count),            // Right display shows counter
        .S1_A(S1_A), .S1_B(S1_B), .S1_C(S1_C), .S1_D(S1_D),  // Right display
        .S1_E(S1_E), .S1_F(S1_F), .S1_G(S1_G),
        .S2_A(S2_A), .S2_B(S2_B), .S2_C(S2_C), .S2_D(S2_D),  // Left display
        .S2_E(S2_E), .S2_F(S2_F), .S2_G(S2_G)
    );

    // ========================================================================
    // Status LED
    // ========================================================================
    assign LED1 = write_enable;         // LED indicates write enable state
    assign LED2 = increment_address;    // LED indicates increment address state

endmodule
```

### main.sv Verification Section in the works

## 5. Build & Upload
>If you are not using Apio, this section does not apply to you
Now that we are done we can upload and build to our fpga board.


**apio.ini**\
Make sure the **board** you use is the one selected here, and the **top-module** matches the name in **main.sv**
```
[env:default]
board = go-board
top-module = top
```



> Make sure your board is connected
```bash
apio build
apio upload
```
You should now be able to play around with our system on your physical board