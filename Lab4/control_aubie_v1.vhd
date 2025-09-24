use work.bv_arithmetic.all;
use work.dlx_types.all;
entity aubie_controller is
generic(prop_delay: time := 5 ns;
            sec_prop_delay: time := 15 ns);
     
port(ir_control: in dlx_word;
alu_out: in dlx_word;
alu_error: in error_code;
clock: in bit;
regfilein_mux: out threeway_muxcode;
memaddr_mux: out threeway_muxcode;
addr_mux: out bit;
pc_mux: out bit;
alu_func: out alu_operation_code;
regfile_index: out register_index;
regfile_readnotwrite: out bit;
regfile_clk: out bit;
mem_clk: out bit;
mem_readnotwrite: out bit;
ir_clk: out bit;
imm_clk: out bit;
addr_clk: out bit;
pc_clk: out bit;
op1_clk: out bit;
op2_clk: out bit;
result_clk: out bit
);
end aubie_controller;
architecture behavior of aubie_controller is
begin
behav: process(clock) is
type state_type is range 1 to 20;
variable state: state_type := 1;
variable opcode: byte;
variable destination,operand1,operand2 : register_index;
begin
if clock'event and clock = '1' then
opcode := ir_control(31 downto 24);
destination := ir_control(23 downto 19);
operand1 := ir_control(18 downto 14);
operand2 := ir_control(13 downto 9);
case state is
when 1 => -- fetch the instruction, for all types
-- your code goes here

mem_readnotwrite <= '1' after prop_delay;
memaddr_mux <= "00" after prop_delay;
mem_clk <= '1' after prop_delay;--  hight to get mem_out
ir_clk <= '1' after prop_delay;--sit to 1, ir will recive signal 
state := 2;

when 2 =>
-- figure out which instruction
if opcode(7 downto 4) = "0000" then -- ALU op
state := 3;
elsif opcode = X"20" then -- STO
elsif opcode = X"30" or opcode = X"31" then -- LD or LDI
state := 7;
elsif opcode = X"22" then -- STOR
elsif opcode = X"32" then -- LDR
elsif opcode = X"40" or opcode = X"41" then -- JMP or JZ
elsif opcode = X"10" then -- NOOP
else -- error
end if;

when 3 =>
-- ALU op: load op1 register from the regfile
-- your code here
regfile_readnotwrite <= '1' after prop_delay;
regfile_index <= operand1 after prop_delay;
regfile_clk <= '1' after prop_delay;
op1_clk <= '1' after prop_delay;
state := 4;

when 4 =>
-- ALU op: load op2 registear from the regfile
-- your code here
regfile_readnotwrite <= '1' after prop_delay;
regfile_index <= operand2 after prop_delay;
regfile_clk <= '1' after prop_delay;
op2_clk <= '1' after prop_delay;
state := 5;

when 5 =>
-- ALU op: perform ALU operation
-- your code here
alu_func <= opcode(3 downto 0) after prop_delay;
result_clk <= '1' after prop_delay;
state := 6;

when 6 =>
-- ALU op: write back ALU operation
-- your code here
regfile_readnotwrite <= '0' after prop_delay;
regfilein_mux <= "00" after prop_delay;
regfile_index <= destination after prop_delay;
regfile_clk <= '1' after prop_delay;
pc_mux <= '0' after prop_delay; --pcplusone out
pc_clk <= '1' after prop_delay;
state := 1;

when 7 =>
-- LD or LDI: get the addr or immediate word
-- your code here

pc_mux <= '0' after prop_delay;
pc_clk <= '1' after prop_delay;
if opcode = X"30" then --LD
mem_readnotwrite <= '1' after prop_delay;
memaddr_mux <= "00" after prop_delay;
mem_clk <= '1' after prop_delay;
addr_mux <= '1' after prop_delay;
addr_clk <='1' after prop_delay;
elsif opcode = X"31" then --LDI
mem_readnotwrite <= '1' after prop_delay;
memaddr_mux <= "00" after prop_delay;
mem_clk <= '1' after prop_delay;
imm_clk <= '1' after prop_delay;
end if;
state := 8;

when 8 =>
-- LD or LDI
-- your code here
if opcode = X"30" then --LD
mem_readnotwrite <= '1' after prop_delay;
memaddr_mux <= "01" after prop_delay;
mem_clk <= '1' after prop_delay;
regfile_readnotwrite <= '0' after prop_delay;
regfile_index <= destination after prop_delay;
regfilein_mux <= "01" after prop_delay;
regfile_clk <= '1' after prop_delay;
elsif opcode = X"31" then --LDI
regfile_readnotwrite <= '0' after prop_delay;
regfile_index <= destination after prop_delay;
imm_clk <= '1' after prop_delay;
regfilein_mux <= "10" after prop_delay;
regfile_clk <= '1' after prop_delay;
end if;
pc_mux <= '0' after prop_delay;
pc_clk <= '1' after prop_delay;
state := 1;

when 9 => --STO-1
pc_mux <= '0' after prop_delay;
pc_clk <= '1' after prop_delay;
state := 10;

when 10 => --STO-2
mem_readnotwrite <= '1' after prop_delay;
memaddr_mux <= "00" after prop_delay;
mem_clk <= '1' after prop_delay;
addr_mux <= '1' after prop_delay;
addr_clk <='1' after prop_delay;
state := 11;
                  
when 11 => --STO-3
regfile_readnotwrite <= '1' after prop_delay;
regfile_index <= operand1 after prop_delay;
regfile_clk <= '1' after prop_delay;
mem_readnotwrite <= '0' after prop_delay;
pc_mux <= '1' after prop_delay, '0' after sec_prop_delay;
pc_clk <= '1' after prop_delay;
memaddr_mux <= "00" after prop_delay;
mem_clk <= '1' after prop_delay;
state := 1;

when 12 => --LDR-1
regfile_readnotwrite <= '1' after prop_delay;
regfile_index <= operand1 after prop_delay;
regfile_clk <= '1' after prop_delay;
addr_mux <= '0' after prop_delay;
addr_clk <= '1' after prop_delay;
state := 13;

when 13 => --LDR-2
mem_readnotwrite <= '1' after prop_delay;
memaddr_mux <= "01" after prop_delay;
mem_clk <= '1' after prop_delay;
regfile_index <= destination after prop_delay;
regfile_readnotwrite <= '0' after prop_delay;
regfilein_mux <= "01" after prop_delay;
regfile_clk <= '1' after prop_delay;
pc_mux <= '0' after prop_delay;
pc_clk <= '1' after prop_delay;
state := 1;

when 14 => --STOR_1
regfile_readnotwrite <= '1' after prop_delay;
regfile_index <= destination after prop_delay;
regfile_clk <= '1' after prop_delay;
addr_mux <= '0' after prop_delay;
addr_clk <= '1' after prop_delay;
state := 15;

when 15 => --STOR-2
regfile_readnotwrite <= '1' after prop_delay;
regfile_index <= operand1 after prop_delay;
regfile_clk <= '1' after prop_delay;
mem_readnotwrite <= '0' after prop_delay;
memaddr_mux <= "01" after prop_delay;
mem_clk <= '1' after prop_delay;
pc_mux <= '0' after prop_delay;
pc_clk <= '1' after prop_delay;
state := 1;

when 16 => --JMP or JZ--1
pc_mux <= '0' after prop_delay;
pc_clk <= '1' after prop_delay;
state := 17;

when 17 => --JMP or JZ--2
pc_clk <= '0' after prop_delay;
memaddr_mux <= "00" after prop_delay;
addr_mux <= '1' after prop_delay;
regfile_clk <= '0' after prop_delay;
mem_clk <= '1' after prop_delay;
mem_readnotwrite <= '1' after prop_delay;
ir_clk <= '0' after prop_delay;
imm_clk <= '0' after prop_delay;
addr_clk <= '1' after prop_delay;
op1_clk <= '0' after prop_delay;
op2_clk <= '0' after prop_delay;
result_clk <= '0' after prop_delay;
state := 18;


when 18 => --JMP or JZ--3
if (opcode = x"40") then
pc_mux <= '0' after prop_delay;
pc_clk <= '1' after prop_delay;
end if;
if (opcode = x"41") then
pc_mux <= '0' after prop_delay;
pc_clk <= '1' after prop_delay;
end if;
state := 1;
      
when 19 => --NOOP- do nothing
pc_mux <= '0';
pc_clk <= '1';
state := 1;

when others => null;
end case;
elsif clock'event and clock = '0' then
-- reset all the register clocks
-- your code here
regfile_clk <= '0';
mem_clk <= '0';
ir_clk <= '0';
imm_clk <= '0';
addr_clk <= '0';
pc_clk <= '0';
op1_clk <= '0';
op2_clk <= '0';
result_clk <= '0';
end if;
end process behav;
end behavior;