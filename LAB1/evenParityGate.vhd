entity evenParityGate is
   port (
       a_in, b_in, c_in: in bit;
       result: out bit
   );
end entity evenParityGate;

architecture behaviour1 of evenParityGate is
begin
   process (a_in, b_in, c_in)
   begin
       if (a_in = '0' and b_in = '0' and c_in = '0') or
          (a_in = '0' and b_in = '1' and c_in = '1') or
          (a_in = '1' and b_in = '0' and c_in = '1') or
          (a_in = '1' and b_in = '1' and c_in = '0') then
           result <= '1';
       else
           result <= '0';
       end if;
   end process;
end architecture behaviour1;