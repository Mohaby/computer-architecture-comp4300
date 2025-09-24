add wave -position insertpoint  \
sim:/mux/input_0 \
sim:/mux/input_1 \
sim:/mux/which \
sim:/mux/output
 
 
force -freeze sim:/mux/input_0 32'hA1A1A1A1 0
force -freeze sim:/mux/input_1 32'hFFFFFFFF 0
force -freeze sim:/mux/which '1' 0
run 50 ns
force -freeze sim:/mux/input_0 32'hA1A1A1A1 0
force -freeze sim:/mux/input_1 32'hFFFFFFFF 0
force -freeze sim:/mux/which '0' 0
run 50 ns
force -freeze sim:/mux/input_0 32'hA1A1A1A1 0
force -freeze sim:/mux/input_1 32'hFFFFFFFF 0
force -freeze sim:/mux/which '1' 0
run 50 ns
force -freeze sim:/mux/input_0 32'hA1A1A1A1 0
force -freeze sim:/mux/input_1 32'hFFFFFFFF 0
force -freeze sim:/mux/which '0' 0
run 50 ns
force -freeze sim:/mux/input_0 32'hA1A1A1A1 0
force -freeze sim:/mux/input_1 32'hFFFFFFFF 0
force -freeze sim:/mux/which '1' 0
run 50 ns
force -freeze sim:/mux/input_0 32'hA1A1A1A1 0
force -freeze sim:/mux/input_1 32'hFFFFFFFF 0
force -freeze sim:/mux/which '0' 0
run 50 ns