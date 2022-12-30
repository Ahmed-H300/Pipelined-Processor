/*this is the control unit which is responsible for creating most of enable and select signals that will make the processor work correctly*/
module CU(RegLow_write, ALU_OP, RegHigh_write, ALU_src1, MemToReg, memWrite, memRead, portWrite, portRead,
			memType, PC_push_pop, flags_push_pop, JMP_type, is_jmp, JMP_src, SET_Z, SET_N, SET_C, SET_OVF, 
			CLR_Z, CLR_N, CLR_C, CLR_OVF, SP_src, mem_data_src, mem_address_src, SET_INT, instruction);

/*this is the instruction to decode which is 16 bits*/
input wire [15:0] instruction;

/*reg_dst1_write_back , this is the signal that's used to allow writing back to the Rdst1*/
output wire RegLow_write;

/*reg_dst1_write_back , this is the signal that's used to allow writing back to the Rdst2 (used only incase of multiplications)*/
output wire RegHigh_write;

/*used to select which ALU operation to preform*/
output wire [3:0] ALU_OP;

/*to select between shmt, Rsrc or DATA in case of LDM*/
output wire [1:0] ALU_src1;

/*to choose the source of Rdst1 is comming from the memory or result of ALU*/
output wire MemToReg;

/*signal to write to the data memory*/
output wire memWrite;

/*signal to read from the data memory*/
output wire memRead;

/*signal to write to the port memory*/
output wire portWrite;

/*signal to read from the port memory*/
output wire portRead;

/*to select between the port memory and data memory while reading from memory*/
output wire memType;

/*to indication we should pop/push PC*/
output wire PC_push_pop;

/*to indication we should pop/push flags*/
output wire flags_push_pop;

/*to indicate whether jump on: flag(carry, zero, negative) or unconditional*/
output wire [1:0] JMP_type;

/*to indication it's a jump command or not*/
output wire is_jmp;

/*to select whether to jump using immediate value or using value in register*/
output wire JMP_src;

/*sets the zero flag*/
output wire SET_Z;

/*sets the negative flag*/
output wire SET_N;

/*sets the carry flag*/
output wire SET_C;

/*sets the interrupt flag*/
output wire SET_OVF;

/*clears the zero flag*/
output wire CLR_Z;

/*clears the negative flag*/
output wire CLR_N;

/*clears the carry flag*/
output wire CLR_C;

/*clears the interrupt flag*/
output wire CLR_OVF;

/*select whether to keep SP value as it's or decrement it or increment it*/
output wire [1:0] SP_src;

/*select between PUSH PC or Rdst*/
output wire mem_data_src;

/*select between using address using Rdst and SP*/
output wire mem_address_src;

/*this is the software interrupt wire*/
output wire SET_INT;


/**************************************************************
	temp wire to make the code looks clean
**************************************************************/
wire [3:0] opcode;	// this is the opcode of the instruction
wire [2:0] Rdst1;	// this is the first Register destination number 
wire [2:0] Rdst2;	// this is the second Register destination number 
wire [2:0] Rsrc;	// this is the source Register number 
wire [3:0] shmt;	// this is the value that we will shift with in case of shifting
wire [1:0] funct;	// these are functionality bits to determine the functionality of the instruction after determining its type from opcode
wire OP;			// this is just a bit in c_type instructions to determine whether we are setting or clearing a flag
wire PC;			// this is just a bit to determine whether to PUSH/POP PC
wire flags;			// this is just a bit to determine whether to PUSH/POP flags
wire [3:0] port;	// to determine the port number from which we will (read from/ write to) 
wire [3:0] hash_imm;// these are used immediate bit concatenated with the next line in the memeory to preform absolute jumps
wire [2:0] I_funct;	// since I_type had many instruction so we mad funct bits to be 3-bits to be able to hold these instructions

/*assigning each wire to the corresponding bits in the instruction , refer to "ISA design.pdf"*/
assign opcode = instruction[15:12];
assign Rdst1 = instruction[11:9];
assign Rdst2 = instruction[5:3];
assign Rsrc = instruction[8:6];
assign shmt = instruction[5:2];
assign funct = instruction[1:0];
assign OP = instruction[11];
assign PC = instruction[8];
assign flags = instruction[7];
assign port = instruction[5:2];
assign hash_imm = instruction[6:3];
assign I_funct = instruction[2:0];
 
/**************************************************************
	detection of the instruction type
**************************************************************/

/*to detect the R type instruction*/
wire is_R_type;
assign is_R_type = (opcode == 4'd1) | (opcode == 4'd2) | (opcode == 4'd3);

/*to detect the B type instruction*/
wire is_B_type;
assign is_B_type = (opcode == 4'd4);

/*to detect the C type instruction*/
wire is_C_type;
assign is_C_type = (opcode == 4'd5);

/*to detect the S type instruction*/
wire is_S_type;
assign is_S_type = (opcode == 4'd6);

/*to detect the M type instruction*/
wire is_M_type;
assign is_M_type = (opcode == 4'd7);

/*to detect the I type instruction*/
wire is_I_type;
assign is_I_type = (opcode == 4'd8);

/*to detect the No operation instruction*/
wire is_NOP;
assign is_NOP = (opcode == 4'd0);

/*to detect the clear all flags instruction*/
wire is_CLR_FLAGS;
assign is_CLR_FLAGS = (opcode == 4'd9);

/*to detect the "call Rdst" instruction*/
wire is_CALL;
assign is_CALL = (opcode == 4'd10);

/*to detect if the instruction is software interrupt*/
wire is_SET_INT_inst;
assign is_SET_INT_inst = (opcode == 4'd11);


/**************************************************************
	detection of the instruction itself
**************************************************************/

/*to detect if the instruction is multiplication*/
wire is_MUL_inst;
assign is_MUL_inst = ((opcode == 4'd1) & (funct == 2'd1));

/*to detect if the instruction is shifting instruction, whether right or left*/
wire is_SHIFT_inst;
assign is_SHIFT_inst = ((opcode == 4'd2) & ((funct == 2'd1) | (funct == 2'd0))); 

/*to detect if the instruction is jump if zero*/
wire is_JZ_Rdst_inst;
assign is_JZ_Rdst_inst = (is_B_type & (funct == 2'd0));

/*to detect if the instruction is jump if negative*/
wire is_JN_Rdst_inst;
assign is_JN_Rdst_inst = (is_B_type & (funct == 2'd1));

/*to detect if the instruction is jump if carry*/
wire is_JC_Rdst_inst;
assign is_JC_Rdst_inst = (is_B_type & (funct == 2'd2));

/*to detect if the instruction is jump unconditionally */
wire is_JMP_Rdst_inst;
assign is_JMP_Rdst_inst = (is_B_type & (funct == 2'd3));

/*to detect if the instruction is clear zero flag*/
wire is_CLRZ_inst;
assign is_CLRZ_inst = (is_C_type & (funct == 2'd0) & (OP == 0));

/*to detect if the instruction is clear negative flag*/
wire is_CLRN_inst;
assign is_CLRN_inst = (is_C_type & (funct == 2'd1) & (OP == 0));

/*to detect if the instruction is clear carry flag*/
wire is_CLRC_inst;
assign is_CLRC_inst = (is_C_type & (funct == 2'd2) & (OP == 0));

/*to detect if the instruction is clear interrupt flag*/
wire is_CLR_OVF_inst;
assign is_CLR_OVF_inst = (is_C_type & (funct == 2'd3) & (OP == 0));

/*to detect if the instruction is set zero flag*/
wire is_SETZ_inst;
assign is_SETZ_inst = (is_C_type & (funct == 2'd0) & (OP == 1));

/*to detect if the instruction is set negative flag*/
wire is_SETN_inst;
assign is_SETN_inst = (is_C_type & (funct == 2'd1) & (OP == 1));

/*to detect if the instruction is set carry flag*/
wire is_SETC_inst;
assign is_SETC_inst = (is_C_type & (funct == 2'd2) & (OP == 1));

/*to detect if the instruction is set interrupt flag*/
wire is_SET_OVF_inst;
assign is_SET_OVF_inst = (is_C_type & (funct == 2'd3) & (OP == 1));

/*to detect if the instruction is PUSH*/
wire is_PUSH_inst;
assign is_PUSH_inst = (is_S_type & (funct == 2'd0));

/*to detect if the instruction is POP*/
wire is_POP_inst;
assign is_POP_inst = (is_S_type & (funct == 2'd1));

/*to detect if the instruction is OUT*/
wire is_OUT_inst;
assign is_OUT_inst = (is_M_type & (funct == 2'd0));

/*to detect if the instruction is IN*/
wire is_IN_inst;
assign is_IN_inst = (is_M_type & (funct == 2'd1));

/*to detect if the instruction is LDD*/
wire is_LDD_inst;
assign is_LDD_inst = (is_M_type & (funct == 2'd2));

/*to detect if the instruction is STD*/
wire is_STD_inst;
assign is_STD_inst = (is_M_type & (funct == 2'd3));

/*to detect if the instruction is LDM*/
wire is_LDM_inst;
assign is_LDM_inst = (is_I_type & (funct == 2'd0));

/*to detect if the instruction is CALL using immediate value*/
wire is_CALL_hashImm_inst;
assign is_CALL_hashImm_inst = (is_I_type & (funct == 2'd1));

/*to detect if the instruction is JMP unconditionally using immediate value*/
wire is_JMP_hashImm_inst;
assign is_JMP_hashImm_inst = (is_I_type & (funct == 2'd2));

/*to detect if the instruction is jump if carry flag using immediate value*/
wire is_JC_hashImm_inst;
assign is_JC_hashImm_inst = (is_I_type & (funct == 2'd3));

/*to detect if the instruction is jump if negative flag using immediate value*/
wire is_JN_hashImm_inst;
assign is_JN_hashImm_inst = (is_I_type & (funct == 2'd4));

/*to detect if the instruction is jump if zero flag using immediate value*/
wire is_JZ_hashImm_inst;
assign is_JZ_hashImm_inst = (is_I_type & (funct == 2'd5));


/**************************************************************
	dummy wires used as immediate between gates
**************************************************************/
wire [3:0] selected_ALU_OP_from_group0; 	// used to detected the needed ALU operation from group0 based on funct
wire [3:0] selected_ALU_OP_from_group1;		// used to detected the needed ALU operation from group1 based on funct
wire [3:0] selected_ALU_OP_from_group2;		// used to detected the needed ALU operation from group2 based on funct


assign selected_ALU_OP_from_group0 = 	(funct == 4'd0) ? 4'd10 :		// Division (DIV)
										(funct == 4'd1) ? 4'd9 :		// multiplication (MUL)
										(funct == 4'd2) ? 4'd0 :		// addition (ADD)
										4'd1;							// subtraction (SUB)									

assign selected_ALU_OP_from_group1 = 	(funct == 4'd0) ? 4'd7 :		// shift left (SHL)
										(funct == 4'd1) ? 4'd8 :		// shift right (SHR)
										(funct == 4'd2) ? 4'd2 :		// increment bt 1 (INC)
										4'd3;							// decrement by one (DEC)
										
assign selected_ALU_OP_from_group2 = 	(funct == 4'd0) ? 4'd5 :		// bitwise OR (OR)
										(funct == 4'd1) ? 4'd4 :		// bitwise AND (AND)
										(funct == 4'd2) ? 4'd6 :		// bitwise NOT (NOT)
										4'd11;							// move instruction (MOV)
											 

/*
	calculating the value of RegLow_write :
	---------------------------------------
		active in :
		- all of R_type instructions
		- m_type in case of IN or LDD
		- s_type in case of POP and PC != 1
		- I type in case of LDM
*/
assign RegLow_write = is_R_type | is_IN_inst | is_LDD_inst | (is_POP_inst & (!PC)) | is_LDM_inst;

/*
	calculating the value of RegHigh_write :
	---------------------------------------
	active in :
		- multiplication command only
*/
assign RegHigh_write = is_MUL_inst;

/*
	calculating the value of ALU_OP :
	---------------------------------------
	values:
		- 0 (ADD) when opcode is 1 and funct is 2
		- 1 (SUB) when opcode is 1 and funct is 3
		- 2 (INC) when opcode is 2 and funct is 2
		- 3 (DEC) when opcode is 2 and funct is 3
		- 4 (AND) when opcode is 3 and funct is 1
		- 5 (OR) when opcode is 3 and funct is 0
		- 6 (NOT) when opcode is 3 and funct is 2
		- 7 (SHL) when opcode is 2 and funct is 0
		- 8 (SHR) when opcode is 2 and funct is 1
		- 9 (MUL) when opcode is 1 and funct is 1
		- 10 (DIV) when opcode is 1 and funct is 0
		- 11 (MOV) when opcode is 3 and funct is 3
	otherwise:
		- we use the command MOV for any other operation
*/
assign ALU_OP = (opcode == 4'd1) ? selected_ALU_OP_from_group0 :	// select the operation from the group0
				(opcode == 4'd2) ? selected_ALU_OP_from_group1 :	// select the operation from the group1
				(opcode == 4'd3) ? selected_ALU_OP_from_group2 :	// select the operation from the group2
				4'd11;												// make MOV command is the default command
				
/*
	calculating the value of ALU_src1 :
	---------------------------------------
	values: 
		- 0 : when input to Rsrc in ALU comes from register file (anyother case)
		- 1 : when input to Rsrc in ALU comes from DATA which is 16 input used mostly with LDM command
		- 2 : when input to Rsrc in ALU comes from shmt to do shifting (ALUOP = SHF | SHR)
*/
assign ALU_src1 = 	(is_LDM_inst) ? 2'd1 :
					(is_SHIFT_inst) ? 2'd2 :
					2'd0;
					
/*
	calculating the value of MemToReg :
	---------------------------------------
	active in :
		- LDD, POP (where PC != 0) , IN
*/					
assign MemToReg = is_LDD_inst | is_IN_inst | (is_POP_inst & (!(PC | flags)));


/*
	calculating the value of memWrite :
	---------------------------------------
	active in :
		- PUSH, STD, CALL #imm , CALL Rdst
*/					
assign memWrite = is_PUSH_inst | is_STD_inst | is_CALL_hashImm_inst | is_CALL;


/*
	calculating the value of memRead :
	---------------------------------------
	active in :
		- POP, LDD
*/					
assign memRead = is_POP_inst | is_LDD_inst;


/*
	calculating the value of portWrite :
	---------------------------------------
	active in : 
		-  OUT
*/					
assign portWrite = is_OUT_inst;


/*
	calculating the value of portRead :
	---------------------------------------
	active in :
		- IN
*/					
assign portRead = is_IN_inst;


/*
	calculating the value of memType :
	---------------------------------------
	active in :
		- when memRead or memWrite is high 
*/					
assign memType = memRead | memWrite;				
				
				
/*
	calculating the value of PC_push_pop :
	---------------------------------------
	active in:
		- using PUSH/POP and PC = 1
		- CALL
*/					
assign PC_push_pop = ((is_PUSH_inst | is_POP_inst) & PC) | is_CALL | is_CALL_hashImm_inst;				


/*
	calculating the value of flags_push_pop :
	---------------------------------------
	active in:
		- using PUSH/POP and flags = 1
*/					
assign flags_push_pop = (is_PUSH_inst | is_POP_inst) & flags;				
	
/*
	calculating the value of JMP_type :
	---------------------------------------
	values:
		- 0 when performing unconditional jump
		- 1 when jumping on carry flag
		- 2 when jumping on negative flag
		- 3 when jumping on zero flag
*/					
assign JMP_type = 	(is_JC_Rdst_inst | is_JC_hashImm_inst)? 2'd1 :
					(is_JN_Rdst_inst | is_JN_hashImm_inst)? 2'd2 :
					(is_JZ_Rdst_inst | is_JZ_hashImm_inst)? 2'd3 :
					2'd0;
	
	
/*
	calculating the value of is_jmp :
	---------------------------------------
	active in:
		- b_type instructions, CALL, I_type except for LDM
*/					
assign is_jmp = is_B_type | is_CALL | (is_I_type & (!is_LDM_inst));	
	
	
/*
	calculating the value of JMP_src :
	---------------------------------------
	active in:
		- I_type
*/	
assign JMP_src = is_I_type;			


/*
	calculating the value of SET_Z :
	---------------------------------------
	active in:
		- c_type instructions group 1 (SET_Z)
*/	
assign SET_Z = is_SETZ_inst;	

/*
	calculating the value of SET_N :
	---------------------------------------
	active in:
		- c_type instructions group 1 (SET_N)
*/	
assign SET_N = is_SETN_inst;	

/*
	calculating the value of SET_N :
	---------------------------------------
	active in:
		- c_type instructions group 1 (SET_C)
*/	
assign SET_C = is_SETC_inst;	

/*
	calculating the value of SET_OVF :
	---------------------------------------
	active in:
		- c_type instructions group 1 (SET_OVF)
*/	
assign SET_OVF = is_SET_OVF_inst;	
	
	
/*
	calculating the value of CLR_Z :
	---------------------------------------
	active in:
		- c_type instructions group 0 (CLR_Z) and CLR_FLAGS instruction
*/	
assign CLR_Z = is_CLRZ_inst | is_CLR_FLAGS;		
	
/*
	calculating the value of CLR_N :
	---------------------------------------
	active in:
		- c_type instructions group 0 (CLR_N) and CLR_FLAGS instruction
*/	
assign CLR_N = is_CLRN_inst | is_CLR_FLAGS;	

/*
	calculating the value of CLR_C :
	---------------------------------------
	active in:
		- c_type instructions group 0 (CLR_C) and CLR_FLAGS instruction
*/	
assign CLR_C = is_CLRC_inst | is_CLR_FLAGS;	

/*
	calculating the value of CLR_OVF :
	---------------------------------------
	active in:
		- c_type instructions group 0 (CLR_OVF) and CLR_FLAGS instruction
		- RTI instruction (POP PC, flags)		
*/	
assign CLR_OVF = is_CLR_OVF_inst | is_CLR_FLAGS | (is_POP_inst & PC & flags);	


/*
	calculating the value of SP_src :
	---------------------------------------
	values :
		- 0		keep the value of SP as it's in case of NO (PUSH/POP, CALL)
		- 1		decrement the value of SP by 1 incase of POP
		- 2 	increment the value of SP by 1 incase of PUSH, CALL
*/	
assign SP_src = (is_POP_inst) ? 2'd1 :
				(is_PUSH_inst | is_CALL | is_CALL_hashImm_inst) ? 2'd2 :
				2'd0;

/*
	calculating the value of mem_data_src :
	---------------------------------------
	active in:
		- PUSH command, PC | flags = 1
		- CALL
*/	
assign mem_data_src = (is_PUSH_inst & (PC | flags)) | is_CALL | is_CALL_hashImm_inst;	


/*
	calculating the value of mem_address_src :
	---------------------------------------
	acive in :
		- POP/PUSH instructions (s_type)
		- CALL
*/	
assign mem_address_src = is_S_type | is_CALL | is_CALL_hashImm_inst;


/*
	calculating the value of mem_address_src :
	---------------------------------------
	acive in :
		- SET_INT instruction
*/
assign SET_INT = is_SET_INT_inst;
	
				
endmodule