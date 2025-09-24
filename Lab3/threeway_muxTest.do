add wave -position insertpoint \
sim:/threeway_mux/which \
sim:/threeway_mux/input_0 \
sim:/threeway_mux/input_1 \
sim:/threeway_mux/input_2 \
sim:/threeway_mux/output \
force -freeze sim:/threeway_mux/input_0 32'h00000000 0
force -freeze sim:/threeway_mux/input_1 32'hFFFFFFFF 0
force -freeze sim:/threeway_mux/input_2 32'hFFFF0000 0
force -freeze sim:/threeway_mux/which 2'h0 0
run 200 ns
force -freeze sim:/threeway_mux/which 2'h1 0
run 200 ns
force -freeze sim:/threeway_mux/which 2'h2 0
run 200 ns
