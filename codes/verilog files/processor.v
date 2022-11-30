`include "stages/ID.v"
`include "stages/EX.v"	
`include "stages/IF.v"
`include "stages/MEM.v"
`include "stages/WB.v"

`include "intermediate_buffers/EX_MEM.v"
`include "intermediate_buffers/ID_EX.v"
`include "intermediate_buffers/IF_ID.v"
`include "intermediate_buffers/MEM_WB.v"



/*this is our top module which is our processor*/
module processor(EPC, CAUSE, interrupt, reset, clk);

/*this is exception program counter that will hold the address of the malfunction instruction*/
output wire [31:0] EPC;

/*this is the reason of exception register that will give exception number pointing out the reason of exception*/
output wire [3:0] CAUSE;

/*this is the reset singal which zeros all the resets except for PC and SP that will hold special value*/
input wire reset;

/*this is the clk that's taken as input to the processor and that's really what makes the processor run*/
input wire clk;

/*this is the interrupt signal that's taken as input to the processor and it makes the prcoessor goes into interrupt handler routine*/
input wire interrupt;



/**************************************************************
	immediate wires for the IF stage
**************************************************************/

/*inputs*/
wire exception_IF;
wire SET_INT_IF;
wire pop_pc_IF;
wire [31:0] PC_popedValue_IF;
wire jmp_sgn_IF;
wire [31:0] PC_jmpValue_IF;
wire stall;

/*outputs*/
wire [31:0] PC_IF;
wire [15:0] instruction_IF;
wire [15:0] Data_IF;
wire INT_IF;


/**************************************************************
	immediate wires for the IF_ID buffer
	(inputs are the outputs of IF stage)
**************************************************************/

/*outputs*/
wire [31:0] PC_IF_ID_buff;
wire [15:0] instr_IF_ID_buff;
wire [15:0] data_IF_ID_buff;
wire INT_IF_ID_buff;


/**************************************************************
	immediate wires for the ID stage 
	(inputs comes from an (IF and WB) stages)
**************************************************************/

/*outputs*/
wire [31:0] PC_ID;
wire [3:0] Shmt_ID;
wire [3:0] hash_imm_ID;
wire [15:0] Data_ID;
wire [2:0] Rdst1_ID;
wire [2:0] Rdst2_ID;
wire [3:0] PORT_ID;
wire [2:0] Rsrc_ID;
wire INT_ID;

wire [15:0] Rdst_val_ID;
wire [15:0] Rsrc_val_ID;

wire [1:0] ALU_src1_ID;
wire mem_write_ID;
wire mem_read_ID;
wire reglow_write_ID;
wire reghigh_write_ID;
wire [3:0] ALU_OP_ID;
wire port_write_ID;
wire port_read_ID;
wire mem_type_ID;
wire memToReg_ID;
wire set_Z_ID;
wire set_N_ID;
wire set_C_ID;
wire set_INT_ID;
wire clr_Z_ID;
wire clr_N_ID;
wire clr_C_ID;
wire clr_INT_ID;
wire [1:0] jmp_sel_ID;
wire [1:0] SP_src_ID;
wire is_jmp_ID;
wire jmp_src_ID;
wire mem_data_src_ID;
wire mem_addr_src_ID;
wire PC_push_pop_ID;
wire flags_push_pop_ID;

/**************************************************************
	immediate wires for the ID_EX buffer 
	(inputs are ID stage outputs)
**************************************************************/

/*outputs*/
wire [31:0] PC_ID_EX_buff;
wire [3:0] Shmt_ID_EX_buff;
wire [3:0] hash_imm_ID_EX_buff;
wire [15:0] Data_ID_EX_buff;
wire [2:0] Rdst1_ID_EX_buff;
wire [2:0] Rdst2_ID_EX_buff;
wire [3:0] PORT_ID_EX_buff;
wire [2:0] Rsrc_ID_EX_buff;
wire INT_ID_EX_buff;

wire [15:0] Rdst_val_ID_EX_buff;
wire [15:0] Rsrc_val_ID_EX_buff;

wire [1:0] ALU_src1_ID_EX_buff;
wire mem_write_ID_EX_buff;
wire mem_read_ID_EX_buff;
wire reglow_write_ID_EX_buff;
wire reghigh_write_ID_EX_buff;
wire [3:0] ALU_OP_ID_EX_buff;
wire port_write_ID_EX_buff;
wire port_read_ID_EX_buff;
wire mem_type_ID_EX_buff;
wire memToReg_ID_EX_buff;
wire set_Z_ID_EX_buff;
wire set_N_ID_EX_buff;
wire set_C_ID_EX_buff;
wire set_INT_ID_EX_buff;
wire clr_Z_ID_EX_buff;
wire clr_N_ID_EX_buff;
wire clr_C_ID_EX_buff;
wire clr_INT_ID_EX_buff;
wire [1:0] jmp_sel_ID_EX_buff;
wire [1:0] SP_src_ID_EX_buff;
wire is_jmp_ID_EX_buff;
wire jmp_src_ID_EX_buff;
wire mem_data_src_ID_EX_buff;
wire mem_addr_src_ID_EX_buff;
wire PC_push_pop_ID_EX_buff;
wire flags_push_pop_ID_EX_buff;

/**************************************************************
	immediate wires for the EX stage
**************************************************************/

/*inputs*/

/*outputs*/

/**************************************************************
	immediate wires for the EX_MEM buffer
**************************************************************/

/*inputs*/

/*outputs*/

/**************************************************************
	immediate wires for the MEM stage
**************************************************************/

/*inputs*/

/*outputs*/

/**************************************************************
	immediate wires for the MEM_WB buffer
**************************************************************/

/*inputs*/

/*outputs*/

/**************************************************************
	immediate wires for the WB stage
**************************************************************/

/*inputs*/

/*outputs*/
wire [15:0] Rdst2_val_WB;
wire [2:0] Rdst2_WB;
wire reghigh_write_WB;
wire [15:0] Rdst1_val_WB;
wire [2:0] Rdst1_WB;
wire reglow_write_WB;


/**************************************************************
	connecting the modules(stages) together
**************************************************************/

IF instr_fetch(.PC_IF_out(PC_IF), .instruction(instruction_IF), .Data(Data_IF), .INT(INT_IF), .clk(clk), .reset(reset), .interrupt(interrupt), .exception(exception_IF),
				.SET_INT(SET_INT_IF), .pop_pc(pop_pc_IF), .PC_popedValue(PC_popedValue_IF), .jmp_sgn(jmp_sgn_IF), .PC_jmpValue(PC_jmpValue_IF), .stall(stall));

IF_ID fetch_decode_buff(.PC_out(PC_IF_ID_buff), .instruction_out(instr_IF_ID_buff), .Data_out(data_IF_ID_buff), .INT_out(INT_IF_ID_buff), 
						.PC_in(PC_IF), .instruction_in(instruction_IF), .Data_in(Data_IF), .INT_in(INT_IF), .stall(stall), .reset(reset), .clk(clk));
						
ID instr_decode(.PC_out(PC_ID), .Shmt_out(Shmt_ID), .hash_imm_out(hash_imm_ID), .Data_out(Data_ID), .Rdst1_out(Rdst1_ID), .Rdst_val_out(Rdst_val_ID), .Rsrc_val_out(Rsrc_val_ID),
				.ALU_src1_out(ALU_src1_ID), .mem_write_out(mem_write_ID), .mem_read_out(mem_read_ID), .reglow_write_out(reglow_write_ID), .reghigh_write_out(reghigh_write_ID),
				.ALU_OP_out(ALU_OP_ID), .port_write_out(port_write_ID), .port_read_out(port_read_ID), .Rdst2_out(Rdst2_ID), .mem_type_out(mem_type_ID), .memToReg_out(memToReg_ID),
				.set_Z_out(set_Z_ID), .set_N_out(set_N_ID), .set_C_out(set_C_ID), .set_INT_out(set_INT_ID), .clr_Z_out(clr_Z_ID), .clr_N_out(clr_N_ID),.clr_C_out(clr_C_ID), 
				.clr_INT_out(clr_INT_ID), .jmp_sel_out(jmp_sel_ID), .SP_src_out(SP_src_ID), .PORT_out(PORT_ID), .Rsrc_out(Rsrc_ID), .is_jmp_out(is_jmp_ID), .jmp_src_out(jmp_src_ID),
				.mem_data_src_out(mem_data_src_ID), .mem_addr_src_out(mem_addr_src_ID), .INT_out(INT_ID), .PC_push_pop_out(PC_push_pop_ID), .flags_push_pop_out(flags_push_pop_ID), 
				.PC_in(PC_IF_ID_buff), .instruction_in(instr_IF_ID_buff), .Data_in(data_IF_ID_buff), .INT_in(INT_IF_ID_buff), .data_to_be_written_low_in(Rdst1_val_WB), 
				.reg_dst_low_in(Rdst1_WB), .reg_write_low_in(reglow_write_WB), .data_to_be_written_high_in(Rdst2_val_WB), .reg_dst_high_in(Rdst2_WB), .reg_write_high_in(reghigh_write_WB), 
				.reset(reset), .clk(clk));

ID_EX decode_execute_buff(.PC_out(PC_ID_EX_buff), .Shmt_out(Shmt_ID_EX_buff), .hash_imm_out(hash_imm_ID_EX_buff), .Data_out(Data_ID_EX_buff), .Rdst1_out(Rdst1_ID_EX_buff), 
							.Rdst_val_out(Rdst_val_ID_EX_buff), .Rsrc_val_out(Rsrc_val_ID_EX_buff), .ALU_src1_out(ALU_src1_ID_EX_buff), .mem_write_out(mem_write_ID_EX_buff),
							.mem_read_out(mem_read_ID_EX_buff), .reglow_write_out(reglow_write_ID_EX_buff), .reghigh_write_out(reghigh_write_ID_EX_buff), .ALU_OP_out(ALU_OP_ID_EX_buff), 
							.port_write_out(port_write_ID_EX_buff), .port_read_out(port_read_ID_EX_buff), .Rdst2_out(Rdst2_ID_EX_buff), .mem_type_out(mem_type_ID_EX_buff), .memToReg_out(memToReg_ID_EX_buff), 
							.set_Z_out(set_Z_ID_EX_buff), .set_N_out(set_N_ID_EX_buff), .set_C_out(set_C_ID_EX_buff), .set_INT_out(set_INT_ID_EX_buff), .clr_Z_out(clr_Z_ID_EX_buff), .clr_N_out(clr_N_ID_EX_buff),
							.clr_C_out(clr_C_ID_EX_buff), .clr_INT_out(clr_INT_ID_EX_buff), .jmp_sel_out(jmp_sel_ID_EX_buff), .SP_src_out(SP_src_ID_EX_buff), .PORT_out(PORT_ID_EX_buff), .Rsrc_out(Rsrc_ID_EX_buff), 
							.is_jmp_out(is_jmp_ID_EX_buff), .jmp_src_out(jmp_src_ID_EX_buff), .mem_data_src_out(mem_data_src_ID_EX_buff), .mem_addr_src_out(mem_addr_src_ID_EX_buff), .INT_out(INT_ID_EX_buff), 
							.PC_push_pop_out(PC_push_pop_ID_EX_buff), .flags_push_pop_out(flags_push_pop_ID_EX_buff), .PC_in(PC_ID), .Shmt_in(Shmt_ID), .hash_imm_in(hash_imm_ID), .Data_in(Data_ID), .Rdst1_in(Rdst1_ID), 
							.Rdst_val_in(Rdst_val_ID), .Rsrc_val_in(Rsrc_val_ID), .ALU_src1_in(ALU_src1_ID), .mem_write_in(mem_write_ID), .mem_read_in(mem_read_ID), .reglow_write_in(reglow_write_ID), .reghigh_write_in(reghigh_write_ID),
							.ALU_OP_in(ALU_OP_ID), .port_write_in(port_write_ID), .port_read_in(port_read_ID), .Rdst2_in(Rdst2_ID), .mem_type_in(mem_type_ID), .memToReg_in(memToReg_ID), .set_Z_in(set_Z_ID), .set_N_in(set_N_ID), 
							.set_C_in(set_C_ID), .set_INT_in(set_INT_ID), .clr_Z_in(clr_Z_ID), .clr_N_in(clr_N_ID), .clr_C_in(clr_C_ID), .clr_INT_in(clr_INT_ID), .jmp_sel_in(jmp_sel_ID), .SP_src_in(SP_src_ID), .PORT_in(PORT_ID),
							.Rsrc_in(Rsrc_ID), .is_jmp_in(is_jmp_ID), .jmp_src_in(jmp_src_ID), .mem_data_src_in(mem_data_src_ID), .mem_addr_src_in(mem_addr_src_ID), .INT_in(INT_ID), .PC_push_pop_in(PC_push_pop_ID),
							.flags_push_pop_in(flags_push_pop_ID), .stall(stall), .reset(reset), .clk(clk));

endmodule