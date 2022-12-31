/*this is the register file that holds registers from R0 to R7 where each one is 16-bit width*/
module regFile(reg1_read_src, reg2_read_dst, reg_readnum_dst, reg_readnum_src, reset, clk, reg_dst_low, 
				reg_dst_high, data_to_be_written_low, data_to_be_written_high, reg_write_high, reg_write_low);

/*this is the data to be read into Rsrc value into ALU*/
output wire [15:0] reg1_read_src;

/*this is the data to be read into Rdst value into ALU*/
output wire [15:0] reg2_read_dst;

/*to select which register to be read as Rdst*/
input wire [2:0] reg_readnum_dst;

/*to select which register to be read as Rsrc*/
input wire [2:0] reg_readnum_src;

/*a reset signal that cause all register to be 0*/
input wire reset;

/*clk that makes register can be written into it*/
input wire clk;

/*to select which register to write the data to it where this register is the lower 16 bits in case of multiplication*/
input wire [2:0] reg_dst_low;

/*to select which register to write the data to it where this register is the upper 16 bits in case of multiplication*/
input wire [2:0] reg_dst_high;

/*this is the actual data to write to the register where it represents the lower 16 bits in case of multiplication*/
input wire [15:0] data_to_be_written_low;

/*this is the actual data to write to the register where it represents the upper 16 bits in case of multiplication*/
input wire [15:0] data_to_be_written_high;

/*this is the enable signal that snables writing to the register which is the default AKA : the upper 16 bits in case of multiplication*/
input wire reg_write_high;

/*this is the enable signal that snables writing to the register which is the default AKA : the lower 16 bits in case of multiplication*/
input wire reg_write_low;


/**************************************************************
	temp wires to make the code looks clean
**************************************************************/
wire clk_Rdst1;					// this is the clock that will be fed to the first destination register (lower 16 bits in case of multiplication)
wire clk_Rdst2;					// this is the clock that will be fed to the second destination register (the upper 16 bits in case of multiplication)
wire clk_Rdst1_input[0:7];		// this is array of wires where each wire will carry the clock to a unique reigster based on selection of Rdst1
wire clk_Rdst2_input[0:7];		// this is array of wires where each wire will carry the clock to a unique reigster based on selection of Rdst2
wire clk_actual[0:7];			// this is is actual clock that will be passed into each unique register
wire [15:0] data_actual[0:7];	// this is the actual data that to be passed to the input of the register
wire data_clk_select[0:7];		// we need to handle if the command asked to write Rdst1 and Rdst2 to the same register then we will give the priority to Rdst1 and same thig for clk
genvar it;						// this is just an iterator to create for loops
wire [15:0] register_out[0:7];	// these are the data read from the registers

/*evaulating the values of theses temp(intermediate) wire refer to the reigsterFile design in the pdf*/
assign clk_Rdst1 = clk & reg_write_low;
assign clk_Rdst2 = clk & reg_write_high;

/*generate array of muxes to select both actual clock and actual data_in*/
generate
  for(it = 0; it < 8; it = it + 1) 
  begin
    assign clk_actual[it] = data_clk_select[it] ? clk_Rdst1_input[it] : clk_Rdst2_input[it];
	assign data_actual[it] = data_clk_select[it] ? data_to_be_written_low : data_to_be_written_high;
  end
endgenerate

/*generating the actual registers*/
generate
  for(it = 0; it < 8; it = it + 1) 
  begin
    Reg #(16) registerModule(.out_data(register_out[it]), .reset(reset), .set(1'b0), .clk(clk_actual[it]), .in_data(data_actual[it]), .flush(1'b0));
  end
endgenerate

/*demultiplexing the clock*/
assign {clk_Rdst1_input[0], clk_Rdst1_input[1], clk_Rdst1_input[2], clk_Rdst1_input[3], clk_Rdst1_input[4], clk_Rdst1_input[5], clk_Rdst1_input[6], clk_Rdst1_input[7]}= 
						(reg_dst_low == 3'd0) 	? 	{clk_Rdst1	, 1'd0		, 1'd0		, 1'd0		, 1'd0		, 1'd0		, 1'd0		, 1'd0		} :
						(reg_dst_low == 3'd1) 	? 	{1'd0		, clk_Rdst1	, 1'd0		, 1'd0		, 1'd0		, 1'd0		, 1'd0		, 1'd0		} :
						(reg_dst_low == 3'd2) 	? 	{1'd0		, 1'd0		, clk_Rdst1	, 1'd0		, 1'd0		, 1'd0		, 1'd0		, 1'd0		} :
						(reg_dst_low == 3'd3) 	? 	{1'd0		, 1'd0		, 1'd0		, clk_Rdst1	, 1'd0		, 1'd0		, 1'd0		, 1'd0		} :
						(reg_dst_low == 3'd4) 	? 	{1'd0		, 1'd0		, 1'd0		, 1'd0		, clk_Rdst1	, 1'd0		, 1'd0		, 1'd0		} :
						(reg_dst_low == 3'd5) 	? 	{1'd0		, 1'd0		, 1'd0		, 1'd0		, 1'd0		, clk_Rdst1	, 1'd0		, 1'd0		} :
						(reg_dst_low == 3'd6) 	? 	{1'd0		, 1'd0		, 1'd0		, 1'd0		, 1'd0		, 1'd0		, clk_Rdst1	, 1'd0		} :
													{1'd0		, 1'd0		, 1'd0		, 1'd0		, 1'd0		, 1'd0		, 1'd0		, clk_Rdst1	} ;

assign {clk_Rdst2_input[0], clk_Rdst2_input[1], clk_Rdst2_input[2], clk_Rdst2_input[3], clk_Rdst2_input[4], clk_Rdst2_input[5], clk_Rdst2_input[6], clk_Rdst2_input[7]}= 
						(reg_dst_high == 3'd0) 	? 	{clk_Rdst2	, 1'd0		, 1'd0		, 1'd0		, 1'd0		, 1'd0		, 1'd0		, 1'd0		} :
						(reg_dst_high == 3'd1) 	? 	{1'd0		, clk_Rdst2	, 1'd0		, 1'd0		, 1'd0		, 1'd0		, 1'd0		, 1'd0		} :
						(reg_dst_high == 3'd2) 	? 	{1'd0		, 1'd0		, clk_Rdst2	, 1'd0		, 1'd0		, 1'd0		, 1'd0		, 1'd0		} :
						(reg_dst_high == 3'd3) 	? 	{1'd0		, 1'd0		, 1'd0		, clk_Rdst2	, 1'd0		, 1'd0		, 1'd0		, 1'd0		} :
						(reg_dst_high == 3'd4) 	? 	{1'd0		, 1'd0		, 1'd0		, 1'd0		, clk_Rdst2	, 1'd0		, 1'd0		, 1'd0		} :
						(reg_dst_high == 3'd5) 	? 	{1'd0		, 1'd0		, 1'd0		, 1'd0		, 1'd0		, clk_Rdst2	, 1'd0		, 1'd0		} :
						(reg_dst_high == 3'd6) 	? 	{1'd0		, 1'd0		, 1'd0		, 1'd0		, 1'd0		, 1'd0		, clk_Rdst2	, 1'd0		} :
													{1'd0		, 1'd0		, 1'd0		, 1'd0		, 1'd0		, 1'd0		, 1'd0		, clk_Rdst2	} ;
			
/*demultiplexing the select*/
assign {data_clk_select[0], data_clk_select[1], data_clk_select[2], data_clk_select[3], data_clk_select[4], data_clk_select[5], data_clk_select[6], data_clk_select[7]}= 
						(reg_dst_low == 3'd0)	?	{1'd1, 1'd0, 1'd0, 1'd0, 1'd0, 1'd0, 1'd0, 1'd0} :
						(reg_dst_low == 3'd1)	?	{1'd0, 1'd1, 1'd0, 1'd0, 1'd0, 1'd0, 1'd0, 1'd0} :
						(reg_dst_low == 3'd2)	?	{1'd0, 1'd0, 1'd1, 1'd0, 1'd0, 1'd0, 1'd0, 1'd0} :
						(reg_dst_low == 3'd3)	?	{1'd0, 1'd0, 1'd0, 1'd1, 1'd0, 1'd0, 1'd0, 1'd0} :
						(reg_dst_low == 3'd4)	?	{1'd0, 1'd0, 1'd0, 1'd0, 1'd1, 1'd0, 1'd0, 1'd0} :
						(reg_dst_low == 3'd5)	?	{1'd0, 1'd0, 1'd0, 1'd0, 1'd0, 1'd1, 1'd0, 1'd0} :
						(reg_dst_low == 3'd6)	?	{1'd0, 1'd0, 1'd0, 1'd0, 1'd0, 1'd0, 1'd1, 1'd0} :
													{1'd0, 1'd0, 1'd0, 1'd0, 1'd0, 1'd0, 1'd0, 1'd1} ;
													
													
/*multiplexing the data read from the register*/
assign reg2_read_dst = 	(reg_readnum_dst == 3'd0)	?	register_out[0]	:
						(reg_readnum_dst == 3'd1)	?	register_out[1]	:
						(reg_readnum_dst == 3'd2)	?	register_out[2]	:
						(reg_readnum_dst == 3'd3)	?	register_out[3]	:
						(reg_readnum_dst == 3'd4)	?	register_out[4]	:
						(reg_readnum_dst == 3'd5)	?	register_out[5]	:
						(reg_readnum_dst == 3'd6)	?	register_out[6]	:
														register_out[7]	;
														
														
assign reg1_read_src = 	(reg_readnum_src == 3'd0)	?	register_out[0]	:
						(reg_readnum_src == 3'd1)	?	register_out[1]	:
						(reg_readnum_src == 3'd2)	?	register_out[2]	:
						(reg_readnum_src == 3'd3)	?	register_out[3]	:
						(reg_readnum_src == 3'd4)	?	register_out[4]	:
						(reg_readnum_src == 3'd5)	?	register_out[5]	:
						(reg_readnum_src == 3'd6)	?	register_out[6]	:
														register_out[7]	;						
		
endmodule