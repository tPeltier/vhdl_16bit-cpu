#set page(
  paper: "us-letter",
  margin: (x: 1in, y: 1in),
)
#set text(
  font: "Consolas",
  size: 10pt,
)
#set par(
  leading: 0.6em,
  spacing: 0.5em,
  justify: false,
  first-line-indent: 1.5em,
)
#let today = datetime.today()
#show heading: set block(above: 1.4em, below: 1em)
#show link: set text(blue)
#show link: underline

// --- TITLE ---
#align(center, text(17pt)[
  *Project 2*\
  *Single Cycle 16-bit CPU in VHDL*
])
#align(center, text(13pt)[
  CPSC 5700\
  \
  Justice Peltier\
  NWW612\
  Lewis Green\
  XLL755
])
#align(center, text(11pt)[
  #today.display()
])

= Link to EDA Project

= Module Structure
Our module implements a single-cycle, 16-bit CPU composed of an instruction memory interface, a data memory interface, and a debug interface that exposes all internal registers. 
Inputs include clk, rst, imem_data, and dmem_rdata, while outputs consist of imem_addr, dmem_addr, dmem_we, dmem_wdata, pc_o, and debug signals for registers R0–R7. 
CPU state contains eight 16-bit general-purpose registers along with a program counter (PC). Each instruction is 16 bits wide and partitioned into a 4-bit opcode, three 3-bit 
register fields (a, b, c), and a 3-bit immediate value that is sign-extended during execution. Combinational logic computes effective addresses such as (R[b] + imm3) for memory 
operations. Supported instructions include addition (add), subtraction (sub), add immediate (addi), bitwise AND (and), bitwise OR (or), load (ld), store (st), and branch-if-equal (beq).

= Test Program
The testbench generates a clock signal and applies a reset to initialize the CPU before loading a predefined program into instruction memory. 
After initialization, the CPU is allowed to run for approximately 250 nanoseconds, providing sufficient time for all instructions in the program to execute. 
Once execution is completed, the testbench evaluates specific register values and memory locations to verify correct behavior. Assertions are used to compare expected 
results with actual outputs; any mismatch produces an error message indicating failure, while correct values generate confirmation messages.

Program execution exercises all supported opcodes and utilizes multiple registers to validate functionality across the Datapath. 
Arithmetic and logical operations are tested through sequences of add, subtract, AND, and OR instructions. Memory operations are verified by storing computed values into 
data memory and subsequently loading them back into registers. A branch instruction is also included to confirm proper control flow and conditional execution. Overall, this 
testbench ensures that the CPU correctly performs instruction execution, data movement, and interaction between registers and memory.


= Screenshots

// #figure(
//   image("wave_screenshot.png"),
//   caption: [Waveform],
// )
//
// #figure(
//   image("pass_Output.png"),
//   caption: [Console Output],
// )
