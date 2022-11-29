vlog ../verilog\ files/processor.v

vsim -t 100ps processor

mem load -i {instructionMemory.mem} /processor/instr_fetch/instr_mem/memory

add wave interrupt reset clk PC_IF instruction_IF Data_IF INT_IF instr_fetch/PC_in instr_fetch/masterOut instr_fetch/slaveOut instr_fetch/PC_out instr_fetch/is_Itype instr_fetch/inst_opcode  


force interrupt 1'b0
force reset 1'b0
force clk 1'b0
force SET_INT_IF	1'b0
force pop_pc_IF		1'b0
force jmp_sgn_IF	1'b0
force exception_IF	1'b0
force PC_popedValue_IF	32'd1
force PC_jmpValue_IF	32'd2
force stall	1'b0
force clk 1'b1
force clk 1 0, 0 {100 ps} -r 200
run

force reset 1'b1
run


run

force reset 1'b0
run


