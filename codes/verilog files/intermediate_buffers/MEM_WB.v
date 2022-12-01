module MEM_WB(Rdst2_val_out, Rdst2_out, reghigh_write_out, reglow_write_out, Rdst1_out, Rdst1_val_out, Data_out, memToReg_out,
			  Rdst2_val_in, Rdst2_in, reghigh_write_in, reglow_write_in, Rdst1_in, Rdst1_val_in, Data_in, memToReg_in, stall, reset, clk);


/*the clk that derives our buffer*/
input wire clk;

/*the reset signal that zeros out our buffer*/
input wire reset;

/*the stall signal that prevents any new value from being stored in the buffer*/
input wire stall;

/**************************************************************
	value bypassed from the MEM stage
	(refer to MEM.v to know what each symbol means) 
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
	value read from the MEM stage
	(refer to MEM.v to know what each symbol means) 
	(don't forget to have a look at the design files)
**************************************************************/	
input wire [15:0] Rdst2_val_in;
input wire [2:0] Rdst2_in;
input wire reghigh_write_in;
input wire reglow_write_in;
input wire [2:0] Rdst1_in;
input wire [15:0] Rdst1_val_in;
input wire [15:0] Data_in;
input wire memToReg_in;


/**************************************************************
	actuals registers in the buffer
**************************************************************/	
reg [15:0] Rdst2_val;
reg [2:0] Rdst2;
reg reghigh_write;
reg reglow_write;
reg [2:0] Rdst1;
reg [15:0] Rdst1_val;
reg [15:0] Data;
reg memToReg;

/**************************************************************
	important assings
**************************************************************/	
assign Rdst2_val_out = Rdst2_val;
assign Rdst2_out = Rdst2;
assign reghigh_write_out = reghigh_write;
assign reglow_write_out = reglow_write;
assign Rdst1_out = Rdst1;
assign Rdst1_val_out = Rdst1_val;
assign Data_out = Data;
assign memToReg_out = memToReg;

/**************************************************************
	the actual logic of the buffer
**************************************************************/	
always @(negedge clk)
begin
	
	if(reset)
	begin
		Rdst2_val <= 16'd0;
		Rdst2 <= 3'd0;
		reghigh_write <= 1'd0;
		reglow_write <= 1'd0;
		Rdst1 <= 3'd0;
		Rdst1_val <= 16'd0;
		Data <= 16'd0;
		memToReg <= 1'd0;		
	end
	
	else if(!stall & !clk)
	begin 
		Rdst2_val <= Rdst2_val_in;
		Rdst2 <= Rdst2_in;
		reghigh_write <= reghigh_write_in;
		reglow_write <= reglow_write_in;
		Rdst1 <= Rdst1_in;
		Rdst1_val <= Rdst1_val_in;
		Data <= Data_in;
		memToReg <= memToReg_in;	
	end

	else 
	begin
		Rdst2_val <= Rdst2_val;
		Rdst2 <= Rdst2;
		reghigh_write <= reghigh_write;
		reglow_write <= reglow_write;
		Rdst1 <= Rdst1;
		Rdst1_val <= Rdst1_val;
		Data <= Data;
		memToReg <= memToReg;	
	end

end

endmodule