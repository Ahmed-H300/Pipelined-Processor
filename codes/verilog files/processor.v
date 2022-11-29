`include "intermediate buffers/EX_MEM.v"
`include "intermediate buffers/ID_EX.v"
`include "intermediate buffers/IF_ID.v"
`include "intermediate buffers/MEM_WB.v"

`include "stages/ID.v"
`include "stages/EX.v"
`include "stages/IF.v"
`include "stages/MEM.v"
`include "stages/WB.v"



/*this is our top module which is our processor*/
module processor(EPC, interrupt, reset, clk);

/*this is exception program counter that will hold the address of the malfunction instruction*/
output wire [31:0] EPC;

/*this is the reset singal which zeros all the resets except for PC and SP that will hold special value*/
input wire reset;

/*this is the clk that's taken as input to the processor and that's really what makes the processor run*/
input wire clk;

/*this is the interrupt signal that's taken as input to the processor and it makes the prcoessor goes into interrupt handler routine*/
input wire interrupt;



/**************************************************************
	immediate wires for the IF stage
**************************************************************/

/*inputs*/
wire exception_IF;
wire SET_INT_IF;
wire pop_pc_IF;
wire [31:0] PC_popedValue_IF;
wire jmp_sgn_IF;
wire [31:0] PC_jmpValue_IF;
wire stall;

/*outputs*/
wire [31:0] PC_IF;
wire [15:0] instruction_IF;
wire [15:0] Data_IF;
wire INT_IF;


/**************************************************************
	immediate wires for the IF_ID buffer
**************************************************************/

/*inputs*/

/*outputs*/

/**************************************************************
	immediate wires for the ID stage
**************************************************************/

/*inputs*/

/*outputs*/

/**************************************************************
	immediate wires for the ID_EX buffer
**************************************************************/

/*inputs*/

/*outputs*/

/**************************************************************
	immediate wires for the EX stage
**************************************************************/

/*inputs*/

/*outputs*/

/**************************************************************
	immediate wires for the EX_MEM buffer
**************************************************************/

/*inputs*/

/*outputs*/

/**************************************************************
	immediate wires for the MEM stage
**************************************************************/

/*inputs*/

/*outputs*/

/**************************************************************
	immediate wires for the MEM_WB buffer
**************************************************************/

/*inputs*/

/*outputs*/

/**************************************************************
	immediate wires for the WB stage
**************************************************************/

/*inputs*/

/*outputs*/


/**************************************************************
	connecting the modules(stages) together
**************************************************************/

IF instr_fetch(.PC_IF_out(PC_IF), .instruction(instruction_IF), .Data(Data_IF), .INT(INT_IF), .clk(clk), .reset(reset), .interrupt(interrupt), .exception(exception_IF),
				.SET_INT(SET_INT_IF), .pop_pc(pop_pc_IF), .PC_popedValue(PC_popedValue_IF), .jmp_sgn(jmp_sgn_IF), .PC_jmpValue(PC_jmpValue_IF), .stall(stall));




endmodule