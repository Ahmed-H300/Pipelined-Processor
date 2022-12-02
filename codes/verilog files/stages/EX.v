`include "../units/ALU.v"
`include "../utils/reg.v"

/*this is the execute imstruction stage*/
module EX(PC_out, SP_src_out, port_write_out, port_read_out, Rdst1_val_out, Rdst1_out, mem_write_out, mem_read_out, reglow_write_out, reghigh_write_out, Rdst2_out, 
			mem_type_out, memToReg_out, Rdst2_val_out, PORT_out, Rsrc_out, Rsrc_val_out, mem_data_src_out, mem_addr_src_out, Rdst_val_out, INT_out, PC_push_pop_out,
			flags_push_pop_out, jmp_addr_out, do_jmp_out, PC_in, Shmt_in, hash_imm_in, Data_in, Rdst1_in, Rdst_val_in, Rsrc_val_in, ALU_src1_in, mem_write_in, mem_read_in,
			reglow_write_in, reghigh_write_in, ALU_OP_in, port_write_in, port_read_in, Rdst2_in, mem_type_in, memToReg_in, set_Z_in, set_N_in, set_C_in, set_INT_in,
			clr_Z_in, clr_N_in, clr_C_in, clr_INT_in, jmp_sel_in, SP_src_in, PORT_in, Rsrc_in, is_jmp_in, jmp_src_in, mem_data_src_in, mem_addr_src_in, INT_in,
			PC_push_pop_in, flags_push_pop_in, POP_flags_val_in, is_POP_flags_in, clk, reset);

/*it's the jmp address incase we did want to do jmp instruction*/
output wire [31:0] jmp_addr_out;

/*it's a signal to indicated that we will do jmp so change the value of PC*/
output wire do_jmp_out;

/*this is the result of ALU (Rdst1 val) which is the lower 16 bits in case of multiplication*/
output wire [15:0] Rdst1_val_out;

/*this is the result of ALU (Rdst2 val) which is the upper 16 bits in case of multiplication*/
output wire [15:0] Rdst2_val_out;


/*this is the reset signal that will zero out the CCR register*/
input wire reset;

/*this is the clock signal that derives the CCR register*/
input wire clk;

/*this value comes from the MEM stage when poping the flags*/
input wire [2:0] POP_flags_val_in;

/*the signal coming from the MEM stage indicating we want to POP the flags value*/
input wire is_POP_flags_in;

/**************************************************************
	value read from the ID_EX buffer
	(refer to ID.v to know what each symbol means) 
	(don't forget to have a look at the design files)
**************************************************************/
input wire [31:0] PC_in;
input wire [3:0] Shmt_in;
input wire [3:0] hash_imm_in;
input wire [15:0] Data_in;
input wire [2:0] Rdst1_in;
input wire [2:0] Rdst2_in;
input wire [3:0] PORT_in;
input wire [2:0] Rsrc_in;
input wire INT_in;

input wire [15:0] Rdst_val_in;
input wire [15:0] Rsrc_val_in;

input wire [1:0] ALU_src1_in;
input wire mem_write_in;
input wire mem_read_in;
input wire reglow_write_in;
input wire reghigh_write_in;
input wire [3:0] ALU_OP_in;
input wire port_write_in;
input wire port_read_in;
input wire mem_type_in;
input wire memToReg_in;
input wire set_Z_in;
input wire set_N_in;
input wire set_C_in;
input wire set_INT_in;
input wire clr_Z_in;
input wire clr_N_in;
input wire clr_C_in;
input wire clr_INT_in;
input wire [1:0] jmp_sel_in;
input wire [1:0] SP_src_in;
input wire is_jmp_in;
input wire jmp_src_in;
input wire mem_data_src_in;
input wire mem_addr_src_in;
input wire PC_push_pop_in;
input wire flags_push_pop_in;


/**************************************************************
	value bypassed from the ID_EX buffer to the output
	(some of them are used internally)
	(refer to ID.v to know what each symbol means) 
	(don't forget to have a look at the design files)
**************************************************************/
output wire [31:0] PC_out;
output wire [1:0] SP_src_out;
output wire port_write_out;
output wire port_read_out;
output wire [2:0] Rdst1_out;
output wire mem_write_out; 
output wire mem_read_out;
output wire reglow_write_out;
output wire reghigh_write_out;
output wire [2:0] Rdst2_out;
output wire mem_type_out;
output wire memToReg_out;
output wire [3:0] PORT_out;
output wire [2:0] Rsrc_out;
output wire [15:0] Rsrc_val_out;
output wire mem_data_src_out;
output wire mem_addr_src_out;
output wire [15:0] Rdst_val_out;
output wire INT_out;
output wire PC_push_pop_out;
output wire flags_push_pop_out;

/**************************************************************
	immediate wires for clean code
**************************************************************/

/*output wires from the CCR register*/
wire CFlag_out;
wire NFlag_out;
wire ZFlag_out;
wire INTFlag_out;

/*input wires to the CCR register*/
wire CFlag_in;
wire NFlag_in;
wire ZFlag_in;
wire INTFlag_in;

/*set signal to the CCR register*/
wire CFlag_set;
wire NFlag_set;
wire ZFlag_set;
wire INTFlag_set;

/*reset signal to the CCR register*/
wire CFlag_reset;
wire NFlag_reset;
wire ZFlag_reset;
wire INTFlag_reset;

/*these are the results coming from the ALU*/
wire [15:0] ALU_resultLowerWord;
wire [15:0] ALU_resultUpperWord;
wire ALU_CF_out;
wire ALU_NF_out;
wire ALU_ZF_out;
wire [15:0] ALU_Rdst;
wire [15:0] ALU_Rsrc;
wire [3:0] ALU_OP;
wire ALU_ZF_in;
wire ALU_NF_in;
wire ALU_CF_in;

/*just a wire to whether choose between the result flags of the current instruction in the execution or the flags coming from POP in MEM stage*/
wire choose_POP_flags;

/*wires needed in case of jmp instructions with all of its types, refer to the schematic for more understanding*/
wire [31:0] jmp_addr_pc_offset;
wire [31:0]	jmp_actual_addr;
wire jmp_flag_select;
wire is_jmp_instr;
wire clr_CF_JC;		// clearing the C flag after JC
wire clr_NF_JN;		// clearing the N flag after JN
wire clr_ZF_JZ;		// clearing the Z flag after JZ


/**************************************************************
	creating needed modules
**************************************************************/
Reg #(1) Z_flag(.out_data(ZFlag_out), .reset(ZFlag_reset), .set(ZFlag_set), .clk(clk), .in_data(ZFlag_in));
Reg #(1) C_flag(.out_data(CFlag_out), .reset(CFlag_reset), .set(CFlag_set), .clk(clk), .in_data(CFlag_in));
Reg #(1) N_flag(.out_data(NFlag_out), .reset(NFlag_reset), .set(NFlag_set), .clk(clk), .in_data(NFlag_in));
Reg #(1) INT_flag(.out_data(INTFlag_out), .reset(INTFlag_reset), .set(INTFlag_set), .clk(clk), .in_data(INTFlag_out));

ALU arithmetic_unit(.resultLowerWord(ALU_resultLowerWord), .resultUpperWord(ALU_resultUpperWord), .CF_out(ALU_CF_out), .NF_out(ALU_NF_out), .ZF_out(ALU_ZF_out), 
					.Rdst(ALU_Rdst), .Rsrc(ALU_Rsrc), .ALU_OP(ALU_OP), .ZF_in(ALU_ZF_in), .NF_in(ALU_NF_in), .CF_in(ALU_CF_in));

/**************************************************************
	important assigns
**************************************************************/

/*to check which flags to insert as input to the CCR*/
assign choose_POP_flags = (ALU_CF_in == ALU_CF_out) & (ALU_NF_in == ALU_NF_out) & (ALU_ZF_in == ALU_ZF_out) & is_POP_flags_in;

/*chosing the inputs to the CCR based on whether prioirty to POP instr or the current instruction in the exection*/
assign ZFlag_in = (choose_POP_flags) ? POP_flags_val_in[2] : ALU_ZF_out;
assign NFlag_in = (choose_POP_flags) ? POP_flags_val_in[1] : ALU_NF_out;
assign CFlag_in = (choose_POP_flags) ? POP_flags_val_in[0] : ALU_CF_out;

/*assigning the set signal for the CCR*/
assign ZFlag_set = set_Z_in;
assign NFlag_set = set_N_in;
assign CFlag_set = set_C_in;

/*assigning the reset signal for the CCR*/
assign CFlag_reset = reset | clr_CF_JC | clr_C_in;
assign NFlag_reset = reset | clr_NF_JN | clr_N_in;
assign ZFlag_reset = reset | clr_ZF_JZ | clr_Z_in;
assign INTFlag_reset = reset | clr_INT_in;

/*for the inputs/outputs to the ALU*/
assign ALU_Rdst = Rdst_val_in;  //TO BE EDITED

assign ALU_Rsrc = 	(ALU_src1_in == 2'd0)	?	Rsrc_val_in				:		// TO BE EDITED
					(ALU_src1_in == 2'd1)	?	Data_in					:
												{{12{1'b0}}, Shmt_in}	;		
assign ALU_OP = ALU_OP_in;
assign ALU_ZF_in = ZFlag_out;
assign ALU_CF_in = CFlag_out;
assign ALU_NF_in = NFlag_out;

/*calculation of the jmp addresses in case of jmp address*/
assign jmp_addr_pc_offset = PC_in + {{16{Rdst_val_out[15]}}, Rdst_val_out};

assign jmp_flag_select = 	(jmp_sel_in == 2'd0)	?	1'd1		:
							(jmp_sel_in == 2'd1)	?	CFlag_out	:
							(jmp_sel_in == 2'd2)	?	NFlag_out	:
														ZFlag_out	;

assign is_jmp_instr		= 	(is_jmp_in)		?	jmp_flag_select		:
												1'd0				;
												
assign {clr_CF_JC, clr_NF_JN, clr_ZF_JZ}	=	(jmp_sel_in == 2'd0)	?	{1'd0,					1'd0,			1'd0}	:
												(jmp_sel_in == 2'd1)	?	{is_jmp_instr,			1'd0,			1'd0}	:
												(jmp_sel_in == 2'd2)	?	{1'd0,			is_jmp_instr,			1'd0}	:
																			{1'd0,					1'd0,	is_jmp_instr}	;

assign jmp_actual_addr	= (jmp_src_in)	?	{{12{1'b0}}, hash_imm_in, Data_in}	:
											jmp_addr_pc_offset					;
											

											
/**************************************************************
	bypassing some outputs and assigning the others
**************************************************************/
assign PC_out = {ZFlag_out, NFlag_out, CFlag_out, PC_in[28:0]};
assign SP_src_out = SP_src_in;
assign port_write_out = port_write_in;
assign port_read_out = port_read_in;
assign Rdst1_val_out = ALU_resultLowerWord;
assign Rdst1_out = Rdst1_in;
assign mem_write_out = mem_write_in;
assign mem_read_out = mem_read_in;
assign reglow_write_out = reglow_write_in;
assign reghigh_write_out = reghigh_write_in;
assign Rdst2_out = Rdst2_in;
assign mem_type_out = mem_type_in;
assign memToReg_out = memToReg_in;
assign Rdst2_val_out = ALU_resultUpperWord;
assign PORT_out = PORT_in;
assign Rsrc_out = Rsrc_in;
assign Rsrc_val_out = Rsrc_val_in;
assign mem_data_src_out = mem_data_src_in;
assign mem_addr_src_out = mem_addr_src_in;
assign Rdst_val_out = Rdst_val_in;
assign INT_out = INT_in;
assign PC_push_pop_out = PC_push_pop_in;
assign flags_push_pop_out = flags_push_pop_in;
assign jmp_addr_out = jmp_actual_addr;
assign do_jmp_out = is_jmp_instr;
			
endmodule