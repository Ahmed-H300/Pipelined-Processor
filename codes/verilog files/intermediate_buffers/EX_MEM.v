module EX_MEM(PC_out, SP_src_out, port_write_out, port_read_out, Rdst1_val_out, Rdst1_out, mem_write_out, mem_read_out, reglow_write_out, reghigh_write_out, Rdst2_out, 
				mem_type_out, memToReg_out, Rdst2_val_out, PORT_out, Rsrc_out, Rsrc_val_out, mem_data_src_out, mem_addr_src_out, Rdst_val_out, INT_out, PC_push_pop_out,
				flags_push_pop_out, PC_in, SP_src_in, port_write_in, port_read_in, Rdst1_val_in, Rdst1_in, mem_write_in, mem_read_in, reglow_write_in, reghigh_write_in, Rdst2_in, 
				mem_type_in, memToReg_in, Rdst2_val_in, PORT_in, Rsrc_in, Rsrc_val_in, mem_data_src_in, mem_addr_src_in, Rdst_val_in, INT_in, PC_push_pop_in,
				flags_push_pop_in, clk, reset, stall, flush);



/**************************************************************
	value read from the EX stage
	(refer to EX.v to know what each symbol means) 
	(don't forget to have a look at the design files)
**************************************************************/
output wire [15:0] Rdst1_val_out;
output wire [15:0] Rdst2_val_out;
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
	value read from the EX stage
	(refer to EX.v to know what each symbol means) 
	(don't forget to have a look at the design files)
**************************************************************/		
input wire [15:0] Rdst1_val_in;
input wire [15:0] Rdst2_val_in;
input wire [31:0] PC_in;
input wire [1:0] SP_src_in;
input wire port_write_in;
input wire port_read_in;
input wire [2:0] Rdst1_in;
input wire mem_write_in; 
input wire mem_read_in;
input wire reglow_write_in;
input wire reghigh_write_in;
input wire [2:0] Rdst2_in;
input wire mem_type_in;
input wire memToReg_in;
input wire [3:0] PORT_in;
input wire [2:0] Rsrc_in;
input wire [15:0] Rsrc_val_in;
input wire mem_data_src_in;
input wire mem_addr_src_in;
input wire [15:0] Rdst_val_in;
input wire INT_in;
input wire PC_push_pop_in;
input wire flags_push_pop_in;


/*the clk that dervies the buffer*/
input wire clk;

/*the stall signal the prevents the buffer from storing the income value*/
input wire stall;

/*the reset signal that zero out the content of the buffer*/
input wire reset;

/*this is the flush signal and it's synchrounous with the clock*/
input wire flush;

/**************************************************************
	actuals registers in the buffer
**************************************************************/
reg [15:0] Rdst1_val;
reg [15:0] Rdst2_val;
reg [31:0] PC;
reg [1:0] SP_src;
reg port_write;
reg port_read;
reg [2:0] Rdst1;
reg mem_write; 
reg mem_read;
reg reglow_write;
reg reghigh_write;
reg [2:0] Rdst2;
reg mem_type;
reg memToReg;
reg [3:0] PORT;
reg [2:0] Rsrc;
reg [15:0] Rsrc_val;
reg mem_data_src;
reg mem_addr_src;
reg [15:0] Rdst_val;
reg INT;
reg PC_push_pop;
reg flags_push_pop;

/**************************************************************
	important assigns
**************************************************************/
assign Rdst1_val_out = Rdst1_val;
assign Rdst2_val_out = Rdst2_val;
assign PC_out = PC;
assign SP_src_out = SP_src;
assign port_write_out = port_write;
assign port_read_out = port_read;
assign Rdst1_out = Rdst1;
assign mem_write_out = mem_write; 
assign mem_read_out = mem_read;
assign reglow_write_out = reglow_write;
assign reghigh_write_out = reghigh_write;
assign Rdst2_out = Rdst2;
assign mem_type_out = mem_type;
assign memToReg_out = memToReg;
assign PORT_out = PORT;
assign Rsrc_out = Rsrc;
assign Rsrc_val_out = Rsrc_val;
assign mem_data_src_out = mem_data_src;
assign mem_addr_src_out = mem_addr_src;
assign Rdst_val_out = Rdst_val;
assign INT_out = INT;
assign PC_push_pop_out = PC_push_pop;
assign flags_push_pop_out = flags_push_pop;

/**************************************************************
	the actual logic of the buffer
**************************************************************/	
always @(negedge clk, posedge reset)
begin 

	if(reset)
	begin
		Rdst1_val <= 16'd0;
		Rdst2_val <= 16'd0;
		PC <= 32'd0;
		SP_src <= 2'd0;
		port_write <= 1'd0;
		port_read <= 1'd0;
		Rdst1 <= 3'd0;
		mem_write <= 1'd0;
		mem_read <= 1'd0;
	 	reglow_write <= 1'd0;
		reghigh_write <= 1'd0;
		Rdst2 <= 3'd0;
		mem_type <= 1'd0;
		memToReg <= 1'd0;
		PORT <= 4'd0;
		Rsrc <= 3'd0;
		Rsrc_val <= 16'd0;
		mem_data_src <= 1'd0;
		mem_addr_src <= 1'd0;
		Rdst_val <= 16'd0;
		INT <= 1'd0;
		PC_push_pop <= 1'd0;
		flags_push_pop <= 1'd0;		
	end
	
	else if(flush)
	begin
		Rdst1_val <= 16'd0;
		Rdst2_val <= 16'd0;
		SP_src <= 2'd0;
		port_write <= 1'd0;
		port_read <= 1'd0;
		Rdst1 <= 3'd0;
		mem_write <= 1'd0;
		mem_read <= 1'd0;
	 	reglow_write <= 1'd0;
		reghigh_write <= 1'd0;
		Rdst2 <= 3'd0;
		mem_type <= 1'd0;
		memToReg <= 1'd0;
		PORT <= 4'd0;
		Rsrc <= 3'd0;
		Rsrc_val <= 16'd0;
		mem_data_src <= 1'd0;
		mem_addr_src <= 1'd0;
		Rdst_val <= 16'd0;
		PC_push_pop <= 1'd0;
		flags_push_pop <= 1'd0;		
	end
	
	else if(!stall & !clk)
	begin 
		Rdst1_val <= Rdst1_val_in;
		Rdst2_val <= Rdst2_val_in;
		PC <= PC_in;
		SP_src <= SP_src_in;
		port_write <= port_write_in;
		port_read <= port_read_in;
		Rdst1 <= Rdst1_in;
		mem_write <= mem_write_in;
		mem_read <= mem_read_in;
	 	reglow_write <= reglow_write_in;
		reghigh_write <= reghigh_write_in;
		Rdst2 <= Rdst2_in;
		mem_type <= mem_type_in;
		memToReg <= memToReg_in;
		PORT <= PORT_in;
		Rsrc <= Rsrc_in;
		Rsrc_val <= Rsrc_val_in;
		mem_data_src <= mem_data_src_in;
		mem_addr_src <= mem_addr_src_in;
		Rdst_val <= Rdst_val_in;
		INT <= INT_in;
		PC_push_pop <= PC_push_pop_in;
		flags_push_pop <= flags_push_pop_in;
	end

	else 
	begin
		Rdst1_val <= Rdst1_val;
		Rdst2_val <= Rdst2_val;
		PC <= PC;
		SP_src <= SP_src;
		port_write <= port_write;
		port_read <= port_read;
		Rdst1 <= Rdst1;
		mem_write <= mem_write;
		mem_read <= mem_read;
	 	reglow_write <= reglow_write;
		reghigh_write <= reghigh_write;
		Rdst2 <= Rdst2;
		mem_type <= mem_type;
		memToReg <= memToReg;
		PORT <= PORT;
		Rsrc <= Rsrc;
		Rsrc_val <= Rsrc_val;
		mem_data_src <= mem_data_src;
		mem_addr_src <= mem_addr_src;
		Rdst_val <= Rdst_val;
		INT <= INT;
		PC_push_pop <= PC_push_pop;
		flags_push_pop <= flags_push_pop;
	end


end


endmodule