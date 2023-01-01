`include "../utils/reg.v"
`include "../utils/mem.v"

/*this is the stage of fetching the instruction*/
module IF(PC_IF_out, instruction, Data, INT, clk, reset, interrupt, exception, SET_INT, pop_pc, PC_popedValue, PC_IF_ID_in, jmp_sgn, PC_jmpValue, stall);

/*this is the program counter of the current executing address*/
output wire [31:0] PC_IF_out;

/*this is the fetched instruction from the instruction memory*/
output wire [15:0] instruction;

/*this is the immediate value incase of I_type instrutions*/
output wire [15:0] Data;

/*this is the interrupt bit in case interrupt signal happened*/
output wire INT;

/*this is the interrupt coming from the outer world*/
input wire interrupt;

/*this is the clk that derives the cpu*/
input wire clk;

/*this is the reset signal that does reseting sequence*/
input wire reset;

/*this is the signal that indicates the arrival of exception signal*/ 	
input wire exception;

/*this is the interrupt signal comming due to the command SET_INT*/
input wire SET_INT;

/*this is the signal that indicates poping the PC value*/
input wire pop_pc;

/*this is the PC value which is just got popped*/
input [31:0] PC_popedValue;

/*this is the signal that arrises due to happening of jmp*/
input wire jmp_sgn;

/*this is stall signal that will make PC holds its value*/
input wire stall;

/*this is the value of the new PC when preforming jumping*/
input wire [31:0] PC_jmpValue;

/*this is the value of the PC from the buffer used for SET_INT command execution*/
input wire [31:0] PC_IF_ID_in;

/**************************************************************
	1 bit regs in this stage
**************************************************************/

/*this is the interrupt register to make the interrupt active for only one cycle*/
reg INT_reg;

/*this is the reset register to make the reset active for only one cycle*/
reg RESET_reg;

/*this is the jmp signal register to make the signal active for only one cycle*/
reg JMP_SGN_reg;

/**************************************************************
	immediate wires to make the code cleaner
**************************************************************/
wire [31:0] PC_out;
wire [31:0] PC_in;
wire [31:0] PC_addedByOne;
wire [15:0] instr;
wire [15:0] tempRegOut;
wire [3:0] inst_opcode;
wire is_Itype;
wire masterOut;
wire slaveOut;
wire do_interruptRoutine;
wire do_reset;

/**************************************************************
	important assigns
**************************************************************/
assign PC_addedByOne = PC_out + 1;
assign inst_opcode = {4{!masterOut}} & instr[15:12] & {4{!INT_reg}};

assign PC_in =  (RESET_reg)					?	32'd32			:
				(INT_reg)					?	32'd0			:
				(pop_pc)					?	PC_popedValue	:
				(JMP_SGN_reg)				?	PC_jmpValue		:
												PC_addedByOne	;

assign instruction = 	(masterOut | INT_reg | JMP_SGN_reg) 	?	16'd0			:
						(slaveOut)								?	tempRegOut		:
																	instr			;

assign Data = instr;
assign INT = INT_reg;
assign PC_IF_out = PC_addedByOne;//(SET_INT)	?	PC_IF_ID_in	:	PC_addedByOne;
assign do_interruptRoutine = interrupt | SET_INT;
assign do_reset = exception | reset;

/**************************************************************
	creating needed modules
**************************************************************/

PC pc(.PC_out(PC_out), .PC_in(PC_in), .clk(clk), .stall(stall & (!masterOut)));
memory #(20'b1111_1111_1111_1111_1111) instr_mem(.data_out(instr), .reset(1'b0), .address(PC_out), .data_in(16'd0), .mem_read(1'd1), .mem_write(1'd0), .clk(clk));
I_typeDetectionUnit ItypeDetectionUnit(.is_I_type(is_Itype), .instr_opcode(inst_opcode));
masterSlaveReg stateMachine(.masterOut(masterOut), .slaveOut(slaveOut), .masterIn(is_Itype), .clk(clk), .reset(reset | do_interruptRoutine | pop_pc | JMP_SGN_reg));
Reg #(16) tempReg(.out_data(tempRegOut), .reset(reset), .set(1'b0), .clk(is_Itype), .in_data(instr), .flush(1'b0), .clr(1'b0), .stall(1'b0));


/**************************************************************
	logic for 1 bit regs
**************************************************************/
always@(negedge clk, do_interruptRoutine)
begin
	if(do_interruptRoutine)
		INT_reg <= 1;
	else if(!clk & !stall)
		INT_reg <= 0;
	else
		INT_reg <= INT_reg;
end

always@(negedge clk, do_reset)
begin
	if(do_reset)
		RESET_reg <= 1;
	else if(!clk & !stall)
		RESET_reg <= 0;
	else
		RESET_reg <= RESET_reg;
end


always@(negedge clk, jmp_sgn)
begin
	if(jmp_sgn)
		JMP_SGN_reg <= 1;
	else if(!clk)
		JMP_SGN_reg <= 0;
	else
		JMP_SGN_reg <= JMP_SGN_reg;
end

endmodule


/*this is the program counter module*/
module PC(PC_out, PC_in, clk, stall);

/*this is the new program counter value*/
output wire [31:0] PC_out; 

/*this is the value to change PC with it*/
input wire [31:0] PC_in;

/*this is the clk that will make PC work*/
input wire clk;

/*this is stall signal with will make PC not change its value if stall signal came*/
input wire stall;

/*this is actually our reg that holds program counter*/
reg [31:0] programCounter;

/*important assigns*/
assign PC_out = programCounter;

/*this is the logic of this module*/
always @(negedge clk)
begin 
	if(!stall)
		programCounter <= PC_in;
	else
		programCounter <= programCounter;
end

endmodule




/*this module detects if the fetched instruction is I_type or not*/
module I_typeDetectionUnit(is_I_type, instr_opcode);

/*this is output signal that will say if the incoming instruction is I type or not*/
output wire is_I_type;

/*this is the opcode of the instruction where if the opcode = 8 then it's I type*/
input wire [3:0] instr_opcode;

/*the actual logic*/
assign is_I_type =  (instr_opcode == 4'd8) ? 1'b1 : 1'b0;

endmodule




/*used in the state machine as in the schematic to delay for one clock cycle*/
module masterSlaveReg(masterOut, slaveOut, masterIn, clk, reset);

/*this is the value that the master reg holds*/
output wire masterOut;

/*this is the value that the slave reg holds*/
output wire slaveOut;

/*this is the input to the master reg*/
input wire masterIn;

/*this is clk that dervies the regs*/
input wire clk;

/*this is the reset signal that zeros out the 2 regs*/
input wire reset;

/*this is actually the master register*/
reg masterReg;

/*this is actually the slave reg*/
reg slaveReg;

/*important assigns*/
assign masterOut = masterReg;
assign slaveOut = slaveReg;

/*actual logic in the circuit*/
always @(clk, posedge reset)
begin 
	if(reset)
	begin 
		masterReg <= 0;
		slaveReg <= 0;
	end
	else if(!clk)
		slaveReg <= masterReg;
	else if(clk)
		masterReg <= masterIn;
	else	// impossible state
	begin
		masterReg <= masterReg;
		slaveReg <= slaveReg;
	end

end

endmodule