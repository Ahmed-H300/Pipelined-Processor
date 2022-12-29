vlog ../verilog\ files/processor.v

vsim -t 100ps processor

mem load -filltype value -filldata 0 -fillradix symbolic -skip 0 /processor/instr_fetch/instr_mem/memory
mem load -i ../verilog\ files/simulation\ files/instructionMemory.mem /processor/instr_fetch/instr_mem/memory


#Signals
add wave -divider signals
add wave -color #00FF3A -label INT interrupt -label rst reset -label clk clk -label EPC EPC -label CAUSE CAUSE

#register file
add wave -divider reg_file
for { set a 0}  {$a < 8} {incr a} {
   add wave -color yellow -radix dec -label reg[$a] instr_decode/registerFile/genblk2[$a]/registerModule/register
}

#Program counter
add wave -divider PC					     
add wave -color #007EFF -radix dec -label pc_IF PC_IF -label pc_ID PC_ID -label pc_EX PC_EX

#Stack pointer
add wave -divider SP
add wave -color #4A00FF -radix dec -label SP instr_memory/SP

#CCR register
add wave -divider CCR
add wave -color #00FFFB -label Z_flag instr_execute/Z_flag/register 
add wave -color #00FFFB -label C_flag instr_execute/C_flag/register 
add wave -color #00FFFB -label N_flag instr_execute/N_flag/register 
add wave -color #00FFFB -label OV_flag instr_execute/OVF_flag/register 


# for testing
add wave -divider IF
add wave -color #B27600 instr_fetch/*

add wave -divider IF_ID
add wave -color #B27600 fetch_decode_buff/*

add wave -divider ID
add wave -color #B27600 instr_decode/*

add wave -divider EX
add wave -color #B27600 instr_execute/*

add wave -divider EX_MEM
add wave -color #B27600 execute_memory_buff/*

add wave -divider MEM
add wave -color #B27600 instr_memory/*

add wave -divider WB
add wave -color #B27600 instr_WB/*

add wave -divider HDU
add wave -color #B27600 hazard_unit/*

add wave -divider EDU
add wave -color #B27600 exception_unit/*

add wave -divider another_tests
add wave -color #B27600 stall_HDU stall_MEM set_INT_ID exception_EDU set_INT_ID


force interrupt 1'b0
force reset 1'b1
force clk 1 0, 0 {100 ps} -r 200
run

force reset 1'b0
run

# loading the data memory after reset signal
mem load -i ../verilog\ files/simulation\ files/portInMemory.mem /processor/instr_memory/port_in_memory/memory
mem load -i ../verilog\ files/simulation\ files/dataMemory.mem /processor/instr_memory/data_memory/memory

run