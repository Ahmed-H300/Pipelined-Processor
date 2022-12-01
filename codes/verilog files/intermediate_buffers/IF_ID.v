/*this is the buffer between instruction fetch stage and instruction decode stage*/
module IF_ID (PC_out, instruction_out, Data_out, INT_out, PC_in, instruction_in, Data_in, INT_in, stall, reset, clk);
	
/*this is the PC output from IF stage*/
output wire [31:0] PC_out;

/*this is the instruction output from IF stage*/
output wire [15:0] instruction_out;

/*this is the Data output from IF stage where it will be useful in case of I_type command where the data will act as immediate values*/
output wire [15:0] Data_out;

/*this is the INT output from IF stage*/
output INT_out;

/*this is the PC output from IF stage*/
input wire [31:0] PC_in;

/*this is the instruction output from IF stage*/
input wire [15:0] instruction_in;

/*this is the Data output from IF stage where it will be useful in case of I_type command where the data will act as immediate values*/
input wire [15:0] Data_in;

/*this is the INT output from IF stage*/
input INT_in;

/*this is the stall signal that will prevent the bufffer from allowing the input to pass to the output*/
input wire stall;

/*this is the reset signal that will zero out the buffer*/
input wire reset;

/*this is the clk that derives our buffer*/
input wire clk;

/**************************************************************
	actual register in the buffer
**************************************************************/
reg [31:0] PC;
reg [15:0] instruction;
reg [15:0] Data;
reg INT;

/**************************************************************
	important assigns
**************************************************************/
assign PC_out = PC;
assign instruction_out = instruction;
assign Data_out = Data;
assign INT_out = INT;

/**************************************************************
	actual logic of the buffer
**************************************************************/
always @(negedge clk)
begin
	
	if(reset)
	begin
		PC <= 32'd0;
		instruction <= 16'd0;
		Data <= 32'd0;
		INT <= 32'd0;	
	end
	
	else if(!stall & !clk)
	begin 
		PC <= PC_in;
		instruction <= instruction_in;
		Data <= Data_in;
		INT <= INT_in;		
	end

	else 
	begin
		PC <= PC;
		instruction <= instruction;
		Data <= Data;
		INT <= INT;		
	end

end

endmodule