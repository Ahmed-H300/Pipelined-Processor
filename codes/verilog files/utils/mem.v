/*this is some generice memory that will be used as portMem, dataMem, instrMem*/
module memory #(parameter memSize = 1024) (data_out, reset, address, data_in, mem_read, mem_write, clk);

/*this is the output data given address and read_signal*/
output wire [15:0] data_out;

/*this is the the reset signal that zero out all the data*/
input wire reset;

/*this is the address in the memory that we want to "read from" / "write to" */
input wire [31:0] address;

/*this is the data input in case that we wanted to write to a specific address in the memory*/
input wire [15:0] data_in;

/*this is the signal that's used to out data given address to the data_out else, it outs zero*/
input wire mem_read;

/*this is the signal that enables writing to a memory given the address*/
input wire mem_write;

/*this is the clk that drives the registers*/
input wire clk;

/*this is a variable used to iterate all over the registers of the memory*/
integer i;

/*this is actually our memory*/
reg [15:0] memory[0:memSize-1];

/*important assigns*/
assign data_out = (mem_read) ? memory[address] : 16'd0;

/*this is the actual logic of reading and writing*/
always @(posedge clk, reset)
begin
	
	if(reset)
	begin
		for (i = 0; i < memSize; i = i + 1) 
			memory[i] <= 16'd0;
	end
	
	else if(clk)
	begin
		if(mem_write)
			memory[address] = data_in;
	end
	
end

endmodule