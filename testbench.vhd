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
      pc_o      : out unsigned(15 downto 0)
    );
  end component;

begin
  -- =========================
  -- 4) CLOCK GENERATOR
  -- =========================
  -- TODO (students): Do not change. Clock toggles until done='1'.
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
      pc_o      => pc
    );

  -- =========================
  -- 6) IMEM / DMEM BEHAVIOR
  -- =========================
  -- IMEM is ROM: combinational read
  -- TODO (students): Keep this exact behavior.
  imem_data <= IMEM(to_integer(imem_addr(7 downto 0)));

  -- DMEM read is combinational
  -- TODO (students): Keep this exact behavior.
  dmem_rdata <= DMEM(to_integer(dmem_addr(7 downto 0)));

  -- DMEM write is synchronous on rising edge
  -- TODO (students): Keep this exact behavior.
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
      end if;
    end procedure;

    -- TODO (optional): add check_pc, check_signal, etc.
    -- procedure check_pc(expected : integer) is ...
  begin
    -- -----------------------------------------
    -- (A) Load a program into IMEM
    -- -----------------------------------------
    -- TODO (students): Put your program words here.
    -- Example format:
    -- IMEM(0) <= x"4203";
    -- IMEM(1) <= x"4242";
    --
    -- If you are using the instructor-provided reference program,
    -- paste all words exactly as provided in the manual.
    --
    -- === START PROGRAM LOAD ===
    -- TODO: IMEM(...) <= x"....";
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
    -- TODO (students): Add checks for correctness.
    -- At minimum: check one DMEM location and/or expected outputs.
    --
    -- Example:
    -- check_dmem(2, 8);

    -- TODO: Print final PASS only if all checks passed.
    report "FINAL: PASS" severity note;

    -- Stop the clock and end simulation
    done <= '1';
    wait;
  end process;

end architecture;
