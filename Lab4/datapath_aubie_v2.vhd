-- datapath_aubie.vhd
-- entity reg_file (lab 2)
use work.dlx_types.all;
use work.bv_arithmetic.all;

entity reg_file is
      generic(prop_delay: Time := 15 ns);
      port (data_in: in dlx_word; readnotwrite, clock: in bit; data_out: out dlx_word; reg_number: in register_index);
end entity reg_file;


architecture behavior of reg_file is
      type reg_type is array (0 to 31) of dlx_word;
begin
      reg_file: process(readnotwrite, clock, data_in, reg_number) is
            variable registers : reg_type;
      begin
            if clock = '1' then
                  if readnotwrite = '1' then
                        data_out <= registers(bv_to_integer(reg_number)) after prop_delay;
                  else
                        registers(bv_to_integer(reg_number)) := data_in;
                  end if;
            
                  
            end if;
      end process reg_file;
end architecture behavior;

-- entity alu (lab 3)
use work.dlx_types.all;
use work.bv_arithmetic.all;
entity alu is
generic(prop_delay : Time := 5 ns);
port(operand1, operand2: in dlx_word; operation: in alu_operation_code;
result: out dlx_word; error: out error_code);
end entity alu;

architecture behavior of alu is
begin
      alu_process: process(operand1, operand2, operation) is
            

            variable divide_by_zero: boolean;
            variable op_result: dlx_word; 
            variable op_flow: boolean;    
            variable op1: boolean;
            variable op2: boolean;
      begin
            -- variables
            error <= "0000";
            op1 := false;
            op1 := false;
            --0000  unsigned add
            if operation = "0000" then
                  bv_addu(operand1, operand2, op_result, op_flow);
                  if op_flow then
                        error <= "0001" after prop_delay;
                  end if;
                  result <= op_result after prop_delay;
            --0001 unsigned subtract
            elsif operation = "0001" then
                  bv_subu(operand1, operand2, op_result, op_flow);
                  if op_flow then
                        error <= "0010" after prop_delay;
                  end if;
                  result <= op_result after prop_delay;
            --0010  two's complement add
            elsif operation = "0010" then
                  bv_add(operand1, operand2, op_result, op_flow);
                  if op_flow then
                        --If added two positives and get a negative: overflow
                        if ((operand1(31) = '0') and (operand2(31) = '0') and (op_result(31) = '1')) then
                              error <= "0001" after prop_delay;
                        --If added two negatives and get a positive: underflow
                        elsif ((operand1(31) = '1') and (operand2(31) = '1') and (op_result(31) = '0')) then
                              error <= "0010" after prop_delay;
                        end if;
                  end if;
                  result <= op_result after prop_delay;
            --0011 two's complement subtract
            elsif operation = "0011" then
                  bv_sub(operand1, operand2, op_result, op_flow);
                  if op_flow then
                        --If subtract a - from + and get a negative: overflow
                        if ((operand1(31) = '0') and (operand2(31) = '1') and (op_result(31) = '1')) then
                              error <= "0001" after prop_delay;   
                        --If subtract a + from - and get a positive: underflow
                        elsif ((operand1(31) = '1') and (operand2(31) = '0') and (op_result(31) = '0')) then
                              error <= "0010" after prop_delay;
                        end if;
                  end if;
                  result <= op_result after prop_delay;
            --0100  two's complement multiply
            elsif operation = "0100" then
                  bv_mult(operand1, operand2, op_result, op_flow);
                  if op_flow then
                        --If multiply a positive with a negative and get a positive: underflow
                        if ((operand1(31) = '0') and (operand2(31) = '1') and (op_result(31) = '0')) then   
                              error <= "0010" after prop_delay;
                        elsif ((operand1(31) = '1') and (operand2(31) = '0') and (op_result(31) = '0')) then
                              error <= "0010" after prop_delay;
                        --If  multiply two positves or negatives and get a negative: overflow
                        elsif ((operand1(31) = '0') and (operand2(31) = '0') and (op_result(31) = '1')) then
                              error <= "0001" after prop_delay;
                        elsif ((operand1(31) = '1') and (operand2(31) = '1') and (op_result(31) = '1')) then
                              error <= "0001" after prop_delay;
                        end if;
                  end if;
                  result <= op_result after prop_delay;
            --0101 two's complement divide
            elsif operation = "0101" then
                  bv_div(operand1, operand2, op_result, divide_by_zero, op_flow);
                  --If try to divide by zero:
                  if divide_by_zero then
                        error <= "0011" after prop_delay;
                  end if;
                  
                  if op_flow then
                        error <= "0010" after prop_delay;
                  end if;
                  result <= op_result after prop_delay;
            
            --0111  bitwise AND
            elsif operation = "0111" then
                  for i in 0 to 31 loop
                        op_result(i) := operand1(i) and operand2(i);
                  end loop;
                  result <= op_result after prop_delay;
            --1001  bitwise OR
            elsif operation = "1001" then
                  for i in 0 to 31 loop
                        op_result(i) := operand1(i) or operand2(i);
                  end loop;
                  result <= op_result after prop_delay;
            --1010  logical NOT of operand1 (ignore operand2)
            elsif operation = "1010" then
                  --Check if operand is not azero
                  for i in 0 to 31 loop
                        if (operand1(i) = '1') then
                              op1 := true;
                        end if;
                  end loop;
                  --If operand is 0 give 1, otherwise 0
                  if (not op1) then
                        result <= x"00000001" after prop_delay;
                  else
                        result <= x"00000000" after prop_delay;
                  end if;
            --1011  bitwise NOT of operand1 (ignore operand2)
            elsif operation = "1011" then
                  for i in 0 to 31 loop
                        op_result(i) := not operand1(i);
                  end loop;
                  result <= op_result after prop_delay;
         -- 1100  pass operand1 through to the output
        elsif operation = "1100" then
            result <= operand1 after prop_delay;
        -- 1101  pass operand2 through to the output
        elsif operation = "1101" then
            result <= operand2 after prop_delay;
     
        -- 1111 output all ones without changing
        elsif operation = "1111" then
            result <= x"11111111" after prop_delay;
        -- 1110 output all zeros
        else
            result <= x"00000000" after prop_delay;
       
            end if;
      end process alu_process;
end architecture behavior;
-- alu_operation_code values
-- 0000 unsigned add
-- 0001 unsigned subtract
-- 0010 2's compl add
-- 0011 2's compl sub
-- 0100 2's compl mul
-- 0101 2's compl divide
-- 0110 logical and
-- 0111 bitwise and
-- 1000 logical or
-- 1001 bitwise or
-- 1010 logical not (op1)
-- 1011 bitwise not (op1)
-- 1100-1111 output all zeros
-- error code values
-- 0000 = no error
-- 0001 = overflow/underflow
-- 0010 = divide by zero
-- entity dlx_register (lab 3)
use work.dlx_types.all;
use work.bv_arithmetic.all;

entity dlx_register is
    generic(prop_delay: Time := 10 ns);
    port (
        in_val: in dlx_word;
        clock: in bit;
        out_val: out dlx_word
    );
end entity dlx_register;

architecture behavior of dlx_register is
begin
   dlx_register: process(in_val, clock) is
    begin
   
         if clock = '1' then
            out_val <= in_val after prop_delay;
      end if;
   end process dlx_register;
end architecture behavior;

-- entity pcplusone
use work.dlx_types.all;
use work.bv_arithmetic.all;
entity pcplusone is
generic(prop_delay: Time := 5 ns);
port (input: in dlx_word; clock: in bit; output: out dlx_word);
end entity pcplusone;
architecture behavior of pcplusone is
begin
plusone: process(input,clock) is -- add clock input to make it execute
variable newpc: dlx_word;
variable error: boolean;
begin
if clock'event and clock = '1' then
bv_addu(input,"00000000000000000000000000000001",newpc,error);
output <= newpc after prop_delay;
end if;
end process plusone;
end architecture behavior;

-- entity mux
use work.dlx_types.all;
entity mux is
generic(prop_delay : Time := 5 ns);
port (input_1,input_0 : in dlx_word; which: in bit; output: out dlx_word);
end entity mux;

architecture behavior of mux is
begin
muxProcess : process(input_1, input_0, which) is
begin
if (which = '1') then
output <= input_1 after prop_delay;
else
output <= input_0 after prop_delay;
end if;
end process muxProcess;
end architecture behavior;
-- end entity mux
-- entity threeway_mux
use work.dlx_types.all;
entity threeway_mux is
generic(prop_delay : Time := 5 ns);
port (input_2,input_1,input_0 : in dlx_word; which: in threeway_muxcode;
output: out dlx_word);
end entity threeway_mux;
architecture behavior of threeway_mux is
begin
muxProcess : process(input_1, input_0, which) is
begin
if (which = "10" or which = "11" ) then
output <= input_2 after prop_delay;
elsif (which = "01") then
output <= input_1 after prop_delay;
else
output <= input_0 after prop_delay;
end if;
end process muxProcess;
end architecture behavior;
-- end entity mux
-- entity memory
use work.dlx_types.all;
use work.bv_arithmetic.all;
entity memory is
port (
address : in dlx_word;
readnotwrite: in bit;
data_out : out dlx_word;
data_in: in dlx_word;
clock: in bit);
end memory;
architecture behavior of memory is
begin -- behavior

mem_behav: process(address,clock) is
-- note that there is storage only for the first 1k of the memory, to speed
-- up the simulation
type memtype is array (0 to 1024) of dlx_word;
variable data_memory : memtype;
begin
-- fill this in by hand to put some values in there
-- some instructions
data_memory(0) := X"30200000"; --LD R4, 0x100
data_memory(1) := X"00000100"; -- address 0x100 for previous instruction
data_memory(2) := "00000000000110000100010000000000"; -- ADDU R3,R1,R2
data_memory(4) :=  X"30100000"; -- LD R2, 258
data_memory(5) :=  X"00000102"; -- address 0x102
data_memory(6) :=  X"30080000"; --Ld R1, 257
data_memory(7) :=  "00100000000000001100000000000000"; -- STO R3, 0x103
data_memory(8) :=  x"00000103"; -- address 0x103
data_memory(9) :=  "00110001000000000000000000000000"; -- LDI R0, 0x104
data_memory(10) := x"00000104"; -- 0x104
data_memory(11) := "00100010000000001100000000000000"; -- STOR (R0), R3
data_memory(12) := "00110010001010000000000000000000"; -- LDR R5, (R0)
data_memory(13) := x"40000000"; -- JMP to 261
data_memory(14) := x"00000105";
-- some data
-- note that this code runs every time an input signal to memory changes,
-- so for testing, write to some other locations besides these
data_memory(256) := "01010101000000001111111100000000";
data_memory(257) := "10101010000000001111111100000000";
data_memory(258) := "00000000000000000000000000000001";
data_memory(261) :=  x"00584400"; -- ADDU R11, R1, R2
data_memory(262) := x"4101C000"; -- JZ R7, 267 If R7 == 0, GOTO Addr 267
data_memory(263) := x"0000010B";
data_memory(267) := x"00604400"; -- ADDU R12, R1, R2
data_memory(268) := x"10000000"; -- NOOP
if clock = '1' then
if readnotwrite = '1' then
-- do a read
data_out <= data_memory(bv_to_natural(address)) after 5 ns;
else
-- do a write
data_memory(bv_to_natural(address)) := data_in;
end if;
end if;
end process mem_behav;
end behavior;
-- end entity memory