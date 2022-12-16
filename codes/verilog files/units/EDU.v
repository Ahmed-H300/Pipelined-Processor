/*this is the exception detection unit*/
module EDU(exception_out, exception_ID_out, exception_EXE_out, exception_MEM_out, CAUSE_out, EPC_out, instrOpCode_in, Rsrc_val_Mem_in, mem_write_MEM_in,
			mem_read_MEM_in, SP_MEM_in, is_jmp_EX_in, jmp_addr_EX_in, ALU_OP_in, Rsrc_val_EX_in, PC_ID_in, PC_EXE_in, PC_MEM_in, clk, reset);

/*this is a signal that will arises in case any exception arised*/
output wire exception_out;			
			
/*this is the signal arised due to exception in decode stage*/
output wire exception_ID_out;

/*this is the signal arised due to exception in execute stage*/
output wire exception_EXE_out;

/*this is the signal arised due to exception in memory stage*/
output wire exception_MEM_out;

/*this is the exception number if hapened*/
output wire [2:0] CAUSE_out;

/*this is the address where the exception occured*/
output wire [31:0] EPC_out;

/*this is the opcode of the instruction in the decode stage*/
input wire [3:0] instrOpCode_in;

/*this is the value of Rsrc in the memory stage*/
input wire [15:0] Rsrc_val_Mem_in;

/*this is the memory write signal in the memory stage*/
input wire mem_write_MEM_in;

/*this is the memory read signal in the memory stage*/
input wire mem_read_MEM_in;

/*this is the value of the stack pointer*/
input wire [31:0] SP_MEM_in;

/*this is the signal that indicates if we are about to jump*/
input wire is_jmp_EX_in;

/*this is the address that we will jump to*/
input wire [31:0] jmp_addr_EX_in;

/*this is the ALU operation that we will do to detect division by zero*/
input wire [3:0] ALU_OP_in;

/*this is the value of Rsrc in the execute stage to detect division by 0*/
input wire [15:0] Rsrc_val_EX_in;

/*this is the value of PC in the decode stage*/
input wire [31:0] PC_ID_in;

/*this is the value of PC in the execute stage*/
input wire [31:0] PC_EXE_in;

/*this is the value of PC in the memory stage*/
input wire [31:0] PC_MEM_in;

/*this is the clock and reset needed for registers*/
input wire clk, reset;
  

/**************************************************************
	temp wire to make the code looks clean
**************************************************************/
wire [2:0] cause_of_exception;		// this is a number to tell exception number
wire [1:0] PC_src;					// to determine which PC value from which stage should we take

wire is_stacK_overflow;				// to determine if SP > 4095
wire is_stack_underflow;			// to determine if SP < 2047
wire is_inValid_instr;				// to determine if instr_opcode > 10 (can't identify instruction)
wire is_division_by_zero;			// if Rsrc = 0 and we do division
wire is_out_of_instr_mem;			// if the jmup address is out of instruction memory boundries
wire is_out_of_data_mem;			// if the data we fetch from the data memory is out of data memory boundries

wire is_exception_from_ID;			// to detect if the exceptio arised from the instruction decode stage
wire is_exception_from_EX;			// to detect if the exceptio arised from the instruction execute stage
wire is_exception_from_MEM;			// to detect if the exceptio arised from the instruction memory stage


/**************************************************************
	creating needed registers (EPC and CAUSE) with their logic
**************************************************************/
reg [31:0] EPC;
reg [2:0] CAUSE;

always@(posedge exception_out, reset)
begin

	if(reset)
	begin
		EPC <= 0;
		CAUSE <= 0;
	end
	
	else if(exception_out)
	begin
		CAUSE <= cause_of_exception;
		EPC <= 	(PC_src == 2'd0)	?	32'd0		:
				(PC_src == 2'd1)	?	PC_ID_in	:
				(PC_src == 2'd2)	?	PC_EXE_in	:
										PC_MEM_in	;
				
	end

end

/**************************************************************
	important assigns
**************************************************************/  
assign is_exception_from_ID = is_inValid_instr;
assign is_exception_from_EX = is_division_by_zero | is_out_of_instr_mem;
assign is_exception_from_MEM = is_stacK_overflow | is_stack_underflow | is_out_of_data_mem;

/*select which value to be stored in the CAUSE*/
assign cause_of_exception = (is_stacK_overflow)		?	3'd1	:
							(is_stack_underflow)	?	3'd2	:
							(is_inValid_instr)		?	3'd3	:
							(is_division_by_zero)	?	3'd4	:
							(is_out_of_instr_mem)	?	3'd5	:
							(is_out_of_data_mem)	?	3'd6	:
														3'd0	;
							
/*select which PC to store in the EPC*/
assign PC_src = (is_exception_from_ID)	?	2'd1	:
				(is_exception_from_EX)	?	2'd2	:
				(is_exception_from_MEM)	?	2'd3	:
											2'd0	;

/**************************************************************
	detection of the eception type if present
**************************************************************/  
assign is_stacK_overflow = (SP_MEM_in > 32'd4095);		// to determine if SP > 4095 (upper boundry)
assign is_stack_underflow = (SP_MEM_in < 32'd2047);		// to determine if SP < 2047 (lower boundry)
assign is_inValid_instr = (instrOpCode_in > 4'd10);		// to determine if instr_opcode > 10 (can't identify instruction)
assign is_division_by_zero = (Rsrc_val_EX_in == 16'd0 && ALU_OP_in == 4'd10);		// if Rsrc = 0 and we do division (division by zero)
assign is_out_of_instr_mem = (jmp_addr_EX_in > 32'd1048575 && is_jmp_EX_in); 		// if the jmup address is out of instruction memory boundries
assign is_out_of_data_mem = (Rsrc_val_Mem_in > 16'd4095 && (mem_read_MEM_in | mem_write_MEM_in)); // if the data we fetch from the data memory is out of data memory boundries
 
 
/**************************************************************
	assigning the outputs
**************************************************************/  
assign CAUSE_out = CAUSE;
assign EPC_out = EPC;
assign exception_out =  is_stacK_overflow | is_stack_underflow | is_inValid_instr | is_division_by_zero | is_out_of_instr_mem | is_out_of_data_mem;
assign exception_ID_out = is_exception_from_ID;
assign exception_EXE_out = is_exception_from_EX;
assign exception_MEM_out = is_exception_from_MEM;
 
endmodule