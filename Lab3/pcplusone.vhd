use work.bv_arithmetic.all;
use work.dlx_types.all;


entity pcplusone is
	generic(prop_delay: Time := 5 ns);
	port (
		input: in dlx_word;
		clock: in bit;
		output: out dlx_word);
end entity pcplusone;

architecture behavior of pcplusone is
begin
 pcplusone: process(input, clock) is
	variable result: dlx_word;
	variable one_bit: dlx_word := "00000000000000000000000000000001";
	variable overflow: boolean;

	begin		
		if clock = '1' then
			bv_addu(input, one_bit, result, overflow);
			output <=  result after prop_delay;
		end if;
	end process pcplusone;  
end architecture behavior;