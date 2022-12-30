/*this is the second forwarding unit to do MEM-MEM forwarding*/
module FU2(forward_Rdst1_to_write_data_out, forward_Rdst2_to_write_data_out, forward_Rdst1_to_address_out, forward_Rdst2_to_address_out, Rdst1_WB_in, Rdst2_WB_in,
			Rdst_MEM_in, Rsrc_MEM_in, reg_low_write_WB, reg_high_write_WB);

/*a signal to determine if we will forward Rdst1 from Write-back stage back to write_data in the data memory*/
output wire forward_Rdst1_to_write_data_out;

/*a signal to determine if we will forward Rdst2 from Write-back stage back to write_data in the data memory*/
output wire forward_Rdst2_to_write_data_out;

/*a signal to determine if we will forward Rdst1 from Write-back stage back to address in the data memory*/
output wire forward_Rdst1_to_address_out;

/*a signal to determine if we will forward Rdst2 from Write-back stage back to address in the data memory*/
output wire forward_Rdst2_to_address_out;

/*this is the Rdst1 number in the write back stage*/
input wire [2:0] Rdst1_WB_in;

/*this is the Rdst2 number in the write back stage*/
input wire [2:0] Rdst2_WB_in;

/*this is the Rdst number in the memory stage*/
input wire [2:0] Rdst_MEM_in;

/*this is the Rsrc number in the memory stage*/
input wire [2:0] Rsrc_MEM_in;

/*this is the signal to indicate a register low write back*/
input wire reg_low_write_WB;

/*this is the signal to indicate a register high write back*/
input wire reg_high_write_WB;

/**************************************************************
	temp wire to make the code looks clean
**************************************************************/
wire is_Rdst_MEM_eq_Rdst1_WB;
wire is_Rdst_MEM_eq_Rdst2_WB;

wire is_Rsrc_MEM_eq_Rdst1_WB;
wire is_Rsrc_MEM_eq_Rdst2_WB;


/**************************************************************
	assigns for the temp wire
**************************************************************/
assign is_Rdst_MEM_eq_Rdst1_WB = (Rdst_MEM_in == Rdst1_WB_in);
assign is_Rdst_MEM_eq_Rdst2_WB = (Rdst_MEM_in == Rdst2_WB_in);
	
assign is_Rsrc_MEM_eq_Rdst1_WB = (Rsrc_MEM_in == Rdst1_WB_in);	
assign is_Rsrc_MEM_eq_Rdst2_WB = (Rsrc_MEM_in == Rdst2_WB_in);	

	
/**************************************************************
	the actual logic of the forwarding unit 2:
		-> 	if 	MEM/WB.reglow_writeback
			and	(EX/MEM.RegisterRdst = MEM/WB.RegisterRdst1)
			then forward MEM/WB.RegisterRdst1 back data to memory data
			
			else if MEM/WB.reghigh_writeback
			and	(EX/MEM.RegisterRdst = MEM/WB.RegisterRdst2)
			then forward MEM/WB.RegisterRdst2 back data to memory data

			
		-> 	if 	MEM/WB.reglow_writeback
			and	(EX/MEM.RegisterRsrc = MEM/WB.RegisterRdst1)
			then forward MEM/WB.RegisterRdst1 back data to memory address
			
			else if MEM/WB.reghigh_writeback
			and	(EX/MEM.RegisterRsrc = MEM/WB.RegisterRdst2)
			then forward MEM/WB.RegisterRdst2 back data to memory address
			
			
**************************************************************/
assign forward_Rdst1_to_write_data_out = is_Rdst_MEM_eq_Rdst1_WB & reg_low_write_WB;
assign forward_Rdst2_to_write_data_out = is_Rdst_MEM_eq_Rdst2_WB & reg_high_write_WB;
assign forward_Rdst1_to_address_out = is_Rsrc_MEM_eq_Rdst1_WB & reg_low_write_WB;
assign forward_Rdst2_to_address_out = is_Rsrc_MEM_eq_Rdst2_WB & reg_high_write_WB;
	
endmodule