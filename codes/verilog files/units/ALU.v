/*this is the arithmetic logic unit that's capable of dowing arithmetic operations*/
module ALU(resultLowerWord, resultUpperWord, CF_out, NF_out, ZF_out, OVF_out, Rdst, Rsrc, ALU_OP, ZF_in, NF_in, CF_in, OVF_in);

/*this is the lower 16 bits result of selected operation where total size of result = 32 (due to multiplication)*/
output wire [15:0] resultLowerWord;

/*this is the upper 16 bits result of selected operation where total size of result = 32 (due to multiplication)*/
output wire [15:0] resultUpperWord;

/*this is the result Carry flag of the current operation, if not changed pass the original value*/
output wire CF_out;

/*this is the result Zero flag of the current operation, if not changed pass the original value*/
output wire ZF_out;

/*this is the result Negative flag of the current operation, if not changed pass the original value*/
output wire NF_out;

/*this is the result overflow flag of the current operation, if not changed pass the original value*/
output wire OVF_out;

/*this is the value of the 1st operand which is the target or destination*/
input wire [15:0] Rdst;

/*this is the value of the 2nd operand which is the source*/
input wire [15:0] Rsrc;

/*this is the desired ALU operation to be taken on Rdst and Rsrc*/
input wire [3:0] ALU_OP;

/*this is the original zero flag value taken from the CCR register*/
input wire ZF_in;

/*this is the original negative flag value taken from the CCR register*/
input wire NF_in;

/*this is the original carry flag value taken from the CCR register*/
input wire CF_in;

/*this is the original overflow flag value taken from the CCR register*/
input wire OVF_in;

/**************************************************************
	temp wire to make the code looks clean
**************************************************************/

// inputs to the operation circuits
wire [15:0] ADD_Rdst;		// this is the first input to the ADD circuit
wire [15:0] ADD_Rsrc;		// this is the second input to the ADD circuit
wire [15:0] SUB_Rdst;		// this is the first input to the SUB circuit
wire [15:0] SUB_Rsrc;		// this is the second input to the SUB circuit
wire [15:0] INC_Rdst;		// this is the first input to the INC circuit
wire [15:0] INC_Rsrc;		// this is the second input to the INC circuit	-> (NOT_USED)
wire [15:0] DEC_Rdst;		// this is the first input to the DEC circuit
wire [15:0] DEC_Rsrc;		// this is the second input to the DEC circuit 	-> (NOT_USED)
wire [15:0] AND_Rdst;		// this is the first input to the AND circuit
wire [15:0] AND_Rsrc;		// this is the second input to the AND circuit
wire [15:0] OR_Rdst;		// this is the first input to the OR circuit
wire [15:0] OR_Rsrc;		// this is the second input to the OR circuit
wire [15:0] NOT_Rdst;		// this is the first input to the NOT circuit
wire [15:0] NOT_Rsrc;		// this is the second input to the NOT circuit	-> (NOT_USED)
wire [15:0] SHL_Rdst;		// this is the first input to the SHL circuit
wire [15:0] SHL_Rsrc;		// this is the second input to the SHL circuit
wire [15:0] SHR_Rdst;		// this is the first input to the SHR circuit
wire [15:0] SHR_Rsrc;		// this is the second input to the SHR circuit
wire [15:0] MUL_Rdst;		// this is the first input to the MUL circuit
wire [15:0] MUL_Rsrc;		// this is the second input to the MUL circuit
wire [15:0] DIV_Rdst;		// this is the first input to the DIV circuit
wire [15:0] DIV_Rsrc;		// this is the second input to the DIV circuit
wire [15:0] MOV_Rdst;		// this is the first input to the MOV circuit	-> (NOT_USED)
wire [15:0] MOV_Rsrc;		// this is the second input to the MOV circuit

// outputs from the operation circuit
wire [15:0] ADD_RES;		// this is the result of addition
wire [15:0] SUB_RES;		// this is the result of subtraction
wire [15:0] INC_RES;		// this is the result of incremental
wire [15:0] DEC_RES;		// this is the result of decremental
wire [15:0] AND_RES;		// this is the result of bitwise anding
wire [15:0] OR_RES;			// this is the result of bitwise oring
wire [15:0] NOT_RES;		// this is the result of bitwise negatation
wire [15:0] SHL_RES;		// this is the result of logical shift left
wire [15:0] SHR_RES;		// this is the result of logical shifr right
wire [15:0] MUL_RES_high;	// this is the result of upper 16 bits of multiplcation
wire [15:0] MUL_RES_low;	// this is the result of lower 16 bits of multiplcation
wire [15:0] DIV_RES;		// this is the result of division
wire [15:0] MOV_RES;		// this is the result of moving

//output carry flags from the operation circuit
wire ADD_CF;				// this is the carry flag resulted from addition
wire SUB_CF;				// this is the carry flag resulted from subtraction
wire INC_CF;				// this is the carry flag resulted from incremental
wire DEC_CF;				// this is the carry flag resulted from decremental
wire SHL_CF;				// this is the carry flag resulted from logical shift left
wire SHR_CF;				// this is the carry flag resulted from logical shifr right

//output zero flags from the operation circuit
wire ADD_ZF;				// this is the zero flag resulted from addition
wire SUB_ZF;				// this is the zero flag resulted from subtraction
wire INC_ZF;				// this is the zero flag resulted from incremental
wire DEC_ZF;				// this is the zero flag resulted from decremental
wire AND_ZF;				// this is the zero flag resulted from bitwise anding
wire OR_ZF;					// this is the zero flag resulted from bitwise oring
wire NOT_ZF;				// this is the zero flag resulted from bitwise negatation
wire SHL_ZF;				// this is the zero flag resulted from logical shift left
wire SHR_ZF;				// this is the zero flag resulted from logical shifr right
wire MUL_ZF;				// this is the zero flag resulted from multiplcation
wire DIV_ZF;				// this is the zero flag resulted from division

//output negative flags from the operation circuit
wire ADD_NF;				// this is the negative flag resulted from addition
wire SUB_NF;				// this is the negative flag resulted from subtraction
wire INC_NF;				// this is the negative flag resulted from incremental
wire DEC_NF;				// this is the negative flag resulted from decremental
wire AND_NF;				// this is the negative flag resulted from bitwise anding
wire OR_NF;					// this is the negative flag resulted from bitwise oring
wire NOT_NF;				// this is the negative flag resulted from bitwise negatation
wire SHL_NF;				// this is the negative flag resulted from logical shift left
wire SHR_NF;				// this is the negative flag resulted from logical shifr right
wire MUL_NF;				// this is the negative flag resulted from multiplcation
wire DIV_NF;				// this is the negative flag resulted from division

//general overflow equation
wire OVF_generalTempRes;
wire OVF_multiplicationCase;
   
assign OVF_tempRes = resultLowerWord[15] ^ Rdst[0] & resultLowerWord[15] ^ Rsrc[0]; // overflow happens when the result sign bit is different from both the 2 inputs sign bits
assign OVF_multiplicationCase = resultUpperWord[15] ^ Rdst[0] & resultUpperWord[15] ^ Rsrc[0]; // overflow happens when the result sign bit is different from both the 2 inputs sign bits

/*
		ALU_OPERATIONS (ALU_OP):
		---------------
		- 0 ADD
		- 1 SUB
		- 2 INC
		- 3 DEC
		- 4 AND
		- 5 OR
		- 6 NOT
		- 7 SHL
		- 8 SHR
		- 9 MUL
		- 10 DIV
		- 11 MOV
*/



/**************************************************************
	demultiplixing the inputs
**************************************************************/
assign {ADD_Rdst, SUB_Rdst, INC_Rdst, DEC_Rdst, AND_Rdst, OR_Rdst, NOT_Rdst, SHL_Rdst, SHR_Rdst, MUL_Rdst, DIV_Rdst, MOV_Rdst} = 
						(ALU_OP == 4'd0) 	? 	{Rdst, 16'd0, 16'd0, 16'd0, 16'd0, 16'd0, 16'd0, 16'd0, 16'd0, 16'd0, 16'd0, 16'd0} :
						(ALU_OP == 4'd1) 	? 	{16'd0, Rdst, 16'd0, 16'd0, 16'd0, 16'd0, 16'd0, 16'd0, 16'd0, 16'd0, 16'd0, 16'd0} :
						(ALU_OP == 4'd2) 	? 	{16'd0, 16'd0, Rdst, 16'd0, 16'd0, 16'd0, 16'd0, 16'd0, 16'd0, 16'd0, 16'd0, 16'd0} :
						(ALU_OP == 4'd3) 	? 	{16'd0, 16'd0, 16'd0, Rdst, 16'd0, 16'd0, 16'd0, 16'd0, 16'd0, 16'd0, 16'd0, 16'd0} :
						(ALU_OP == 4'd4) 	? 	{16'd0, 16'd0, 16'd0, 16'd0, Rdst, 16'd0, 16'd0, 16'd0, 16'd0, 16'd0, 16'd0, 16'd0} :
						(ALU_OP == 4'd5) 	? 	{16'd0, 16'd0, 16'd0, 16'd0, 16'd0, Rdst, 16'd0, 16'd0, 16'd0, 16'd0, 16'd0, 16'd0} :
						(ALU_OP == 4'd6) 	? 	{16'd0, 16'd0, 16'd0, 16'd0, 16'd0, 16'd0, Rdst, 16'd0, 16'd0, 16'd0, 16'd0, 16'd0} :
						(ALU_OP == 4'd7) 	? 	{16'd0, 16'd0, 16'd0, 16'd0, 16'd0, 16'd0, 16'd0, Rdst, 16'd0, 16'd0, 16'd0, 16'd0} :
						(ALU_OP == 4'd8) 	? 	{16'd0, 16'd0, 16'd0, 16'd0, 16'd0, 16'd0, 16'd0, 16'd0, Rdst, 16'd0, 16'd0, 16'd0} :
						(ALU_OP == 4'd9) 	? 	{16'd0, 16'd0, 16'd0, 16'd0, 16'd0, 16'd0, 16'd0, 16'd0, 16'd0, Rdst, 16'd0, 16'd0} :
						(ALU_OP == 4'd10) 	? 	{16'd0, 16'd0, 16'd0, 16'd0, 16'd0, 16'd0, 16'd0, 16'd0, 16'd0, 16'd0, Rdst, 16'd0} :
												{16'd0, 16'd0, 16'd0, 16'd0, 16'd0, 16'd0, 16'd0, 16'd0, 16'd0, 16'd0, 16'd0, Rdst} ;
												
												
assign {ADD_Rsrc, SUB_Rsrc, INC_Rsrc, DEC_Rsrc, AND_Rsrc, OR_Rsrc, NOT_Rsrc, SHL_Rsrc, SHR_Rsrc, MUL_Rsrc, DIV_Rsrc, MOV_Rsrc} = 
						(ALU_OP == 4'd0) 	? 	{Rsrc, 16'd0, 16'd0, 16'd0, 16'd0, 16'd0, 16'd0, 16'd0, 16'd0, 16'd0, 16'd0, 16'd0} :
						(ALU_OP == 4'd1) 	? 	{16'd0, Rsrc, 16'd0, 16'd0, 16'd0, 16'd0, 16'd0, 16'd0, 16'd0, 16'd0, 16'd0, 16'd0} :
						(ALU_OP == 4'd2) 	? 	{16'd0, 16'd0, Rsrc, 16'd0, 16'd0, 16'd0, 16'd0, 16'd0, 16'd0, 16'd0, 16'd0, 16'd0} :
						(ALU_OP == 4'd3) 	? 	{16'd0, 16'd0, 16'd0, Rsrc, 16'd0, 16'd0, 16'd0, 16'd0, 16'd0, 16'd0, 16'd0, 16'd0} :
						(ALU_OP == 4'd4) 	? 	{16'd0, 16'd0, 16'd0, 16'd0, Rsrc, 16'd0, 16'd0, 16'd0, 16'd0, 16'd0, 16'd0, 16'd0} :
						(ALU_OP == 4'd5) 	? 	{16'd0, 16'd0, 16'd0, 16'd0, 16'd0, Rsrc, 16'd0, 16'd0, 16'd0, 16'd0, 16'd0, 16'd0} :
						(ALU_OP == 4'd6) 	? 	{16'd0, 16'd0, 16'd0, 16'd0, 16'd0, 16'd0, Rsrc, 16'd0, 16'd0, 16'd0, 16'd0, 16'd0} :
						(ALU_OP == 4'd7) 	? 	{16'd0, 16'd0, 16'd0, 16'd0, 16'd0, 16'd0, 16'd0, Rsrc, 16'd0, 16'd0, 16'd0, 16'd0} :
						(ALU_OP == 4'd8) 	? 	{16'd0, 16'd0, 16'd0, 16'd0, 16'd0, 16'd0, 16'd0, 16'd0, Rsrc, 16'd0, 16'd0, 16'd0} :
						(ALU_OP == 4'd9) 	? 	{16'd0, 16'd0, 16'd0, 16'd0, 16'd0, 16'd0, 16'd0, 16'd0, 16'd0, Rsrc, 16'd0, 16'd0} :
						(ALU_OP == 4'd10) 	? 	{16'd0, 16'd0, 16'd0, 16'd0, 16'd0, 16'd0, 16'd0, 16'd0, 16'd0, 16'd0, Rsrc, 16'd0} :
												{16'd0, 16'd0, 16'd0, 16'd0, 16'd0, 16'd0, 16'd0, 16'd0, 16'd0, 16'd0, 16'd0, Rsrc} ;
												
												
/**************************************************************
	preforming the operation on the inputs
**************************************************************/		

// ADD										
assign {ADD_CF, ADD_RES} = ADD_Rdst + ADD_Rsrc;
assign ADD_NF = ADD_RES[15];
assign ADD_ZF = (ADD_RES == 16'd0);

// SUB
assign {SUB_CF, SUB_RES} = SUB_Rdst - SUB_Rsrc;
assign SUB_NF = SUB_RES[15];
assign SUB_ZF = (SUB_RES == 16'd0);											
						
// INC
assign {INC_CF, INC_RES} = INC_Rdst + 1;
assign INC_NF = INC_RES[15];
assign INC_ZF = (INC_RES == 16'd0);	

// DEC
assign {DEC_CF, DEC_RES} = DEC_Rdst - 1;
assign DEC_NF = DEC_RES[15];
assign DEC_ZF = (DEC_RES == 16'd0);		

// AND
assign AND_RES = AND_Rdst & AND_Rsrc;						
assign AND_NF = AND_RES[15];
assign AND_ZF = (AND_RES == 16'd0);		

// OR
assign OR_RES = OR_Rdst | OR_Rsrc;						
assign OR_NF = OR_RES[15];
assign OR_ZF = (OR_RES == 16'd0);	

// NOT
assign NOT_RES = ~NOT_Rdst;						
assign NOT_NF = NOT_RES[15];
assign NOT_ZF = (NOT_RES == 16'd0);		

// SHL
assign {SHL_CF, SHL_RES} = SHL_Rdst << SHL_Rsrc;						
assign SHL_NF = SHL_RES[15];
assign SHL_ZF = (SHL_RES == 16'd0);			
		
// SHR
assign {SHR_RES, SHR_CF} = SHR_Rdst >> SHR_Rsrc;						
assign SHR_NF = SHR_RES[15];
assign SHR_ZF = (SHR_RES == 16'd0);	

// MUL
assign {MUL_RES_high, MUL_RES_low} = MUL_Rdst * MUL_Rsrc;						
assign MUL_NF = MUL_RES_high[15];
assign MUL_ZF = ({MUL_RES_high, MUL_RES_low} == 8'd0);	

// DIV
assign DIV_RES = DIV_Rdst /  DIV_Rsrc;						
assign DIV_NF = DIV_RES[15];
assign DIV_ZF = (DIV_RES == 16'd0);	

// MOV
assign MOV_RES = MOV_Rsrc;	



/**************************************************************
	multiplixing the results
**************************************************************/
assign resultLowerWord = 	(ALU_OP == 4'd0)	?	ADD_RES	:
							(ALU_OP == 4'd1)	?	SUB_RES	:
							(ALU_OP == 4'd2)	?	INC_RES	:
							(ALU_OP == 4'd3)	?	DEC_RES	:
							(ALU_OP == 4'd4)	?	AND_RES	:
							(ALU_OP == 4'd5)	?	OR_RES	:
							(ALU_OP == 4'd6)	?	NOT_RES	:
							(ALU_OP == 4'd7)	?	SHL_RES	:
							(ALU_OP == 4'd8)	?	SHR_RES	:
							(ALU_OP == 4'd9)	?	MUL_RES_low	:
							(ALU_OP == 4'd10)	?	DIV_RES	:
													MOV_RES	;
							
							
assign CF_out = 			(ALU_OP == 4'd0)	?	ADD_CF	:
							(ALU_OP == 4'd1)	?	SUB_CF	:
							(ALU_OP == 4'd2)	?	INC_CF	:
							(ALU_OP == 4'd3)	?	DEC_CF	:
							(ALU_OP == 4'd4)	?	CF_in	:
							(ALU_OP == 4'd5)	?	CF_in	:
							(ALU_OP == 4'd6)	?	CF_in	:
							(ALU_OP == 4'd7)	?	SHL_CF	:
							(ALU_OP == 4'd8)	?	SHR_CF	:
							(ALU_OP == 4'd9)	?	CF_in	:
							(ALU_OP == 4'd10)	?	CF_in	:
													CF_in	;
							
assign NF_out = 			(ALU_OP == 4'd0)	?	ADD_NF	:
							(ALU_OP == 4'd1)	?	SUB_NF	:
							(ALU_OP == 4'd2)	?	INC_NF	:
							(ALU_OP == 4'd3)	?	DEC_NF	:
							(ALU_OP == 4'd4)	?	AND_NF	:
							(ALU_OP == 4'd5)	?	OR_NF	:
							(ALU_OP == 4'd6)	?	NOT_NF	:
							(ALU_OP == 4'd7)	?	SHL_NF	:
							(ALU_OP == 4'd8)	?	SHR_NF	:
							(ALU_OP == 4'd9)	?	MUL_NF	:
							(ALU_OP == 4'd10)	?	DIV_NF	:
													NF_in	;	
		
		
assign ZF_out = 			(ALU_OP == 4'd0)	?	ADD_ZF	:
							(ALU_OP == 4'd1)	?	SUB_ZF	:
							(ALU_OP == 4'd2)	?	INC_ZF	:
							(ALU_OP == 4'd3)	?	DEC_ZF	:
							(ALU_OP == 4'd4)	?	AND_ZF	:
							(ALU_OP == 4'd5)	?	OR_ZF	:
							(ALU_OP == 4'd6)	?	NOT_ZF	:
							(ALU_OP == 4'd7)	?	SHL_ZF	:
							(ALU_OP == 4'd8)	?	SHR_ZF	:
							(ALU_OP == 4'd9)	?	MUL_ZF	:
							(ALU_OP == 4'd10)	?	DIV_ZF	:
													ZF_in	;		


assign OVF_out = 			(ALU_OP == 4'd0)	?	OVF_tempRes				:
							(ALU_OP == 4'd1)	?	OVF_tempRes				:
							(ALU_OP == 4'd2)	?	OVF_tempRes				:
							(ALU_OP == 4'd3)	?	OVF_tempRes				:
							(ALU_OP == 4'd4)	?	OVF_tempRes				:
							(ALU_OP == 4'd5)	?	OVF_tempRes				:
							(ALU_OP == 4'd6)	?	OVF_tempRes				:
							(ALU_OP == 4'd7)	?	OVF_tempRes				:
							(ALU_OP == 4'd8)	?	OVF_tempRes				:
							(ALU_OP == 4'd9)	?	OVF_multiplicationCase	:
							(ALU_OP == 4'd10)	?	OVF_tempRes				:
													OVF_in	;		
													

// this is used in multiplication only, otherwise the value will be 0
assign resultUpperWord = MUL_RES_high;
		
endmodule