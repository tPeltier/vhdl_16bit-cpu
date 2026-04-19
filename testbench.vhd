library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity tb is
end entity;

architecture sim of tb is
  -- =========================
  -- 0) CLOCK / RESET
  -- =========================
  signal clk  : std_logic := '0';
  signal rst  : std_logic := '1';
  signal done : std_logic := '0';   -- when '1', stop the clock

  -- =========================
  -- 1) CPU <-> MEMORY SIGNALS
  -- =========================
  signal imem_addr : unsigned(15 downto 0);
  signal imem_data : std_logic_vector(15 downto 0);

  signal dmem_addr  : unsigned(15 downto 0);
  signal dmem_we    : std_logic;
  signal dmem_wdata : unsigned(15 downto 0);
  signal dmem_rdata : unsigned(15 downto 0);

  signal pc : unsigned(15 downto 0);
  signal dbg_r0 : unsigned(15 downto 0);
  signal dbg_r1 : unsigned(15 downto 0);
  signal dbg_r2 : unsigned(15 downto 0);
  signal dbg_r3 : unsigned(15 downto 0);
  signal dbg_r4 : unsigned(15 downto 0);
  signal dbg_r5 : unsigned(15 downto 0);
  signal dbg_r6 : unsigned(15 downto 0);
  signal dbg_r7 : unsigned(15 downto 0);

  -- =========================
  -- 2) SIMPLE ROM / RAM MODELS
  -- =========================
  type imem_t is array (0 to 255) of std_logic_vector(15 downto 0);
  type dmem_t is array (0 to 255) of unsigned(15 downto 0);

  signal IMEM : imem_t := (others => (others => '0'));
  signal DMEM : dmem_t := (others => (others => '0'));

  -- =========================
  -- 3) DUT COMPONENT
  -- =========================
  component cpu16 is
    port (
      clk       : in  std_logic;
      rst       : in  std_logic;
      imem_addr : out unsigned(15 downto 0);
      imem_data : in  std_logic_vector(15 downto 0);
      dmem_addr : out unsigned(15 downto 0);
      dmem_we   : out std_logic;
      dmem_wdata: out unsigned(15 downto 0);
      dmem_rdata: in  unsigned(15 downto 0);
      pc_o      : out unsigned(15 downto 0);
      dbg_r0 : out unsigned(15 downto 0);
      dbg_r1 : out unsigned(15 downto 0);
      dbg_r2 : out unsigned(15 downto 0);
      dbg_r3 : out unsigned(15 downto 0);
      dbg_r4 : out unsigned(15 downto 0);
      dbg_r5 : out unsigned(15 downto 0);
      dbg_r6 : out unsigned(15 downto 0);
      dbg_r7 : out unsigned(15 downto 0)
    );
  end component;

begin
  -- =========================
  -- 4) CLOCK GENERATOR
  -- =========================
  -- NOTE: (students): Do not change. Clock toggles until done='1'.
  clock_gen: process
  begin
    while done = '0' loop
      clk <= '0'; wait for 5 ns;
      clk <= '1'; wait for 5 ns;
    end loop;
    clk <= '0';
    wait;
  end process;

  -- =========================
  -- 5) INSTANTIATE CPU
  -- =========================
  dut: cpu16
    port map(
      clk       => clk,
      rst       => rst,
      imem_addr => imem_addr,
      imem_data => imem_data,
      dmem_addr => dmem_addr,
      dmem_we   => dmem_we,
      dmem_wdata=> dmem_wdata,
      dmem_rdata=> dmem_rdata,
      pc_o      => pc,
      dbg_r0    => dbg_r0,
      dbg_r1    => dbg_r1,
      dbg_r2    => dbg_r2,
      dbg_r3    => dbg_r3,
      dbg_r4    => dbg_r4,
      dbg_r5    => dbg_r5,
      dbg_r6    => dbg_r6,
      dbg_r7    => dbg_r7
    );

  -- =========================
  -- 6) IMEM / DMEM BEHAVIOR
  -- =========================
  -- IMEM is ROM: combinational read
  -- NOTE: (students): Keep this exact behavior.
  imem_data <= IMEM(to_integer(imem_addr(7 downto 0)));

  -- DMEM read is combinational
  -- NOTE: (students): Keep this exact behavior.
  dmem_rdata <= DMEM(to_integer(dmem_addr(7 downto 0)));

  -- DMEM write is synchronous on rising edge
  -- NOTE: (students): Keep this exact behavior.
  process(clk)
  begin
    if rising_edge(clk) then
      if dmem_we = '1' then
        DMEM(to_integer(dmem_addr(7 downto 0))) <= dmem_wdata;
      end if;
    end if;
  end process;

  -- =========================
  -- 7) TEST PROGRAM + CHECKS
  -- =========================
  process
    -- -----------------------------------------
    -- Helper check procedures (students can add more)
    -- -----------------------------------------
    procedure check_dmem(addr : integer; expected : integer) is
      variable got : integer;
    begin
      got := to_integer(DMEM(addr));
      if got /= expected then
        report "FAIL: DMEM[" & integer'image(addr) &
               "] expected=" & integer'image(expected) &
               " got=" & integer'image(got)
          severity failure;
      else
        report "PASS: DMEM[" & integer'image(addr) &
               "] = "     & integer'image(got)
          severity note;
      end if;
    end procedure;

    procedure check_reg(reg : integer; expected : integer) is
                        variable got : integer;
    begin
        case reg is
            when 0 => got := to_integer(dbg_r0);
            when 1 => got := to_integer(dbg_r1);
            when 2 => got := to_integer(dbg_r2);
            when 3 => got := to_integer(dbg_r3);
            when 4 => got := to_integer(dbg_r4);
            when 5 => got := to_integer(dbg_r5);
            when 6 => got := to_integer(dbg_r6);
            when 7 => got := to_integer(dbg_r7);
            when others => got := -1;
        end case;
        if got /= expected then
            report "FAIL: R" & integer'image(reg) &
            " expected=" & integer'image(expected) &
            " got="      & integer'image(got)
            severity failure;
        else
            report "PASS: R" & integer'image(reg) &
                   " = "     & integer'image(got)
            severity note;
        end if;
    end procedure;

    procedure check_pc(expected : integer) is
      variable got : integer;
    begin
      got := to_integer(pc);
      if got /= expected then
        report "FAIL: PC expected=" & integer'image(expected) &
               " got=" & integer'image(got)
          severity failure;
      else
        report "PASS: PC = " & integer'image(got) severity note;
      end if;
    end procedure;

    -- TODO (optional): add check_pc, check_signal, etc.
    -- procedure check_pc(expected : integer) is ...
  begin
    -- -----------------------------------------
    -- (A) Load a program into IMEM
    -- -----------------------------------------
    -- === START PROGRAM LOAD ===
    -- NOTE: IMEM(...) <= x"....";
    IMEM(0) <= x"4203"; -- ADDI  R1, R0, 3       ; R1 = i = 3
    IMEM(1) <= x"4407"; -- ADDI  R2, R0, -1      ; R2 = -1
    IMEM(2) <= x"3a50"; -- OR    R5, R1, R2      ; R5 = 3 OR -1 = -1
    IMEM(3) <= x"6049"; -- ST    R1, [R1 + 1]    ; mem[4] = 3
    IMEM(4) <= x"5841"; -- LD    R4, [R1 + 1]    ; R4 = 3
    IMEM(5) <= x"06c8"; -- ADD   R3, R3, R1      ; sum += i | loop top
    IMEM(6) <= x"4247"; -- ADDI  R1, R1, -1      ; i--
    IMEM(7) <= x"7041"; -- BEQ   R1, R0, 1       ; if i==0 jump to PC9
    IMEM(8) <= x"704c"; -- BEQ   R1, R1, -4      ; "unconditional" jump to PC5
    IMEM(9) <= x"611a"; -- ST    R3, [R4 + 2]    ; mem[5] = 6
    IMEM(10) <= x"1d10"; -- SUB   R6, R4, R2      ; R6 = 3-(-1) = 4
    IMEM(11) <= x"6031"; -- ST    R6, [R0 + 1]    ; mem[1] = 4
    IMEM(12) <= x"2ce0"; -- AND   R6, R3, R4      ; R6 = 6 AND 3 = 2
    IMEM(13) <= x"6032"; -- ST    R6, [R0 + 2]    ; mem[2] = 2
    IMEM(14) <= x"4cc7"; -- ADDI  R6, R3, -1      ; R6 = 5
    IMEM(15) <= x"6033"; -- ST    R6, [R0 + 3]    ; mem[3] = 5
    -- === END PROGRAM LOAD ===

    -- -----------------------------------------
    -- (B) Reset sequence
    -- -----------------------------------------
    rst <= '1';
    wait for 25 ns;
    rst <= '0';

    -- -----------------------------------------
    -- (C) Run simulation long enough
    -- -----------------------------------------
    -- TODO (students): adjust runtime if your program is longer.
    wait for 250 ns;

    -- -----------------------------------------
    -- (D) Checks (self-checking requirement)
    -- -----------------------------------------
    check_dmem(1, 4);
    check_dmem(2, 2);
    check_dmem(3, 5);
    check_dmem(4, 3);
    check_dmem(5, 6);
    check_reg(0, 0);
    check_reg(1, 0);
    check_reg(2, 65535); -- -1
    check_reg(3, 6);
    check_reg(4, 3);
    check_reg(5, 65535); -- -1
    check_reg(6, 5);
    check_reg(7, 0);
    check_pc(18);

    -- TODO: Print final PASS only if all checks passed.
    report "FINAL: PASS" severity note;

    -- Stop the clock and end simulation
    done <= '1';
    wait;
  end process;

end architecture;
