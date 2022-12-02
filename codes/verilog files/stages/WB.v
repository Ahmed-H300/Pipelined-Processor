/*this is the write back stage*/
module WB( Rdst2_val_out, Rdst2_out, reghigh_write_out, reglow_write_out, Rdst1_out, Rdst1_val_out,
		   Rdst2_val_in, Rdst2_in, reghigh_write_in, reglow_write_in, Rdst1_in, Rdst1_val_in, Data_in, memToReg_in);


/**************************************************************
	inputs coming from the MEM_WB buffer 
	(logic is so simple, no need to comment and explain)
**************************************************************/
input wire [15:0] Rdst2_val_in;
input wire [2:0] Rdst2_in;
input wire reghigh_write_in;
input wire [15:0] Rdst1_val_in;
input wire [2:0] Rdst1_in;
input wire reglow_write_in;
input wire [15:0] Data_in;
input wire memToReg_in;

/**************************************************************
	outputs from the WB 
	(logic is so simple, no need to comment and explain)
**************************************************************/
output wire [15:0] Rdst2_val_out;
output wire [2:0] Rdst2_out;
output wire reghigh_write_out;
output wire [15:0] Rdst1_val_out;
output wire [2:0] Rdst1_out;
output wire reglow_write_out;

/**************************************************************
	assigning the outputs
**************************************************************/
assign Rdst1_val_out = (memToReg_in) ? Data_in : Rdst1_val_in;  // the whole logic of the write back stage
assign Rdst2_val_out = Rdst2_val_in;
assign Rdst2_out = Rdst2_in;
assign reghigh_write_out = reghigh_write_in;
assign reglow_write_out = reglow_write_in;
assign Rdst1_out = Rdst1_in;

endmodule