/*this is the buffer between the instruction decode and instructiong execute*/
module ID_EX(PC_out, Shmt_out, hash_imm_out, Data_out, Rdst1_out, Rdst_val_out, Rsrc_val_out, ALU_src1_out, mem_write_out, mem_read_out, reglow_write_out, reghigh_write_out,
			ALU_OP_out, port_write_out, port_read_out, Rdst2_out, mem_type_out, memToReg_out, set_Z_out, set_N_out, set_C_out, set_INT_out, clr_Z_out, clr_N_out,
			clr_C_out, clr_INT_out, jmp_sel_out, SP_src_out, PORT_out, Rsrc_out, is_jmp_out, jmp_src_out, mem_data_src_out, mem_addr_src_out, INT_out, PC_push_pop_out,
			flags_push_pop_out, PC_in, Shmt_in, hash_imm_in, Data_in, Rdst1_in, Rdst_val_in, Rsrc_val_in, ALU_src1_in, mem_write_in, mem_read_in, reglow_write_in, reghigh_write_in,
			ALU_OP_in, port_write_in, port_read_in, Rdst2_in, mem_type_in, memToReg_in, set_Z_in, set_N_in, set_C_in, set_INT_in, clr_Z_in, clr_N_in,
			clr_C_in, clr_INT_in, jmp_sel_in, SP_src_in, PORT_in, Rsrc_in, is_jmp_in, jmp_src_in, mem_data_src_in, mem_addr_src_in, INT_in, PC_push_pop_in,
			flags_push_pop_in, stall, reset, clk);
			

/**************************************************************
	value read from the ID stage
	(refer to ID.v to know what each symbol means) 
	(don't forget to have a look at the design files)
**************************************************************/			
output wire [31:0] PC_out;
output wire [3:0] Shmt_out;
output wire [3:0] hash_imm_out;
output wire [15:0] Data_out;
output wire [2:0] Rdst1_out;
output wire [2:0] Rdst2_out;
output wire [3:0] PORT_out;
output wire [2:0] Rsrc_out;
output wire INT_out;

output wire [15:0] Rdst_val_out;
output wire [15:0] Rsrc_val_out;

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
	same values read from the ID stage are buffered to the output
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


/*the clk that dervies the buffer*/
input wire clk;

/*the stall signal the prevents the buffer from storing the income value*/
input wire stall;

/*the reset signal that zero out the content of the buffer*/
input wire reset;


/**************************************************************
	actuals registers in the buffer
**************************************************************/	
reg [31:0] PC;
reg [3:0] Shmt;
reg [3:0] hash_imm;
reg [15:0] Data;
reg [2:0] Rdst1;
reg [2:0] Rdst2;
reg [3:0] PORT;
reg [2:0] Rsrc;
reg INT;

reg [15:0] Rdst_val;
reg [15:0] Rsrc_val;

reg [1:0] ALU_src1;
reg mem_write;
reg mem_read;
reg reglow_write;
reg reghigh_write;
reg [3:0] ALU_OP;
reg port_write;
reg port_read;
reg mem_type;
reg memToReg;
reg set_Z;
reg set_N;
reg set_C;
reg set_INT;
reg clr_Z;
reg clr_N;
reg clr_C;
reg clr_INT;
reg [1:0] jmp_sel;
reg [1:0] SP_src;
reg is_jmp;
reg jmp_src;
reg mem_data_src;
reg mem_addr_src;
reg PC_push_pop;
reg flags_push_pop;


/**************************************************************
	important assigns
**************************************************************/	
assign PC_out = PC;
assign Shmt_out = Shmt;
assign hash_imm_out = hash_imm;
assign Data_out = Data;
assign Rdst1_out = Rdst1;
assign Rdst2_out = Rdst2;
assign PORT_out = PORT;
assign Rsrc_out = Rsrc;
assign INT_out = INT;

assign Rdst_val_out = Rdst_val;
assign Rsrc_val_out = Rsrc_val;

assign ALU_src1_out = ALU_src1;
assign mem_write_out = mem_write;
assign mem_read_out = mem_read;
assign reglow_write_out = reglow_write;
assign reghigh_write_out = reghigh_write;
assign ALU_OP_out = ALU_OP;
assign port_write_out = port_write;
assign port_read_out = port_read;
assign mem_type_out = mem_type;
assign memToReg_out = memToReg;
assign set_Z_out = set_Z;
assign set_N_out = set_N;
assign set_C_out = set_C;
assign set_INT_out = set_INT;
assign clr_Z_out = clr_Z;
assign clr_N_out = clr_N;
assign clr_C_out = clr_C;
assign clr_INT_out = clr_INT;
assign jmp_sel_out = jmp_sel;
assign SP_src_out = SP_src;
assign is_jmp_out = is_jmp;
assign jmp_src_out = jmp_src;
assign mem_data_src_out = mem_data_src;
assign mem_addr_src_out = mem_addr_src;
assign PC_push_pop_out = PC_push_pop;
assign flags_push_pop_out = flags_push_pop;


/**************************************************************
	the actual logic of the buffer
**************************************************************/		
always @(negedge clk)
begin
		if(reset)
	begin
		PC <= 32'd0;
		Shmt <= 4'd0;
		hash_imm <= 4'd0;
		Data <= 16'd0;
		Rdst1 <= 3'd0;
		Rdst2 <= 3'd0;
		PORT <= 4'd0;
		Rsrc <= 3'd0;
		INT <= 1'd0;

		Rdst_val <= 16'd0;
		Rsrc_val <= 16'd0;

		ALU_src1 <= 2'd0;
		mem_write <= 1'd0;
		mem_read <= 1'd0;
		reglow_write <= 1'd0;
		reghigh_write <= 1'd0;
		ALU_OP <= 4'd11;
		port_write <= 1'd0;
		port_read <= 1'd0;
		mem_type <= 1'd0;
		memToReg <= 1'd0;
		set_Z <= 1'd0;
		set_N <= 1'd0;
		set_C <= 1'd0;
		set_INT <= 1'd0;
		clr_Z <= 1'd0;
		clr_N <= 1'd0;
		clr_C <= 1'd0;
		clr_INT <= 1'd0;
		jmp_sel <= 2'd0;
		SP_src <= 2'd0;
		is_jmp <= 1'd0;
		jmp_src <= 1'd0;
		mem_data_src <= 1'd0;
		mem_addr_src <= 1'd0;
		PC_push_pop <= 1'd0;
		flags_push_pop <= 1'd0;	
	end
	
	else if(!stall & !clk)
	begin 
		PC <= PC_in;
		Shmt <= Shmt_in;
		hash_imm <= hash_imm_in;
		Data <= Data_in;
		Rdst1 <= Rdst1_in;
		Rdst2 <= Rdst2_in;
		PORT <= PORT_in;
		Rsrc <= Rsrc_in;
		INT <= INT_in;

		Rdst_val <= Rdst_val_in;
		Rsrc_val <= Rsrc_val_in;

		ALU_src1 <= ALU_src1_in;
		mem_write <= mem_write_in;
		mem_read <= mem_read_in;
		reglow_write <= reglow_write_in;
		reghigh_write <= reghigh_write_in;
		ALU_OP <= ALU_OP_in;
		port_write <= port_write_in;
		port_read <= port_read_in;
		mem_type <= mem_type_in;
		memToReg <= memToReg_in;
		set_Z <= set_Z_in;
		set_N <= set_N_in;
		set_C <= set_C_in;
		set_INT <= set_INT_in;
		clr_Z <= clr_Z_in;
		clr_N <= clr_N_in;
		clr_C <= clr_C_in;
		clr_INT <= clr_INT_in;
		jmp_sel <= jmp_sel_in;
		SP_src <= SP_src_in;
		is_jmp <= is_jmp_in;
		jmp_src <= jmp_src_in;
		mem_data_src <= mem_data_src_in;
		mem_addr_src <= mem_addr_src_in;
		PC_push_pop <= PC_push_pop_in;
		flags_push_pop <= flags_push_pop_in;		
	end

	else 
	begin
		PC <= PC;
		Shmt <= Shmt;
		hash_imm <= hash_imm;
		Data <= Data;
		Rdst1 <= Rdst1;
		Rdst2 <= Rdst2;
		PORT <= PORT;
		Rsrc <= Rsrc;
		INT <= INT;

		Rdst_val <= Rdst_val;
		Rsrc_val <= Rsrc_val;

		ALU_src1 <= ALU_src1;
		mem_write <= mem_write;
		mem_read <= mem_read;
		reglow_write <= reglow_write;
		reghigh_write <= reghigh_write;
		ALU_OP <= ALU_OP;
		port_write <= port_write;
		port_read <= port_read;
		mem_type <= mem_type;
		memToReg <= memToReg;
		set_Z <= set_Z;
		set_N <= set_N;
		set_C <= set_C;
		set_INT <= set_INT;
		clr_Z <= clr_Z;
		clr_N <= clr_N;
		clr_C <= clr_C;
		clr_INT <= clr_INT;
		jmp_sel <= jmp_sel;
		SP_src <= SP_src;
		is_jmp <= is_jmp;
		jmp_src <= jmp_src;
		mem_data_src <= mem_data_src;
		mem_addr_src <= mem_addr_src;
		PC_push_pop <= PC_push_pop;
		flags_push_pop <= flags_push_pop;
	end

end

endmodule