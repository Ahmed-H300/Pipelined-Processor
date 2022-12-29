`include "../utils/mem.v"

/*this is the memory stage which includes anything related to the data memory like SP, store load also anything related to PORTs(I/O)*/
module MEM(Rdst2_val_out, Rdst2_out, reghigh_write_out, reglow_write_out, Rdst1_out, Rdst1_val_out, Data_out, memToReg_out, POP_PC_addr_out, POP_PC_sgn_out,
			POP_flags_val_out, POP_flags_sgn_out, stall_out, SP_val_out, PC_in, SP_src_in, port_write_in, port_read_in, Rdst1_val_in, Rdst1_in, mem_write_in, mem_read_in, reglow_write_in,
			reghigh_write_in, Rdst2_in, mem_type_in, memToReg_in, Rdst2_val_in, PORT_in, Rsrc_in, Rsrc_val_in, mem_data_src_in, mem_addr_src_in, Rdst_val_in,
			INT_in, PC_push_pop_in, flags_push_pop_in, DATA_WB_in, forward_data_to_write_data_FU2_in, forward_data_to_address_FU2_in, reset, clk);


/*this is the address of PC when POP PC*/
output wire [31:0] POP_PC_addr_out;

/*this is the signal that tells PC to change its value to the popped value*/
output wire POP_PC_sgn_out;

/*this is the flags popped out when there is POP flags*/
output wire [3:0] POP_flags_val_out;

/*this is the signal to pop the flags and change the value of flags*/
output wire POP_flags_sgn_out;

/*stalling the previous stages if there is POP PC or PUSH PC*/
output wire stall_out; 

/*this is the reset signal that zero out the content of data memory, port and so on..*/
input wire reset;

/*this is the clk that derives the registers*/
input wire clk;

/*this is the SP current value to be used in exception detection unit*/
output wire[31:0] SP_val_out;

/**************************************************************
	value read from the EX_MEM buffer
	(refer to EX_MEM.v to know what each symbol means) 
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

/**************************************************************
	value bypassed from the EX_MEM buffer
	(refer to EX_MEM.v to know what each symbol means) 
	(don't forget to have a look at the design files)
**************************************************************/
output wire [15:0] Rdst2_val_out;
output wire [2:0] Rdst2_out;
output wire reghigh_write_out;
output wire reglow_write_out;
output wire [2:0] Rdst1_out;
output wire [15:0] Rdst1_val_out;
output wire [15:0] Data_out;
output wire memToReg_out;


/**************************************************************
	value come from the forwarding unit 2 and Write-back stage
	(refer to EX_MEM.v to know what each symbol means) 
	(don't forget to have a look at the design files)
**************************************************************/
input wire [15:0] DATA_WB_in;
input wire forward_data_to_write_data_FU2_in;
input wire forward_data_to_address_FU2_in;

/**************************************************************
	intermediate wires for cleaner code
**************************************************************/

/*wires for the stack pointer*/
wire [31:0] SP_in;
wire [31:0] SP_out;
wire [31:0] SP_selectedVal;
wire [1:0] SP_selector;

/*wires for the data memory*/
wire [15:0] data_mem_out;
wire [15:0] data_mem_in;
wire [31:0] data_mem_addr;

/*wires for the port read memory*/
wire [15:0] port_read_data;

/*wires for the port write memory*/ 
wire [15:0] port_read_data_dummy;

/*wires needed for the temp reg*/
wire [15:0] tempReg_out;

/*wires needed for the state reg that's used to wait for 2 cycles*/
wire stateReg_in;
wire stateReg_out;

/*this is actually the stack pointer register*/
reg [31:0] SP;

/*these wires are for forwarding*/
wire [15:0] normal_Addr_without_forward_selected_value;
wire [15:0] normal_WriteData_without_forward_selected_value;

/*do execute the interrupt*/
wire do_PC_push_pop;
wire do_flags_push_pop;

/*these wires are to handle push PC or PC-1 for the condition of the interrupt*/
wire [27:0] PC_tempModified;
wire [31:0] PC_selected;
wire [27:0] PC_realPart;

/**************************************************************
	important assigns for intermediate wires
**************************************************************/
assign PC_realPart = PC_in[27:0];
assign PC_tempModified = (INT_in)	?	PC_realPart - 1 	:	PC_realPart;
assign PC_selected = {PC_in[31:28], PC_tempModified};

assign SP_in = (reset) ? 32'd2047 : SP_selectedVal;
assign SP_selector = (INT_in) ? 2'd2 : SP_src_in;
assign SP_out = SP;

assign SP_selectedVal = 	(SP_selector == 2'd0)	?	SP_out		:
							(SP_selector == 2'd1)	?	SP_out-1	:
							(SP_selector == 2'd2)	?	SP_out+1	:							
														SP_out		;
														
assign normal_Addr_without_forward_selected_value = (mem_addr_src_in) ?	SP_out	:	{{16{1'b0}}, Rsrc_val_in};

assign normal_WriteData_without_forward_selected_value = 	(!mem_data_src_in)	 ?	Rdst_val_in	:
															(!stall_out)	?	PC_selected[15:0]	: PC_selected[31:16];

assign data_mem_addr = 	(forward_data_to_address_FU2_in) 	? 	DATA_WB_in 	: 	normal_Addr_without_forward_selected_value;
assign data_mem_in = 	(forward_data_to_write_data_FU2_in)	?	DATA_WB_in	: 	normal_WriteData_without_forward_selected_value;


assign do_PC_push_pop = PC_push_pop_in | INT_in;
assign do_flags_push_pop = flags_push_pop_in | INT_in;									

/**************************************************************
	creating needed modules
**************************************************************/
memory #(4096) data_memory(.data_out(data_mem_out), .reset(reset), .address(data_mem_addr), .data_in(data_mem_in), .mem_read(mem_read_in), .mem_write(mem_write_in), .clk(clk));
memory #(16) port_out_memory(.data_out(port_read_data), .reset(reset), .address({{28{1'b0}}, PORT_in}), .data_in(16'd0), .mem_read(port_read_in), .mem_write(1'b0), .clk(clk));
memory #(16) port_in_memory(.data_out(port_read_data_dummy), .reset(reset), .address({{28{1'b0}}, PORT_in}), .data_in(Rdst_val_in), .mem_read(1'b0), .mem_write(port_write_in), .clk(clk));
	
Reg #(16) tempReg(.out_data(tempReg_out), .reset(reset), .set(1'b0), .clk(stall_out), .in_data(data_mem_out));	
Reg #(1) stateReg(.out_data(stateReg_out), .reset(reset), .set(1'b0), .clk(clk), .in_data(stateReg_in));	

/**************************************************************
	actual logic of SP
**************************************************************/
always @(posedge clk)
begin
	SP = SP_in;
end

/**************************************************************
	the logic of stalling for 1 cycle for commands pop,push PC
**************************************************************/
assign stateReg_in = do_PC_push_pop & (!stateReg_out);


/**************************************************************
	assigning values to the output
**************************************************************/
assign stall_out = do_PC_push_pop & stateReg_out;
assign POP_PC_sgn_out = mem_read_in & do_PC_push_pop & (!stateReg_out);
assign Data_out = (mem_type_in) ? data_mem_out : port_read_data;
assign POP_flags_sgn_out = stall_out & do_flags_push_pop & mem_read_in;
assign POP_flags_val_out = data_mem_out[15:12];
assign Rdst2_val_out = Rdst2_val_in;
assign Rdst2_out = Rdst2_in;
assign reghigh_write_out = reghigh_write_in;
assign reglow_write_out = reglow_write_in;
assign Rdst1_out = Rdst1_in;
assign Rdst1_val_out = Rdst1_val_in;
assign memToReg_out = memToReg_in;
assign POP_PC_addr_out = {4'd0, tempReg_out[11:0], data_mem_out};
assign SP_val_out = SP_out;

endmodule