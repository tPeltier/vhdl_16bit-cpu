library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity cpu16 is
  port (
    clk  : in  std_logic;
    rst  : in  std_logic;

    -- Instruction memory (ROM)
    imem_addr : out unsigned(15 downto 0);
    imem_data : in  std_logic_vector(15 downto 0);

    -- Data memory (RAM) — word addressed
    dmem_addr  : out unsigned(15 downto 0);
    dmem_we    : out std_logic;
    dmem_wdata : out unsigned(15 downto 0);
    dmem_rdata : in  unsigned(15 downto 0);

    -- Debug
    pc_o : out unsigned(15 downto 0);
    dbg_r0 : out unsigned(15 downto 0);
    dbg_r1 : out unsigned(15 downto 0);
    dbg_r2 : out unsigned(15 downto 0);
    dbg_r3 : out unsigned(15 downto 0);
    dbg_r4 : out unsigned(15 downto 0);
    dbg_r5 : out unsigned(15 downto 0);
    dbg_r6 : out unsigned(15 downto 0);
    dbg_r7 : out unsigned(15 downto 0)
  );
end entity;

architecture rtl of cpu16 is
  -- =========================
  -- 0) CPU STATE
  -- =========================
  type regfile_t is array (0 to 7) of unsigned(15 downto 0);
  signal R  : regfile_t := (others => (others => '0'));
  signal PC : unsigned(15 downto 0) := (others => '0');
  signal dmem_addr_comb : unsigned(15 downto 0); -- NOTE: added to fix LD timing issue

  -- =========================
  -- 1) INSTRUCTION DECODE SIGNALS
  -- =========================
  signal instr  : std_logic_vector(15 downto 0);
  signal opcode : std_logic_vector(3 downto 0);
  signal a_u, b_u, c_u : unsigned(2 downto 0);
  signal imm3   : std_logic_vector(2 downto 0);

  -- =========================
  -- 2) HELPERS
  -- =========================
  function sext3(x : std_logic_vector(2 downto 0)) return signed is
    variable s : signed(15 downto 0);
  begin
    -- sign-extend 3-bit to 16-bit
    s := resize(signed(x), 16);
    return s;
  end function;

  function idx(u : unsigned(2 downto 0)) return integer is
  begin
    return to_integer(u);
  end function;

begin
  -- Debug
  pc_o <= PC;
  dbg_r0 <= R(0);
  dbg_r1 <= R(1);
  dbg_r2 <= R(2);
  dbg_r3 <= R(3);
  dbg_r4 <= R(4);
  dbg_r5 <= R(5);
  dbg_r6 <= R(6);
  dbg_r7 <= R(7);

  -- =========================
  -- 3) FETCH (combinational)
  -- =========================
  -- PC is a word-addressed instruction index
  imem_addr <= PC;
  instr     <= imem_data;

  -- =========================
  -- 4) DECODE (combinational)
  -- =========================
  -- NOTE (students): Keep these slices exactly.
  opcode <= instr(15 downto 12);
  a_u    <= unsigned(instr(11 downto 9));
  b_u    <= unsigned(instr(8 downto 6));
  c_u    <= unsigned(instr(5 downto 3));
  imm3   <= instr(2 downto 0);

  dmem_addr_comb <= unsigned(signed(R(idx(b_u))) + sext3(imm3)); -- NOTE: added to fix LD timing issue
  dmem_addr      <= dmem_addr_comb; -- NOTE: added to fix LD timing issue
  dmem_wdata     <= R(idx(c_u)); -- NOTE: added to fix ST issue that arose from fixing LD issue
  dmem_we        <= '1' when (opcode = "0110" and rst = '0') else '0'; -- NOTE: added to fix ST issue that arose from fixing LD issue

  -- =========================
  -- 5) SINGLE-CYCLE EXECUTE (sequential state updates)
  -- =========================
  process(clk)
    variable ra, rb, rc : integer range 0 to 7;
    variable off        : signed(15 downto 0);
    variable addr       : unsigned(15 downto 0);

    variable pc_next    : unsigned(15 downto 0);
    variable reg_we     : boolean;
    variable wdata      : unsigned(15 downto 0);
  begin
    if rising_edge(clk) then
      if rst = '1' then
        PC <= (others => '0');
        R  <= (others => (others => '0'));
        -- dmem_we <= '0'; -- NOTE: removed to fix ST issue that arose from fixing LD issue
        -- dmem_addr <= (others => '0'); -- NOTE: removed to fix LD timing issue
        -- dmem_wdata <= (others => '0'); -- NOTE: removed to fix ST issue that arose from fixing LD issue
      else
        -- -------------------------
        -- Defaults (IMPORTANT)
        -- -------------------------
        ra := idx(a_u);
        rb := idx(b_u);
        rc := idx(c_u);
        off := sext3(imm3);

        pc_next := PC + 1;      -- word addressed
        reg_we  := false;
        wdata   := (others => '0');

        -- dmem_we <= '0'; -- NOTE: removed to fix the ST issue that arose from fixing the LD issue

        -- Address for LD/ST: word addressed
        addr := unsigned(signed(R(rb)) + off);

        -- Drive memory interface (safe defaults)
        -- dmem_addr  <= addr; -- NOTE: removed to fix LD timing issue
        -- dmem_wdata <= R(rc); -- NOTE: removed to fix ST issue that arose from fixing LD issue

        -- -------------------------
        -- ISA behavior
        -- -------------------------
        case opcode is
          when "0000" =>  -- ADD  Ra,Rb,Rc
            reg_we := true;
            wdata  := R(rb) + R(rc);

          when "0001" =>  -- SUB  Ra,Rb,Rc
            reg_we := true;
            wdata  := R(rb) - R(rc);

          when "0010" =>  -- AND  Ra,Rb,Rc
            reg_we := true;
            wdata  := R(rb) and R(rc);

          when "0011" =>  -- OR   Ra,Rb,Rc
            reg_we := true;
            wdata  := R(rb) or R(rc);

          when "0100" =>  -- ADDI Ra,Rb,imm3
            reg_we := true;
            wdata  := unsigned(signed(R(rb)) + off);

          when "0101" =>  -- LD Ra,[Rb+imm3]
            reg_we := true;
            wdata  := dmem_rdata;

          when "0110" =>  -- ST Rc,[Rb+imm3]
                          -- dmem_we <= '1'; -- NOTE: removed to fix the ST issue that arose from fixing LD issue

          when "0111" =>  -- BEQ Rb,Rc,imm3
            if R(rb) = R(rc) then
              pc_next := PC + 1 + unsigned(off);
            end if;

          when others =>
            null;
        end case;

        -- -------------------------
        -- Writeback + PC update
        -- -------------------------
        if reg_we then
          R(ra) <= wdata;
        end if;

        PC <= pc_next;
      end if;
    end if;
  end process;

end architecture;
