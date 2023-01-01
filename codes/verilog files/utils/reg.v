`ifndef REG_V
`define REG_V

/*this is the main building block for any register in our processor and we do writing at positive edge*/
module Reg #(parameter N = 16) (out_data, reset, set, clk, in_data, flush, clr, stall);

/*this is the data to be read from the register*/
output wire [N-1:0] out_data;

/*this is the reset signal that forces the register value to be zero and it's asynchronous*/
input wire reset;

/*this is the signal the foces the register value to be all ones (0xFFFF) and it's asynchronous*/
input wire set;

/*this is the clk the makes our register passes the input*/
input wire clk;

/*this is the in_data that to be passed to the out_data at positive edge*/
input wire [N-1:0] in_data;

/*this is actually our register*/
reg [N-1:0] register;

/*this is the flush signal which is synchronized with clock*/
input wire flush;

/*this is the clr signal similar to reset but doesn't do reset of the stall signal is high unlike reset signal*/
input wire clr;

/*this is the stall signal which prevents the change of the values of the reg*/
input wire stall;

/*important assign*/
assign out_data = register;


/*there is a signal that came and we need to change the output */
always @(posedge clk, reset, set, clr) 
begin 
	if(reset)					// passing 0 on reset
		register <= 0;			
	else if(stall)				// keep the value as it's
		register <= register;	
	else if(clr)				// passing 0 on clr
		register <= 0;
	else if (set)				// passing all ones on set
		register <= {N{1'b1}};	
	else if(clk & flush)		// zero the register
		register <= 0;
	else if(clk)				// passing input on clk
		register <= in_data;	
	else						// if nothing happened which is impossible then keep the value
		register <= register;	
end

endmodule


`endif