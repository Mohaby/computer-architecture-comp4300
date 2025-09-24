add wave -position insertpoint  \
sim:/pcplusone/input \
sim:/pcplusone/clock \
sim:/pcplusone/output
 
 
force -freeze sim:/pcplusone/input 32'hFFFFFFF8 0
force -freeze sim:/pcplusone/clock '0' 0
run 50 ns
force -freeze sim:/pcplusone/clock '1' 0
run 50 ns
force -freeze sim:/pcplusone/clock '0' 0
run 50 ns
force -freeze sim:/pcplusone/clock '1' 0
run 50 ns
force -freeze sim:/pcplusone/input 32'hFFFFFFFF 0
force -freeze sim:/pcplusone/clock '0' 0
run 50 ns
force -freeze sim:/pcplusone/clock '1' 0
run 50 ns
force -freeze sim:/pcplusone/clock '0' 0
run 50 ns
force -freeze sim:/pcplusone/clock '1' 0
run 50