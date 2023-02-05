# Objective

make a 5-stage-pipelined-prpocessor which looks like MIPS somehow...    

*assume half word = 16 bit and thee width of the bus is 16 bit so we cann't transfer 32 bit at one time* 

the interrupt code handler is in addresses from *0 to 31*

there are 4 memories in our processor where every memory is 16 bits width :

| Memory Name | Purpose | Size | Stage|
|-------------|---------|------|------|
| instruction memory | holds the instruction to be executed by the processor | 2<sup>20</sup> half world |IF stage| 
| data memory | holds any data like if we said `int x = 10;` then `x` will be stored in data memory | 2<sup>16</sup> half world | MEM stage|
| port in memory | holds the Input data from external world | 2<sup>4</sup> half world | MEM stage|
| port out memory | holds the output data to external world | 2<sup>4</sup> half world | MEM stage|

and we had many registers for example:

| register name | purpose | size | stage|
|---------------|---------|------|------|
| PC | this is the program counter that holds the address of the next instruction to be executed | 32 bit | IF stage |
| SP | this is stack pointer which acts stack pointer (empty ascending) and base address is 2047 | 32 bit | MEM stage |
| EPC | exception program counter which holds the address of malfunctioned instruction | 32 bit | ----- |
| CAUSE | holds the number representing reason of exception whether it's stack overflow/underflow, .... | 4 bit | ----- |
| reg file | this is the register file which contains 8 general purpose registers | (8 * 16) bit | ID stage |
| CCR | this is the register that holds the flags (OVF, NF, ZF, CF) needed for the processor to operate | 4 bit | EX stage|


---
# Major Units in the processors 

we have 7 major units in our processor which are is follow :

- **ALU** (arithmetic logical unit) : this unit is responsible for preforming some logical operations like:     
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
		- 12 MOD    

- **CU** (control unit) : this unit is responsible for producing all needed signals for the processor to act , all signals produced can be found [here](https://github.com/Ahmed-H300/Pipelined-Processor/blob/main/ISA/signalsV2.txt) and they are as follow :

        control unit signals: 32 signals	-> active high		// there is a decoding circuit in the fetch stage to handle the LDM command

        -> RegLow_write 	-> 1 bit (reg_dst1_write_back)
            active in :
                - all of R_type instructions
                - m_type in case of IN and LDD
                - s_type in case of POP and PC != 1
                - I type in case of LDM

        -> RegHigh_write2	-> 1 bit (reg_dst2_write_back)	
            active in :
                - multiplication command only

        -> ALU_OP		-> 4 bits
            values:
                - 0 (ADD) when opcode is 1 and funct is 2
                - 1 (SUB) when opcode is 1 and funct is 3
                - 2 (INC) when opcode is 2 and funct is 2
                - 3 (DEC) when opcode is 2 and funct is 3
                - 4 (AND) when opcode is 3 and funct is 1
                - 5 (OR) when opcode is 3 and funct is 0
                - 6 (NOT) when opcode is 3 and funct is 2
                - 7 (SHL) when opcode is 2 and funct is 0
                - 8 (SHR) when opcode is 2 and funct is 1
                - 9 (MUL) when opcode is 1 and funct is 1
                - 10 (DIV) when opcode is 1 and funct is 0
                - 11 (MOV) when opcode is 3 and funct is 3
                - 12 (MOD) when opcode is 12 and funct is 0
            otherwise:
                - we use the command MOV for any other operation
                        

            
        -> ALU_src1		-> 2 bits		(to select between shmt, Rsrc, data fro, second line in case of LDM)
            values: 
                - 0 : when input to Rsrc in ALU comes from register file (anyother case)
                - 1 : when input to Rsrc in ALU comes from DATA which is 16 input used mostly with LDM command
                - 2 : when input to Rsrc in ALU comes from shmt to do shifting (ALUOP = SHF | SHR)
                

        
        -> MemToReg		-> 1 bit		(to choose the source of Rdst1 is comming from the memory or result of ALU)	
            active in :
                - LDD, POP (where PC = 0 and flags = 0) , IN
                
                
        -> memWrite		-> 1 bit 		(signal to write to the data memory)
            active in :
                - PUSH, STD, CALL #imm , CALL Rdst

        -> memRead		-> 1 bit		(signal to read from the data memory)
            active in :
                - POP, LDD

        -> portWrite		-> 1 bit		(signal to write to the port memory)
            active in : 
                -  OUT

        -> portRead		-> 1 bit		(signal to read from the port memory)
            active in :
                - IN

        -> memType		-> 1 bit		(to select between the port memory and data memory)
            active in :
                - when memRead or memWrite is high 
            

        -> PC_push_pop		-> 1 bit 		(to indication we should pop/push PC)
            active in:
                - using PUSH/POP and PC = 1
                - using CALL

        -> flags_push_pop	-> 1 bit 		(to indication we should pop/push flags)
            active in:
                - using PUSH/POP and flags = 1

        -> JMP_type		-> 2 bit 		(to indicate whether jump on: flag(carry, zero, negative) or unconditional)
            values:
                - 0 when performing unconditional jump
                - 1 when jumping on carry flag
                - 2 when jumping on negative flag
                - 3 when jumping on zero flag

        -> is_jmp		-> 1 bit 		(to indication it's a jump command or not)
            active in:
                - b_type instructions, CALL, I_type except for LDM

        -> JMP_src		-> 1 bit 		(to select whether to jump using immediate value or using register)
            active in:
                - I_type



        -> SET_Z		-> 1 bit 		(sets the zero flag)
            active in:
                - c_type instructions group 1 (SET_Z)

        -> SET_N		-> 1 bit 		(sets the negative flag)
            active in:
                - c_type instructions group 1 (SET_N)

        -> SET_C		-> 1 bit 		(sets the carry flag)
            active in:
                - c_type instructions group 1 (SET_C)

        -> SET_OVF		-> 1 bit 		(sets the interrupt flag)
            active in:
                - c_type instructions group 1 (SET_OVF)


        -> CLR_Z		-> 1 bit 		(clears the zero flag)
            active in:
                - c_type instructions group 0 (CLR_Z) and CLR_FLAGS instruction

        -> CLR_N		-> 1 bit 		(clears the negative flag)
            active in:
                - c_type instructions group 0 (CLR_N) and CLR_FLAGS instruction

        -> CLR_C		-> 1 bit 		(clears the carry flag)
            active in:
                - c_type instructions group 0 (CLR_C) and CLR_FLAGS instruction

        -> CLR_OVF		-> 1 bit 		(clears the interrupt aaflag)
            active in:
                - c_type instructions group 0 (CLR_OVF) and CLR_FLAGS instruction
                - RTI instruction (POP PC, flags)


        -> SP_src		-> 2 bit 		(select whether to keep SP value as it's or decrement it or increment it)
            values :
                - 0	keep the value of SP as it's in case of NO (PUSH/POP, CALL)
                - 1	decrement the value of SP by 1 incase of POP
                - 2 	increment the value of SP by 1 incase of PUSH, CALL

        -> mem_data_src		-> 1 bit 		(select between PUSH PC or Rdst)
            active in:
                - PUSH command, PC | flags = 1
                - CALL

        -> mem_address_src	-> 1 bit 		(select between using address using Rdst and SP)
            acive in :
                - POP/PUSH instructions (s_type)
                - CALL

        -> SETINT : 	-> 1 bit
            active in :
                - opcode = 11

        -> RST :	-> 1 bit
            active in:
                - opcode = 13


- **EDU** (exception detection unit) :  this is the unit that's responsible for exception detection and it works as follows : whenever thers is an exception, the address of the malfunctioned instruction will be stored in **EPC** and a number will be stored in the register called **CAUSE** that represents the reason of the exception where the reason of exception are as follows:

        CAUSE valus:            
            ->	0	:	no error        
            ->	1	:	stack overflow		(mem stage)     
            ->	2	:	stack underflow		(mem stage)         
            ->	3	:	invalid instruction	(decode stage)          
            ->	4	:	Division by zero		(ex stage)          
            ->	5	:	out of memory boundries in instruction memory (ex stage)            
            ->	6	:	out of memory boundries in data memory	(mem stage)     

- **FU1** (first forwarding unit) : this is a forwarding unit that can from MEM stage (ALU-to-ALU) or from WB stage (MEM-to-ALU) to EX stage where the condition of forwarding is as follows:

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

- **FU2** (second forwarding unit) : this is a forwarding unit that can from WB stage (MEM-to-MEM) to MEM stage where the condition of forwarding is as follows:

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


- **HDU** (hazard detection unit) : stalls the processor for only 1 cycle in some special conditions of load-case (not all of load-use-case conditions as many of load-use-case are solved using (MEM-to-MEM) forwarding unit) and the logic of HDU is as follows :

        we will only stall 1 cycle in the following cases:
            case 1:	LDD or OUT
                    then
                    R_type instrucion
            case 2: LDD or OUT
                    then
                    B_type instruction


- **regFile** (register file) : that's the file that holds the our 8 general purpose registers.

---
# Major Stages in the processors

| stage name | main purpose | 
|------------|--------------|
| IF (instruction fetch) stage | fetchs the instruction from the memory and changes PC for interrupt or reset signal|
| ID (instruction decode) stage | decodes the instruction by CU to output needed control signals and contains reg file|
| EX (execute) stage | execute any instruction related to ALU , has the CCR (flags) register, executes jmup instructions|
| MEM (memory) stage | anything related to data memory, stack, port in/out memory|
| WB (write-back) stage | anything related to writing back to the register file | 

---
# How to run our project

1. go to [this directory](https://github.com/Ahmed-H300/Pipelined-Processor/tree/main/codes/scripts_codesTests)
2. if you are on windows machine, then it's recommended to open `git bash` or any other bash that could execute bash scripts
3. if you are on linux machine, just open the terminal
4. run the folllowing command :   
`./make_code <number_of_script_to_be_executed>`
so for example : in the folder called **test codes**, you will find a file called **45_prime_number_calculation.txt** , so in order to execute this code you just write the command `./make_code 45` and the assembler will produce the binary representation of that code and put it in the directory of modelsim work

5. then in modelsim trascript (terminal), just write `do sim.do` and it will execute this code

---
# ISA

|instruction | what it will do| flags affected |
|------------|----------------|----------------|
| DIV Rsrc, Rdst| ${Rdst = \frac{Rdst}{Rsrc}}$| NF, ZF|
| MUL Rds1, Rdst2, Rsrc | {Rdst1, Rdst2} = Rsrc * Rdst1 | NF, ZF |
| ADD Rsrc, Rdst | Rdst = Rdst + Rsrc | NF, ZF, CF, OVF|
| SUB Rsrc, Rdst | Rdst = Rdst - Rsrc | NF, ZF, CF, oVF|
| SHL Rdst, #imm | Rdst = Rdst << #imm | NF, ZF, CF, OVF|
| SHR Rdst, #imm | Rdst = Rdst >> #imm | NF, ZF, CF, OVF|
| INC Rdst | Rdst = Rdst + 1 | NF, ZF, CF, OVF|
| DEC Rdst | Rdst = Rdst - 1 | NF, ZF, CF, OVF|
| OR Rsrc, Rdst | Rdst = Rdst \| Rsrc | NF, ZF|
| AND Rsrc, Rdst | Rdst = Rdst & Rsrc | NF, ZF|
| NOT Rdst | Rdst = ~Rdst | NF, ZF, OVF|
| MOV Rsrc, Rdst | Rdst = Rsrc | none|
| MOD Rsrc, Rdst | Rdst = Rdst % Rsrc | NF, ZF|
| JZ Rdst | `if(ZF == 0) then` <br/> PC &larr; [PC + Rdst] <br/> ZF = 0| ZF | 
| JN Rdst | `if(NF == 0) then` <br/> PC &larr; [PC + Rdst] <br/> NF = 0| NF | 
| JC Rdst | `if(CF == 0) then` <br/> PC &larr; [PC + Rdst] <br/> CF = 0| CF | 
| JMP Rdst | PC &larr; [PC + Rdst] | none | 
| CLRZ | ZF &larr; 0 | ZF|
| CLRN | NF &larr; 0 | NF|
| CLRC | CF &larr; 0 | CF|
| CLROVF | OVF &larr; 0 | OVF|
| SETZ | ZF &larr; 1 | ZF|
| SETN | NF &larr; 1 | NF|
| SETC | CF &larr; 1 | CF|
| SETOVF | OVF &larr; 1 | OVF|
| PUSH Rdst | MEM[SP] = Rdst <br/> SP++ | none|
| PUSH PC | MEM[SP] = PC[15:0] <br/> MEM[SP+1]={flags,PC[27:16]} <br/> SP += 2 | none|
| PUSH PC_FLAGS | MEM[SP] = PC[15:0] <br/> MEM[SP+1]={flags,PC[27:16]} <br/> SP += 2 | none|
| POP Rdst | Rdst = MEM[SP] <br/> SP-- | none|
| POP PC | {dummy,PC[27:16]} = MEM[SP] <br/> PC[15:0] = MEM[SP-1] <br/>  SP -= 2 | none|
| POP PC_FLAGS | {flags,PC[27:16]} = MEM[SP] <br/> PC[15:0] = MEM[SP-1] <br/>  SP -= 2 | CF, ZF, OVF, NF|
| OUT Rdst, #port_num | port_out[#port_num] = Rdst | none |
| IN Rdst, #port_num | Rdst = port_in[#port_num] | none |
| LDD Rsrc, Rdst | Rdst = MEM[Rsrc] | none|
| STD Rsrc, Rdst | MEM[Rdst] = Rsrc | none|
| LDM Rdst, #imm | Rdst = #imm | none |
| CALL #imm | MEM[SP] = PC[15:0] <br/> MEM[SP+1] = {flags,PC[27:0]} <br/> SP += 2 <br/> PC = #imm| none|
| JMP #imm | PC = #imm| none|
| JZ #imm | `if(ZF == 0) then` <br/> PC &larr; #imm <br/> ZF = 0| ZF | 
| JN Rdst | `if(NF == 0) then` <br/> PC &larr; #imm <br/> NF = 0| NF | 
| JC Rdst | `if(CF == 0) then` <br/> PC &larr; #imm <br/> CF = 0| CF | 
| CLR_FLAGS | ZF = 0 &larr; CF = 0 &larr; NF = 0 &larr; OVF = 0 | ZF, CF, ZF, OVF| 
| NOP | do nothing | none |
| SETINT | same as `Interrupt` signal but via software | none |
| RST | same as `RESET` signal but via software | CF, NF, ZF, OVF |
| RET | POP PC | none|
| RTI | POP PC_FLAGS | CF, ZF, NF, OVF |
| CALL Rdst | MEM[SP] = PC[15:0] <br/> MEM[SP+1] = {flags,PC[27:0]} <br/> SP += 2 <br/> PC = [PC + #imm] | none|




--- 
# External signals in our processors

| Signal name | function |
|-------------|----------|
| RESET | PC &larr; 2<sup>5</sup> and resets all other memory locations like regFile, port memory, dataMemory, etc...|
| Interrupt | PUSH PC_FLAGS <br/> PC &larr; 0 <br/> note that any instructions in the pipe will be executed before the exection of the interrupt|

---
# Notes

1. the **I_type** instructions are 32 bits in width so it needs 2 clocks cycle to be fetched while other types are only 16 bits so it needs only 1 clock to be fetched , that's why there is a unit called I_type detection unit in the fetch stage  

2. you can find the full detailed design [here](https://github.com/Ahmed-H300/Pipelined-Processor/blob/main/schematics/processorDesign.pdf)

3. we did the design using *KICAD 6.0* , so it's recommended to see our desgin using KiCad and not just a pdf viewer , the project files made by KiCad can be found [here](https://github.com/Ahmed-H300/Pipelined-Processor/tree/main/schematics/processorDesign) 

4. we made the assembler using python and you can found the code of the python script [here](https://github.com/Ahmed-H300/Pipelined-Processor/blob/main/codes/scripts_codesTests/assembler.py)

5. [this directory](https://github.com/Ahmed-H300/Pipelined-Processor/tree/main/codes/modesim_work) is the modelsim project directory to open and verilog codes of our project can be found [here](https://github.com/Ahmed-H300/Pipelined-Processor/tree/main/codes/verilog%20files) where `processor.v` is like our `main`

6. you can find information about our ISA [Here](https://github.com/Ahmed-H300/Pipelined-Processor/tree/main/ISA)

7. in multiplication, we have 2 destination Rdst, while in division it's only 1 Rdst.

8. the default command to be executed in ALU for non-ALU commands is `MOV` command. 

9. comments, putting code in special address, etc... , all of that are features offered by the assembler

10. since PC is 32 bit and only 20 bit of it will be used to access the memory so when pushing PC , we pushed it as follows : {flags, PC[27:0]} , so incase we wanted to pop flags, we can do that easily.

11. we maded (MEM-to-MEM) forwarding to solve some load-use-case problems like `lDD R1, R2` then `STD R1, R3` which only trasnfer data from one place in the memory to another

12. we couldn't execute unconditional jump in the decode stage as it will need extra hardware as we will need a third forwarding unit to forward Rdst from EX or MEM stage to decode stage if there is any dependency for instrctions like `JMP R1`

13. [this directory](https://github.com/Ahmed-H300/Pipelined-Processor/tree/main/codes/verilog%20files/simulation%20files) contains anything related to automated-simulation, memories files.

14. nested interrupts are handled in our processor where if an interrupt arrives while there is another interrupt being executed, we will serve the newly comming interrupt.
