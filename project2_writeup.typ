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

= CPU Summary

Our CPU module structure creates a single-cycle, 16-bit CPU which consists of a data memory interface, instruction memory interface, and also a debug interface.
The inputs for the structure are `clk`, `rst`, and `imem_data`, `dmem_rdata`, and `dbg_reg_sel`.
Meanwhile, the output is `imem_addr`, `dmem_addr`, `dmem_we`, `dmem_wdata`, `pc_o`, and `dbg_reg_data`.
The CPU state contains eight 16-bit registers (`R0`-`R7`) and a  program counter (`PC`).
The 16-bit instructions is split into a 4-bit opcode, three 3-bit register fields (`a`, `b`, and `c`) , and a 3-bit immediate field.
We also utilize combinational logic which combines memory or address (`R[b] + imm3`). The CPU supports instructions including addition (`add`), subtraction (`sub`), add immediate (`addi`), `and`, `or`, load (`ld`), store (`st`), and be equal (`BEQ`) operations.

= Test Program

The test program generates a clock, resets, loads a program into instruction memory, runs, and then checks select registers and memory values at the end.
The CPU waits for 250 nanoseconds, giving the program time to execute and then run the assertions.
If a value expected in memory or the register is not correct, then a string containing the failure will be printed.
If a value is correct, then a pass will be generated.
The current program utilizes the 8 opcodes and registers, proving the current design can perform basic arithmetic, loading and storing in memory, and that data correctly flows between registers and memory.

= Screenshots

// #figure(
//   image(""),
//   caption: [Waveform],
// )
//
// #figure(
//   image(""),
//   caption: [Console Output],
// )
