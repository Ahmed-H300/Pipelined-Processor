vlog ../verilog\ files/processor.v

vsim -t 100ps processor

mem load -filltype value -filldata 0 -fillradix symbolic -skip 0 /processor/instr_fetch/instr_mem/memory
mem load -i ../verilog\ files/simulation\ files/instructionMemory.mem /processor/instr_fetch/instr_mem/memory

#add wave interrupt reset clk PC_IF instruction_IF Data_IF INT_IF instr_fetch/PC_in instr_fetch/masterOut instr_fetch/slaveOut instr_fetch/PC_out instr_fetch/is_Itype instr_fetch/inst_opcode  
#add wave interrupt reset clk PC_dummy instr_dummy data_dummy INT_dummy PC_IF instruction_IF Data_IF

if 0 {
add wave interrupt reset clk PC_ID_EX_buff Shmt_ID_EX_buff hash_imm_ID_EX_buff Data_ID_EX_buff Rdst1_ID_EX_buff Rdst2_ID_EX_buff PORT_ID_EX_buff Rsrc_ID_EX_buff \
			INT_ID_EX_buff Rdst_val_ID_EX_buff Rsrc_val_ID_EX_buff ALU_src1_ID_EX_buff mem_write_ID_EX_buff mem_read_ID_EX_buff reglow_write_ID_EX_buff reghigh_write_ID_EX_buff \
			ALU_OP_ID_EX_buff port_write_ID_EX_buff port_read_ID_EX_buff mem_type_ID_EX_buff memToReg_ID_EX_buff set_Z_ID_EX_buff set_N_ID_EX_buff set_C_ID_EX_buff set_INT_ID_EX_buff \
			clr_Z_ID_EX_buff clr_N_ID_EX_buff clr_C_ID_EX_buff clr_INT_ID_EX_buff jmp_sel_ID_EX_buff SP_src_ID_EX_buff is_jmp_ID_EX_buff jmp_src_ID_EX_buff mem_data_src_ID_EX_buff \
			mem_addr_src_ID_EX_buff PC_push_pop_ID_EX_buff flags_push_pop_ID_EX_buff
}

if 0 {
add wave interrupt reset clk Rdst1_val_EX_MEM_buff Rdst2_val_EX_MEM_buff PC_EX_MEM_buff SP_src_EX_MEM_buff port_write_EX_MEM_buff port_read_EX_MEM_buff Rdst1_EX_MEM_buff \
			mem_write_EX_MEM_buff mem_read_EX_MEM_buff reglow_write_EX_MEM_buff reghigh_write_EX_MEM_buff Rdst2_EX_MEM_buff mem_type_EX_MEM_buff memToReg_EX_MEM_buff \
			PORT_EX_MEM_buff Rsrc_EX_MEM_buff Rsrc_val_EX_MEM_buff mem_data_src_EX_MEM_buff mem_addr_src_EX_MEM_buff Rdst_val_EX_MEM_buff INT_EX_MEM_buff PC_push_pop_EX_MEM_buff \
			flags_push_pop_EX_MEM_buff instr_execute/clr_CF_JC instr_execute/clr_NF_JN instr_execute/clr_ZF_JZ  instr_execute/clr_N_in instr_execute/clr_C_in instr_execute/CFlag_in \
			instr_execute/choose_POP_flags instr_execute/ALU_ZF_out instr_execute/ALU_ZF_in instr_execute/ZFlag_set instr_execute/ALU_OP instr_execute/ALU_ZF_in instr_execute/ALU_ZF_out
}

if 0 {
add wave interrupt reset clk Rdst2_val_MEM Rdst2_MEM reghigh_write_MEM reglow_write_MEM Rdst1_MEM Rdst1_val_MEM Data_MEM memToReg_MEM POP_PC_addr_MEM POP_PC_sgn_MEM \
				POP_flags_val_MEM POP_flags_sgn_MEM
}

#Signals
add wave -divider signals
add wave -color #00FF3A -label INT interrupt -label rst reset -label clk clk 

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
add wave -color #00FFFB -label INT_flag instr_execute/INT_flag/register 


# for testing
add wave -divider IF
add wave -color #B27600 instr_fetch/*

add wave -divider IF_ID
add wave -color #B27600 fetch_decode_buff/*

add wave -divider ID
add wave -color #B27600 instr_decode/*

add wave -divider EX
add wave -color #B27600 instr_execute/*

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

run