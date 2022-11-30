`include "../units/CU.v"
`include "../units/regFile.v"

/*this is the instruction decoding stage where we decode the instructions and produce the required signals and read values from register file*/
module ID(PC_out, Shmt_out, hash_imm_out, Data_out, Rdst1_out, Rdst_val_out, Rsrc_val_out, ALU_src1_out, mem_write_out, mem_read_out, reglow_write_out, reghigh_write_out,
			ALU_OP_out, port_write_out, port_read_out, Rdst2_out, mem_type_out, memToReg_out, set_Z_out, set_N_out, set_C_out, set_INT_out, clr_Z_out, clr_N_out,
			clr_C_out, clr_INT_out, jmp_sel_out, SP_src_out, PORT_out, Rsrc_out, is_jmp_out, jmp_src_out, mem_data_src_out, mem_addr_src_out, INT_out, PC_push_pop_out,
			flags_push_pop_out, PC_in, instruction_in, Data_in, INT_in, data_to_be_written_low_in, reg_dst_low_in, reg_write_low_in, data_to_be_written_high_in, 
			reg_dst_high_in, reg_write_high_in, reset, clk);

/*this is the program counter comming from the IF stage*/
output wire [31:0] PC_out;

/*incase of shifting operation then this is the number used to shift the register by*/
output wire [3:0] Shmt_out;

/*in case of I_type (in absolute jumps) then this number is concatenated with data to cover the whole memory*/
output wire [3:0] hash_imm_out;

/*this is the immediate value (16 bits) incase of I_type instructions*/
output wire [15:0] Data_out;

/*this is the number of the destination register number 1 (lower 16 bits in case of multiplication)*/
output wire [2:0] Rdst1_out;

/*this is the number of the destination register number 2 (higher 16 bits in case of multiplication)*/
output wire [2:0] Rdst2_out;

/*this is the port number incase we needed to do I/O operations*/
output wire [3:0] PORT_out;

/*this is the number of the source register*/
output wire [2:0] Rsrc_out;

/*this is the interrupt signal*/
output wire INT_out;

/*this is the reset signal that's passed to the registerFile*/
input wire reset;

/*this is the clk that derives the regFile*/
input wire clk;

/**************************************************************
	value read from the Write back stage
	(refer to WB.v to know what each symbol means) 
	(don't forget to have a look at the design files)
**************************************************************/
input wire [15:0] data_to_be_written_low_in;
input wire [2:0] reg_dst_low_in;
input wire reg_write_low_in;
input wire [15:0] data_to_be_written_high_in;
input wire [2:0] reg_dst_high_in;
input wire reg_write_high_in;

/**************************************************************
	value read from the before buffer 
	(refer to IF_ID.v to know what each symbol means) 
	(don't forget to have a look at the design files)
**************************************************************/
input wire [31:0] PC_in;
input wire [15:0] instruction_in;
input wire [15:0] Data_in;
input INT_in;


/**************************************************************
	value read from the registerFile 
	(refer to regFile.v to know what each symbol means) 
	(don't forget to have a look at the design files)
**************************************************************/
output wire [15:0] Rdst_val_out;
output wire [15:0] Rsrc_val_out;


/**************************************************************
	value read from the control unit 
	(refer to CU.v to know what each symbol means) 
	(don't forget to have a look at the design files)
**************************************************************/
output wire [1:0] ALU_src1_out;
output wire mem_write_out;
output wire mem_read_out;
output wire reglow_write_out;
output wire reghigh_write_out;
output wire [3:0] ALU_OP_out;
output wire port_write_out;
output wire port_read_out;
output wire mem_type_out;
output wire memToReg_out;
output wire set_Z_out;
output wire set_N_out;
output wire set_C_out;
output wire set_INT_out;
output wire clr_Z_out;
output wire clr_N_out;
output wire clr_C_out;
output wire clr_INT_out;
output wire [1:0] jmp_sel_out;
output wire [1:0] SP_src_out;
output wire is_jmp_out;
output wire jmp_src_out;
output wire mem_data_src_out;
output wire mem_addr_src_out;
output wire PC_push_pop_out;
output wire flags_push_pop_out;

/**************************************************************
	creating needed modules
**************************************************************/
CU controlUnit(.RegLow_write(reglow_write_out), .ALU_OP(ALU_OP_out), .RegHigh_write(reghigh_write_out), .ALU_src1(ALU_src1_out), .MemToReg(memToReg_out), 
				.memWrite(mem_write_out), .memRead(mem_read_out), .portWrite(port_write_out), .portRead(port_read_out), .memType(mem_type_out), .PC_push_pop(PC_push_pop_out), 
				.flags_push_pop(flags_push_pop_out), .JMP_type(jmp_sel_out), .is_jmp(is_jmp_out), .JMP_src(jmp_src_out), .SET_Z(set_Z_out), .SET_N(set_N_out), .SET_C(set_C_out), 
				.SET_INT(set_INT_out), .CLR_Z(clr_Z_out), .CLR_N(clr_N_out), .CLR_C(clr_C_out), .CLR_INT(clr_INT_out), .SP_src(SP_src_out), .mem_data_src(mem_data_src_out), 
				.mem_address_src(mem_addr_src_out), .instruction(instruction_in));
				
regFile registerFile(.reg1_read_src(Rsrc_val_out), .reg2_read_dst(Rdst_val_out), .reg_readnum_dst(instruction_in[11:9]), .reg_readnum_src(instruction_in[8:6]), 
					.reset(reset), .clk(clk), .reg_dst_low(reg_dst_low_in), .reg_dst_high(reg_dst_high_in), .data_to_be_written_low(data_to_be_written_low_in),
					.data_to_be_written_high(data_to_be_written_high_in), .reg_write_high(reg_write_high_in), .reg_write_low(reg_write_low_in));				

/**************************************************************
	important assigns
**************************************************************/
assign INT_out = INT_in | set_INT_out;
assign Data_out = Data_in;
assign PC_out = PC_in;
assign Shmt_out = instruction_in[5:2];
assign hash_imm_out = instruction_in[6:3];
assign Rdst1_out = instruction_in[11:9];
assign Rdst2_out = instruction_in[5:3];
assign PORT_out = instruction_in[5:2];
assign Rsrc_out = instruction_in[8:6];

endmodule