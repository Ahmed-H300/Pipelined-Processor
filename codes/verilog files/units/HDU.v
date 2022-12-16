/*this is the hazard detection unit*/
module HDU(HDU_stall_out, Rdst1_EX_in, mem_read_EX_in, Rdst_ID_in, Rsrc_ID_in, inst_opcode_ID_in);

/*this is the stall signal coming out of the hazard detection unit*/
output wire HDU_stall_out;

/*this is the Rdst number in the execute stage*/
input wire [2:0] Rdst1_EX_in;

/*this is the memory read signal coming from the execute stage*/
input wire mem_read_EX_in;

/*this is the Rdst number in the instruction decode stage*/
input wire [2:0] Rdst_ID_in;

/*this is the Rsrc number in the instruction decode stage*/
input wire [2:0] Rsrc_ID_in;

/*this is the opcode of the instruction in the decode stage*/
input wire [3:0] inst_opcode_ID_in;



/**************************************************************
	temp wire to make the code looks clean
**************************************************************/
wire is_instr_match_hazard;		// to detect the instructions that causes hazards after LDD or OUT like (R_type and B_type)
wire is_there_depenedency;		// to detect if there is a dependency between the current stage and the next stage

/**************************************************************
	we will only stall 1 cycle in the following cases:
		case 1:	LDD or OUT
				then
				R_type instrucion
		case 2: LDD or OUT
				then
				B_type instruction
**************************************************************/
assign is_instr_match_hazard = (inst_opcode_ID_in == 4'd1 || inst_opcode_ID_in == 4'd2 || inst_opcode_ID_in == 4'd3 || inst_opcode_ID_in == 4'd4);
assign is_there_depenedency = (Rdst1_EX_in == Rsrc_ID_in || Rdst1_EX_in == Rdst_ID_in);
assign HDU_stall_out = is_instr_match_hazard & is_there_depenedency & mem_read_EX_in;


endmodule