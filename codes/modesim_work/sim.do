vlog ../verilog\ files/processor.v

vsim -t 100ps processor

mem load -filltype value -filldata 0 -fillradix symbolic -skip 0 /processor/instr_fetch/instr_mem/memory
mem load -i {instructionMemory.mem} /processor/instr_fetch/instr_mem/memory

#add wave interrupt reset clk PC_IF instruction_IF Data_IF INT_IF instr_fetch/PC_in instr_fetch/masterOut instr_fetch/slaveOut instr_fetch/PC_out instr_fetch/is_Itype instr_fetch/inst_opcode  
#add wave interrupt reset clk PC_dummy instr_dummy data_dummy INT_dummy PC_IF instruction_IF Data_IF

if 0 {
add wave interrupt reset clk PC_ID_EX_buff Shmt_ID_EX_buff hash_imm_ID_EX_buff Data_ID_EX_buff Rdst1_ID_EX_buff Rdst2_ID_EX_buff PORT_ID_EX_buff Rsrc_ID_EX_buff \
			INT_ID_EX_buff Rdst_val_ID_EX_buff Rsrc_val_ID_EX_buff ALU_src1_ID_EX_buff mem_write_ID_EX_buff mem_read_ID_EX_buff reglow_write_ID_EX_buff reghigh_write_ID_EX_buff \
			ALU_OP_ID_EX_buff port_write_ID_EX_buff port_read_ID_EX_buff mem_type_ID_EX_buff memToReg_ID_EX_buff set_Z_ID_EX_buff set_N_ID_EX_buff set_C_ID_EX_buff set_INT_ID_EX_buff \
			clr_Z_ID_EX_buff clr_N_ID_EX_buff clr_C_ID_EX_buff clr_INT_ID_EX_buff jmp_sel_ID_EX_buff SP_src_ID_EX_buff is_jmp_ID_EX_buff jmp_src_ID_EX_buff mem_data_src_ID_EX_buff \
			mem_addr_src_ID_EX_buff PC_push_pop_ID_EX_buff flags_push_pop_ID_EX_buff
}

add wave interrupt reset clk Rdst1_val_EX_MEM_buff Rdst2_val_EX_MEM_buff PC_EX_MEM_buff SP_src_EX_MEM_buff port_write_EX_MEM_buff port_read_EX_MEM_buff Rdst1_EX_MEM_buff \
			mem_write_EX_MEM_buff mem_read_EX_MEM_buff reglow_write_EX_MEM_buff reghigh_write_EX_MEM_buff Rdst2_EX_MEM_buff mem_type_EX_MEM_buff memToReg_EX_MEM_buff \
			PORT_EX_MEM_buff Rsrc_EX_MEM_buff Rsrc_val_EX_MEM_buff mem_data_src_EX_MEM_buff mem_addr_src_EX_MEM_buff Rdst_val_EX_MEM_buff INT_EX_MEM_buff PC_push_pop_EX_MEM_buff \
			flags_push_pop_EX_MEM_buff instr_execute/clr_CF_JC instr_execute/clr_NF_JN instr_execute/clr_ZF_JZ  instr_execute/clr_N_in instr_execute/clr_C_in instr_execute/CFlag_in \
			instr_execute/choose_POP_flags instr_execute/ALU_ZF_out instr_execute/ALU_ZF_in instr_execute/ZFlag_set instr_execute/ALU_OP instr_execute/ALU_ZF_in instr_execute/ALU_ZF_out

force interrupt 1'b0
force reset 1'b0
force clk 1'b0
force SET_INT_IF	1'b0
force pop_pc_IF		1'b0
force exception_IF	1'b0
force PC_popedValue_IF	32'd1
force stall	1'b0
force is_POP_flags_MEM 1'b0
force clk 1'b1
force clk 1 0, 0 {100 ps} -r 200
run

force reset 1'b1
run


run

force reset 1'b0
run


