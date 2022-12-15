/*this is the first forwarding unit to do ALU-ALU or MEM-ALU forwarding*/
module FU1(forward_ALU_dst_out, forward_ALU_src_out, forward_Rdst_num_MEM_to_Rdst_out, forward_Rdst_num_WB_to_Rdst_out, forward_Rdst_num_MEM_to_Rsrc_out, 
			forward_Rdst_num_WB_to_Rsrc_out, Rdst2_wb_WB_in, Rdst1_wb_WB_in, Rdst1_WB_in, Rdst2_WB_in, Rdst1_wb_mem_in, Rdst2_wb_mem_in, Rdst1_mem_in, 
			Rdst2_mem_in, Rsrc_EX_in, Rdst_EX_in);
			
/*this is the selector to select which value to be bypassed to ALU_Rdst*/
output wire [1:0] forward_ALU_dst_out;

/*this is the selector to select which value to be bypassed to ALU_Rsrc*/
output wire [1:0] forward_ALU_src_out;

/*to select between forwarding Rdst1 or Rdst2 from the memory stage to be candidate for ALU_Rds*/
output wire forward_Rdst_num_MEM_to_Rdst_out;

/*to select between forwarding Rdst1 or Rdst2 from the WB stage to be candidate for ALU_Rds*/
output wire forward_Rdst_num_WB_to_Rdst_out;

/*to select between forwarding Rdst1 or Rdst2 from the memory stage to be candidate for ALU_Rsrc*/
output wire forward_Rdst_num_MEM_to_Rsrc_out;

/*to select between forwarding Rdst1 or Rdst2 from the WB stage to be candidate for ALU_Rsrc*/
output wire forward_Rdst_num_WB_to_Rsrc_out;

/*this is the write back signal in the write-back stage for Rdst2*/
input wire Rdst2_wb_WB_in;

/*this is the write back signal in the write-back stage for Rdst1*/
input wire Rdst1_wb_WB_in;

/*this is the Rdst1 number in the write-back stage*/
input wire [2:0] Rdst1_WB_in;

/*this is the Rdst2 number in the write-back stage*/
input wire [2:0] Rdst2_WB_in;

/*this is the write back signal in the mem-back stage for Rdst1*/
input wire Rdst1_wb_mem_in;

/*this is the write back signal in the mem-back stage for Rdst2*/
input wire Rdst2_wb_mem_in;

/*this is the Rdst1 number in the memory stage*/
input wire [2:0] Rdst1_mem_in;

/*this is the Rdst2 number in the memory stage*/
input wire [2:0] Rdst2_mem_in;

/*this is the Rsrc number in the execute stage*/
input wire [2:0] Rsrc_EX_in;

/*this is the Rdst number in the execute stage*/
input wire [2:0] Rdst_EX_in;

/**************************************************************
	temp wire to make the code looks clean
**************************************************************/
wire is_Rdst_EX_eq_Rdst1_mem;
wire is_Rdst_EX_eq_Rdst2_mem;

wire is_Rdst_EX_eq_Rdst1_WB;
wire is_Rdst_EX_eq_Rdst2_WB;

wire is_Rsrc_EX_eq_Rdst1_mem;
wire is_Rsrc_EX_eq_Rdst2_mem;

wire is_Rsrc_EX_eq_Rdst1_WB;
wire is_Rsrc_EX_eq_Rdst2_WB;

/**************************************************************
	assigns for the temp wires
**************************************************************/
assign is_Rdst_EX_eq_Rdst1_mem = (Rdst_EX_in == Rdst1_mem_in) & Rdst1_wb_mem_in;
assign is_Rdst_EX_eq_Rdst2_mem = (Rdst_EX_in == Rdst2_mem_in) & Rdst2_wb_mem_in;

assign is_Rdst_EX_eq_Rdst1_WB = (Rdst_EX_in == Rdst1_WB_in) & Rdst1_wb_WB_in;
assign is_Rdst_EX_eq_Rdst2_WB = (Rdst_EX_in == Rdst2_WB_in) & Rdst2_wb_WB_in;

assign is_Rsrc_EX_eq_Rdst1_mem = (Rsrc_EX_in == Rdst1_mem_in) & Rdst1_wb_mem_in;
assign is_Rsrc_EX_eq_Rdst2_mem = (Rsrc_EX_in == Rdst2_mem_in) & Rdst2_wb_mem_in;

assign is_Rsrc_EX_eq_Rdst1_WB = (Rsrc_EX_in == Rdst1_WB_in) & Rdst1_wb_WB_in;
assign is_Rsrc_EX_eq_Rdst2_WB = (Rsrc_EX_in == Rdst2_WB_in) & Rdst2_wb_WB_in;


/**************************************************************
	the actual logic of the forwarding unit 1:
		-> 	if 	EX/MEM.RegLowWrite
			and	EX/MEM.RegisterRdst1 = ID/EX.RegisterRsrc
			then forward EX/MEM.RegisterRdst1 to ALU_Rsrc
			
			else if EX/MEM.RegHighWrite
			and	EX/MEM.RegisterRdst2 = ID/EX.RegisterRsrc
			then forward EX/MEM.RegisterRdst2 to ALU_Rsrc

			else if MEM/WB.RegLowWrite
			and	EX/MEM.RegisterRdst1 = ID/EX.RegisterRsrc
			then forward EX/MEM.RegisterRdst1 to ALU_Rsrc
			
			else if MEM/WB.RegHighWrite
			and	EX/MEM.RegisterRdst2 = ID/EX.RegisterRsrc
			then forward EX/MEM.RegisterRdst2 to ALU_Rsrc
			
		-> 	if 	EX/MEM.RegLowWrite
			and	EX/MEM.RegisterRdst1 = ID/EX.RegisterRsrc
			then forward EX/MEM.RegisterRdst1 to ALU_Rdst
			
			else if EX/MEM.RegHighWrite
			and	EX/MEM.RegisterRdst2 = ID/EX.RegisterRsrc
			then forward EX/MEM.RegisterRdst2 to ALU_Rdst

			else if MEM/WB.RegLowWrite
			and	EX/MEM.RegisterRdst1 = ID/EX.RegisterRsrc
			then forward EX/MEM.RegisterRdst1 to ALU_Rdst
			
			else if MEM/WB.RegHighWrite
			and	EX/MEM.RegisterRdst2 = ID/EX.RegisterRsrc
			then forward EX/MEM.RegisterRdst2 to ALU_Rdst
			
**************************************************************/
assign forward_ALU_dst_out = 	(is_Rdst_EX_eq_Rdst1_mem | is_Rdst_EX_eq_Rdst2_mem) ?	2'd1	:
								(is_Rdst_EX_eq_Rdst1_WB | is_Rdst_EX_eq_Rdst2_WB) 	?	2'd2	:
																						2'd0	;
																						
assign 	forward_ALU_src_out = 	(is_Rsrc_EX_eq_Rdst1_mem | is_Rsrc_EX_eq_Rdst2_mem) ?	2'd1	:
								(is_Rsrc_EX_eq_Rdst1_WB | is_Rsrc_EX_eq_Rdst2_WB) 	?	2'd2	:
																						2'd0	;						

assign forward_Rdst_num_MEM_to_Rdst_out = is_Rdst_EX_eq_Rdst1_mem;

assign forward_Rdst_num_WB_to_Rdst_out = is_Rdst_EX_eq_Rdst1_WB;

assign forward_Rdst_num_MEM_to_Rsrc_out = is_Rsrc_EX_eq_Rdst1_mem;

assign forward_Rdst_num_WB_to_Rsrc_out = is_Rsrc_EX_eq_Rdst1_WB;
			
endmodule