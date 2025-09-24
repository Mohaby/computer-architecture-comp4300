-- Mohab Yousef
--Comp4300
--Lab 2
--10/03/2023



use work.dlx_types.all;
use work.bv_arithmetic.all;

entity alu is
	generic(prop_delay: time := 15 ns);
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