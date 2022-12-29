'''
*************************************************************************

------------------------------ HG Complier ------------------------------

*************************************************************************
'''
# imports
##########################################################################
# for the argumnets
import sys
# for colored printing
from colorama import Fore, Back, Style
# ordered dictionary
from collections import OrderedDict
# replace insensitive
#import re
##########################################################################
# check if a file name is wirtten and check whether an ouput name is given or the default will be used (a.mem)
argumentLenght = len(sys.argv)
if ((argumentLenght != 2) and (argumentLenght != 3)):
    print(Fore.RED + 'Number of argumnet is invalid')
    print(Fore.RED + 'try some thing like: python hgg.py filename.hg (or) python hgg.py filename.hg outputfilename')
    print(Fore.RED + 'hgg is out... see you later')
    print(Style.RESET_ALL)
    exit()
# getting the file name
fileName = sys.argv[1]
# setting the default outputname
fileNameOut = 'a.mem'
# check whether to change the name or not
if (argumentLenght == 3):
    fileNameOut = sys.argv[2]
# compile the file


def getInput(file, arrayISA):
    # loop on line and neglect empty lines
    for line in file:
        if(line.strip()):
            if(';' in line):
                # to delte any commnets form the line
                indexofhash = line.rfind(';')
                line = line[0:indexofhash]
                if(not line.strip()):
                    continue
            # add line to the array
            arrayISA.append(line)
# compile the instructions for range
# first loop for instuctions without label


def CompileOutput(arrayISA, out, start, end):
    reg = {
        'R0': 0b000,
        'R1': 0b001,
        'R2': 0b010,
        'R3': 0b011,
        'R4': 0b100,
        'R5': 0b101,
        'R6': 0b110,
        'R7': 0b111,
        'r0': 0b000,
        'r1': 0b001,
        'r2': 0b010,
        'r3': 0b011,
        'r4': 0b100,
        'r5': 0b101,
        'r6': 0b110,
        'r7': 0b111,
    }
    opCode = {
        'NOP': 0b0000,
        'group0': 0b0001,
        'group1': 0b0010,
        'group2': 0b0011,
        'b_type': 0b0100,
        'c_type': 0b0101,
        's_type': 0b0110,
        'm_type': 0b0111,
        'I_type': 0b1000,
        'CLR_FLAGS': 0b1001,
        'CALL': 0b1010,
        'SETINT': 0b1011,
    }
    func = {
        'funct0': 0b00,
        'funct1': 0b01,
        'funct2': 0b10,
        'funct3': 0b11,
    }
    bits = 16
    rdsShift = 3 * 3
    rds2Shift = 1 * 3
    rsrShift = 2 * 3
    shmtShift = 2
    PCShift = 8
    PC_FlagsShift = 7
    operationShift = 11
    opCodeShift = 3 * 4
    numISA = 0
    currentIP = start
    for line in arrayISA:
        if (currentIP > end or currentIP < start):
            return 'out of bound in writing memory'
        lineOld = line
        line = line.replace(',', ' ')
        line = line.replace('RTI', 'POP PC_Flags')
        line = line.replace('RET', 'POP PC')
        #insensitive_hippo = re.compile(re.escape('hippo'), re.IGNORECASE)
        #insensitive_hippo.sub('giraffe', 'I want a hIPpo for my birthday')
        line = line.split()
        temp = 0b0000000000000000
        if(line[0].casefold() == 'DIV'.casefold()):  # DIV R0, R1   -> R0->src    -> R1-> dst
            if(len(line) == 3):
                op1 = reg.get(line[1], None)
                op2 = reg.get(line[2], None)
                if(op1 == None or op2 == None):
                    return 'Error in ' + lineOld + 'Instruction number:' + str((numISA + 1))
                temp = temp | (opCode['group0'] << opCodeShift) | (
                    op2 << rdsShift) | (op1 << rsrShift) | (func['funct0'])
                out[currentIP] = temp
            else:
                return 'Error in ' + lineOld + 'Instruction number:' + str((numISA + 1))
        # note there is 2 rdes types #MUL R0, R1, R2   -> R0-> src  ->  R1 -> rds -> R2-> rds2
        elif (line[0].casefold() == 'MUL'.casefold()):
            if(len(line) == 4):
                op1 = reg.get(line[1], None)
                op2 = reg.get(line[2], None)
                op3 = reg.get(line[3], None)
                if(op1 == None or op2 == None or op3 == None):
                    return 'Error in ' + lineOld + 'Instruction number:' + str((numISA + 1))
                temp = temp | (opCode['group0'] << opCodeShift) | (op2 << rdsShift) | (
                    op1 << rsrShift) | (op3 << rds2Shift) | (func['funct1'])
                out[currentIP] = temp
            else:
                return 'Error in ' + lineOld + 'Instruction number:' + str((numISA + 1))

        elif (line[0].casefold() == 'ADD'.casefold()):  # like Div
            if(len(line) == 3):
                op1 = reg.get(line[1], None)
                op2 = reg.get(line[2], None)
                if(op1 == None or op2 == None):
                    return 'Error in ' + lineOld + 'Instruction number:' + str((numISA + 1))
                temp = temp | (opCode['group0'] << opCodeShift) | (
                    op2 << rdsShift) | (op1 << rsrShift) | (func['funct2'])
                out[currentIP] = temp
            else:
                return 'Error in ' + lineOld + 'Instruction number:' + str((numISA + 1))
        elif (line[0].casefold() == 'SUB'.casefold()):  # like Div
            if(len(line) == 3):
                op1 = reg.get(line[1], None)
                op2 = reg.get(line[2], None)
                if(op1 == None or op2 == None):
                    return 'Error in ' + lineOld + 'Instruction number:' + str((numISA + 1))
                temp = temp | (opCode['group0'] << opCodeShift) | (
                    op2 << rdsShift) | (op1 << rsrShift) | (func['funct3'])
                out[currentIP] = temp
            else:
                return 'Error in ' + lineOld + 'Instruction number:' + str((numISA + 1))
        # SHL R0, 5    -> R0 -> rds , -> 5 -> shmt
        elif (line[0].casefold() == 'SHL'.casefold()):
            if(len(line) == 3):
                op1 = reg.get(line[1], None)
                if(op1 == None):
                    return 'Error in ' + lineOld + 'Instruction number:' + str((numISA + 1))
                temp = temp | (opCode['group1'] << opCodeShift) | (
                    op1 << rdsShift) | (int(line[2]) << shmtShift) | (func['funct0'])
                out[currentIP] = temp
            else:
                return 'Error in ' + lineOld + 'Instruction number:' + str((numISA + 1))
        elif (line[0].casefold() == 'SHR'.casefold()):  # like SHL
            if(len(line) == 3):
                op1 = reg.get(line[1], None)
                if(op1 == None):
                    return 'Error in ' + lineOld + 'Instruction number:' + str((numISA + 1))
                temp = temp | (opCode['group1'] << opCodeShift) | (
                    op1 << rdsShift) | (int(line[2]) << shmtShift) | (func['funct1'])
                out[currentIP] = temp
            else:
                return 'Error in ' + lineOld + 'Instruction number:' + str((numISA + 1))
        elif (line[0].casefold() == 'INC'.casefold()):  # Inc Rds
            if(len(line) == 2):
                op1 = reg.get(line[1], None)
                if(op1 == None):
                    return 'Error in ' + lineOld + 'Instruction number:' + str((numISA + 1))
                temp = temp | (opCode['group1'] << opCodeShift) | (
                    op1 << rdsShift) | (func['funct2'])
                out[currentIP] = temp
            else:
                return 'Error in ' + lineOld + 'Instruction number:' + str((numISA + 1))
        elif (line[0].casefold() == 'DEC'.casefold()):
            if(len(line) == 2):
                op1 = reg.get(line[1], None)
                if(op1 == None):
                    return 'Error in ' + lineOld + 'Instruction number:' + str((numISA + 1))
                temp = temp | (opCode['group1'] << opCodeShift) | (
                    op1 << rdsShift) | (func['funct3'])
                out[currentIP] = temp
            else:
                return 'Error in ' + lineOld + 'Instruction number:' + str((numISA + 1))
        elif (line[0].casefold() == 'OR'.casefold()):
            if(len(line) == 3):
                op1 = reg.get(line[1], None)
                op2 = reg.get(line[2], None)
                if(op1 == None or op2 == None):
                    return 'Error in ' + lineOld + 'Instruction number:' + str((numISA + 1))
                temp = temp | (opCode['group2'] << opCodeShift) | (
                    op2 << rdsShift) | (op1 << rsrShift) | (func['funct0'])
                out[currentIP] = temp
            else:
                return 'Error in ' + lineOld + 'Instruction number:' + str((numISA + 1))
        elif (line[0].casefold() == 'AND'.casefold()):
            if(len(line) == 3):
                op1 = reg.get(line[1], None)
                op2 = reg.get(line[2], None)
                if(op1 == None or op2 == None):
                    return 'Error in ' + lineOld + 'Instruction number:' + str((numISA + 1))
                temp = temp | (opCode['group2'] << opCodeShift) | (
                    op2 << rdsShift) | (op1 << rsrShift) | (func['funct1'])
                out[currentIP] = temp
            else:
                return 'Error in ' + lineOld + 'Instruction number:' + str((numISA + 1))
        elif (line[0].casefold() == 'NOT'.casefold()):
            if(len(line) == 2):
                op1 = reg.get(line[1], None)
                if(op1 == None):
                    return 'Error in ' + lineOld + 'Instruction number:' + str((numISA + 1))
                temp = temp | (opCode['group2'] << opCodeShift) | (
                    op1 << rdsShift) | (func['funct2'])
                out[currentIP] = temp
            else:
                return 'Error in ' + lineOld + 'Instruction number:' + str((numISA + 1))
        elif (line[0].casefold() == 'MOV'.casefold()):
            if(len(line) == 3):
                op1 = reg.get(line[1], None)
                op2 = reg.get(line[2], None)
                if(op1 == None or op2 == None):
                    return 'Error in ' + lineOld + 'Instruction number:' + str((numISA + 1))
                temp = temp | (opCode['group2'] << opCodeShift) | (
                    op2 << rdsShift) | (op1 << rsrShift) | (func['funct3'])
                out[currentIP] = temp
            else:
                return 'Error in ' + lineOld + 'Instruction number:' + str((numISA + 1))
        elif (line[0].casefold() == 'JZ'.casefold()):  # note there is two types
            if(len(line) == 2):
                op1 = reg.get(line[1], None)
                if(op1 == None):
                    temp = temp | (opCode['I_type'] <<
                                   opCodeShift) | (func['funct5'])
                    out[currentIP] = temp
                    currentIP += 1
                    temp = line[1]
                    labelused.append(line[1])
                    out[currentIP] = temp
                else:
                    temp = temp | (opCode['b_type'] << opCodeShift) | (
                        op1 << rdsShift) | (func['funct0'])
                    out[currentIP] = temp
            else:
                return 'Error in ' + lineOld + 'Instruction number:' + str((numISA + 1))
        elif (line[0].casefold() == 'JN'.casefold()):
            if(len(line) == 2):
                op1 = reg.get(line[1], None)
                if(op1 == None):
                    temp = temp | (opCode['I_type'] <<
                                   opCodeShift) | (func['funct4'])
                    out[currentIP] = temp
                    currentIP += 1
                    temp = line[1]
                    labelused.append(line[1])
                    out[currentIP] = temp
                else:
                    temp = temp | (opCode['b_type'] << opCodeShift) | (
                        op1 << rdsShift) | (func['funct1'])
                    out[currentIP] = temp
            else:
                return 'Error in ' + lineOld + 'Instruction number:' + str((numISA + 1))
        elif (line[0].casefold() == 'JC'.casefold()):
            if(len(line) == 2):
                op1 = reg.get(line[1], None)
                if(op1 == None):
                    temp = temp | (opCode['I_type'] <<
                                   opCodeShift) | (func['funct3'])
                    out[currentIP] = temp
                    currentIP += 1
                    temp = line[1]
                    labelused.append(line[1])
                    out[currentIP] = temp
                else:
                    temp = temp | (opCode['b_type'] << opCodeShift) | (
                        op1 << rdsShift) | (func['funct2'])
                    out[currentIP] = temp
            else:
                return 'Error in ' + lineOld + 'Instruction number:' + str((numISA + 1))
        elif (line[0].casefold() == 'JMP'.casefold()):  # rds and imediate
            if(len(line) == 2):
                op1 = reg.get(line[1], None)
                if(op1 == None):
                    temp = temp | (opCode['I_type'] <<
                                   opCodeShift) | (func['funct2'])
                    out[currentIP] = temp
                    currentIP += 1
                    temp = line[1]
                    labelused.append(line[1])
                    out[currentIP] = temp
                else:
                    temp = temp | (opCode['b_type'] << opCodeShift) | (
                        op1 << rdsShift) | (func['funct3'])
                    out[currentIP] = temp
            else:
                return 'Error in ' + lineOld + 'Instruction number:' + str((numISA + 1))
        elif (line[0].casefold() == 'CLRZ'.casefold()):
            if(len(line) == 1):
                temp = temp | (opCode['c_type'] << opCodeShift) | (
                    0 << operationShift) | (func['funct0'])
                out[currentIP] = temp
            else:
                return 'Error in ' + lineOld + 'Instruction number:' + str((numISA + 1))
        elif (line[0].casefold() == 'CLRN'.casefold()):
            if(len(line) == 1):
                temp = temp | (opCode['c_type'] << opCodeShift) | (
                    0 << operationShift) | (func['funct1'])
                out[currentIP] = temp
            else:
                return 'Error in ' + lineOld + 'Instruction number:' + str((numISA + 1))
        elif (line[0].casefold() == 'CLRC'.casefold()):
            if(len(line) == 1):
                temp = temp | (opCode['c_type'] << opCodeShift) | (
                    0 << operationShift) | (func['funct2'])
                out[currentIP] = temp
            else:
                return 'Error in ' + lineOld + 'Instruction number:' + str((numISA + 1))
        elif (line[0].casefold() == 'CLROVF'.casefold()):
            if(len(line) == 1):
                temp = temp | (opCode['c_type'] << opCodeShift) | (
                    0 << operationShift) | (func['funct3'])
                out[currentIP] = temp
            else:
                return 'Error in ' + lineOld + 'Instruction number:' + str((numISA + 1))
        elif (line[0].casefold() == 'SETZ'.casefold()):
            if(len(line) == 1):
                temp = temp | (opCode['c_type'] << opCodeShift) | (
                    1 << operationShift) | (func['funct0'])
                out[currentIP] = temp
            else:
                return 'Error in ' + lineOld + 'Instruction number:' + str((numISA + 1))
        elif (line[0].casefold() == 'SETN'.casefold()):
            if(len(line) == 1):
                temp = temp | (opCode['c_type'] << opCodeShift) | (
                    1 << operationShift) | (func['funct1'])
                out[currentIP] = temp
            else:
                return 'Error in ' + lineOld + 'Instruction number:' + str((numISA + 1))
        elif (line[0].casefold() == 'SETC'.casefold()):
            if(len(line) == 1):
                temp = temp | (opCode['c_type'] << opCodeShift) | (
                    1 << operationShift) | (func['funct2'])
                out[currentIP] = temp
            else:
                return 'Error in ' + lineOld + 'Instruction number:' + str((numISA + 1))
        elif (line[0].casefold() == 'SETOVF'.casefold()):
            if(len(line) == 1):
                temp = temp | (opCode['c_type'] << opCodeShift) | (
                    1 << operationShift) | (func['funct3'])
                out[currentIP] = temp
            else:
                return 'Error in ' + lineOld + 'Instruction number:' + str((numISA + 1))
        elif (line[0].casefold() == 'PUSH'.casefold()):  # rds pc_flags pc
            if(len(line) == 2):
                op1 = reg.get(line[1], None)
                if(op1 == None):
                    if(line[1].casefold() == 'PC'.casefold()):
                        temp = temp | (opCode['s_type'] << opCodeShift) | (
                            1 << PCShift) | (0 << PC_FlagsShift) | (func['funct0'])
                        out[currentIP] = temp
                    elif (line[1].casefold() == 'PC_Flags'.casefold()):
                        temp = temp | (opCode['s_type'] << opCodeShift) | (
                            1 << PCShift) | (1 << PC_FlagsShift) | (func['funct0'])
                        out[currentIP] = temp
                    else:
                        return 'Error in ' + lineOld + 'Instruction number:' + str((numISA + 1))
                else:
                    temp = temp | (opCode['s_type'] << opCodeShift) | (
                        op1 << rdsShift) | (func['funct0'])
                    out[currentIP] = temp
            else:
                return 'Error in ' + lineOld + 'Instruction number:' + str((numISA + 1))
        elif (line[0].casefold() == 'POP'.casefold()):  # rds pc_flags pc
            if(len(line) == 2):
                op1 = reg.get(line[1], None)
                if(op1 == None):
                    if(line[1].casefold() == 'PC'.casefold()):
                        temp = temp | (opCode['s_type'] << opCodeShift) | (
                            1 << PCShift) | (0 << PC_FlagsShift) | (func['funct1'])
                        out[currentIP] = temp
                    elif (line[1].casefold() == 'PC_Flags'.casefold()):
                        temp = temp | (opCode['s_type'] << opCodeShift) | (
                            1 << PCShift) | (1 << PC_FlagsShift) | (func['funct1'])
                        out[currentIP] = temp
                    else:
                        return 'Error in ' + lineOld + 'Instruction number:' + str((numISA + 1))
                else:
                    temp = temp | (opCode['s_type'] << opCodeShift) | (
                        op1 << rdsShift) | (func['funct1'])
                    out[currentIP] = temp
            else:
                return 'Error in ' + lineOld + 'Instruction number:' + str((numISA + 1))
        elif (line[0].casefold() == 'OUT'.casefold()):  # rds, portnumber
            if(len(line) == 3):
                op1 = reg.get(line[1], None)
                if(op1 == None):
                    return 'Error in ' + lineOld + 'Instruction number:' + str((numISA + 1))
                temp = temp | (opCode['m_type'] << opCodeShift) | (
                    op1 << rdsShift) | (int(line[2]) << shmtShift) | (func['funct0'])
                out[currentIP] = temp
            else:
                return 'Error in ' + lineOld + 'Instruction number:' + str((numISA + 1))
        elif (line[0].casefold() == 'IN'.casefold()):  # rds, portnumber
            if(len(line) == 3):
                op1 = reg.get(line[1], None)
                if(op1 == None):
                    return 'Error in ' + lineOld + 'Instruction number:' + str((numISA + 1))
                temp = temp | (opCode['m_type'] << opCodeShift) | (
                    op1 << rdsShift) | (int(line[2]) << shmtShift) | (func['funct1'])
                out[currentIP] = temp
            else:
                return 'Error in ' + lineOld + 'Instruction number:' + str((numISA + 1))
        elif (line[0].casefold() == 'LDD'.casefold()):
            if(len(line) == 3):
                op1 = reg.get(line[1], None)
                op2 = reg.get(line[2], None)
                if(op1 == None or op2 == None):
                    return 'Error in ' + lineOld + 'Instruction number:' + str((numISA + 1))
                temp = temp | (opCode['m_type'] << opCodeShift) | (
                    op2 << rdsShift) | (op1 << rsrShift) | (func['funct2'])
                out[currentIP] = temp
            else:
                return 'Error in ' + lineOld + 'Instruction number:' + str((numISA + 1))
        elif (line[0].casefold() == 'STD'.casefold()):  # STD R0, R1  -> R0-> dst  R1 -> src
            if(len(line) == 3):
                op1 = reg.get(line[1], None)
                op2 = reg.get(line[2], None)
                if(op1 == None or op2 == None):
                    return 'Error in ' + lineOld + 'Instruction number:' + str((numISA + 1))
                temp = temp | (opCode['m_type'] << opCodeShift) | (
                    op1 << rdsShift) | (op2 << rsrShift) | (func['funct3'])
                out[currentIP] = temp
            else:
                return 'Error in ' + lineOld + 'Instruction number:' + str((numISA + 1))
        elif (line[0].casefold() == 'LDM'.casefold()):  # LDM R0, 55
            if(len(line) == 3):
                op1 = reg.get(line[1], None)
                if(op1 == None):
                    return 'Error in ' + lineOld + 'Instruction number:' + str((numISA + 1))
                temp = temp | (opCode['I_type'] << opCodeShift) | (
                    op1 << rdsShift) | (func['funct0'])
                out[currentIP] = temp
                currentIP += 1
                temp = int(line[2])
                if(temp < 0):
                    temp = (temp + (1 << bits)) % (1 << bits)
                out[currentIP] = temp
            else:
                return 'Error in ' + lineOld + 'Instruction number:' + str((numISA + 1))
        elif (line[0].casefold() == 'CLR_FLAGS'.casefold()):
            if(len(line) == 1):
                temp = temp | (opCode['CLR_FLAGS'] << opCodeShift)
                out[currentIP] = temp
            else:
                return 'Error in ' + lineOld + 'Instruction number:' + str((numISA + 1))
        elif (line[0].casefold() == 'SETINT'.casefold()):
            if(len(line) == 1):
                temp = temp | (opCode['SETINT'] << opCodeShift)
                out[currentIP] = temp
            else:
                return 'Error in ' + lineOld + 'Instruction number:' + str((numISA + 1))
        elif (line[0].casefold() == 'NOP'.casefold()):
            if(len(line) == 1):
                out[currentIP] = temp
            else:
                return 'Error in ' + lineOld + 'Instruction number:' + str((numISA + 1))
        # rds , imediate # call Rds , # CALL label
        elif (line[0].casefold() == 'CALL'.casefold()):
            if(len(line) == 2):
                op1 = reg.get(line[1], None)
                if(op1 == None):
                    temp = temp | (opCode['I_type'] <<
                                   opCodeShift) | (func['funct1'])
                    out[currentIP] = temp
                    currentIP += 1
                    temp = line[1]
                    labelused.append(line[1])
                    out[currentIP] = temp
                else:
                    temp = temp | (opCode['CALL'] << opCodeShift) | (
                        op1 << rdsShift)
                    out[currentIP] = temp
            else:
                return 'Error in ' + lineOld + 'Instruction number:' + str((numISA + 1))
        elif(len(line) == 1):
            if(line[0][-1] == ':'):
                label[line[0][:-1]] = currentIP
                continue
            else:
                return 'Error in ' + lineOld + 'Instruction number:' + str((numISA + 1))
        else:
            return 'Invaild Instruction (instruction is not in the ISA please check your code): ' + lineOld + '-> ' + str((numISA + 1))
        currentIP += 1
        numISA += 1

    return 0


label = {}
labelused = []


def labelCompile(out):

    try:
        # loop for label
        # second loop for label instuctions
        for k, v in out.items():
            if(v in labelused):
                out[k] = label[v]
    except:
        print(Fore.RED + 'Error in handling jumping labels! please check it again!')
        print(Style.RESET_ALL)
        exit()


arrayISA = []
# try opening the file
try:
    file = open(fileName, 'r')
    getInput(file, arrayISA)
    if(len(arrayISA) == 0):
        print(Fore.RED + 'File is Empty! Please check it again.')
        print(Style.RESET_ALL)
        exit()
    # Closing the file
    file.close()

except IOError:
    print(Fore.RED + 'Could not open file! Please check it again.')
    print(Style.RESET_ALL)
    exit()


# spliting Vector and ()
# check for VECT
arrVect = []
if ('VECT\n' in arrayISA):
    index = arrayISA.index('VECT\n')
    arrVect = arrayISA[index + 1:]
    del arrayISA[index:]

# check for {}
arrSpecial = []
if (('{\n' in arrayISA) and ('}\n' in arrayISA)):
    index1 = arrayISA.index('{\n')
    index2 = arrayISA.index('}\n')
    arrSpecial = arrayISA[index1 + 1: index2]
    del arrayISA[index1: index2 + 1]

# dectionary of compiled ISA
out = OrderedDict()

# Compile VECT
if(len(arrVect) != 0):
    startMain = 0
    endMain = 31
    errorMessage = CompileOutput(arrVect, out, startMain, endMain)
    if(errorMessage != 0):
        print(Fore.RED + errorMessage + '! Please check it again.')
        print(Style.RESET_ALL)
        exit()
    if(len(out) == 0):
        print(Fore.RED + 'Error Couldn\'t assemble the file! Please check it again.')
        print(Style.RESET_ALL)
        exit()

# Compile ISA
if(len(arrayISA) != 0):
    startMain = 32
    endMain = 1048575
    errorMessage = CompileOutput(arrayISA, out, startMain, endMain)
    if(errorMessage != 0):
        print(Fore.RED + errorMessage + '! Please check it again.')
        print(Style.RESET_ALL)
        exit()
    if(len(out) == 0):
        print(Fore.RED + 'Error Couldn\'t assemble the file! Please check it again.')
        print(Style.RESET_ALL)
        exit()

#Compile ()
if(len(arrSpecial) != 0):
    startMain = int(arrSpecial[0])
    del arrSpecial[0]
    endMain = 1048575
    errorMessage = CompileOutput(arrSpecial, out, startMain, endMain)
    if(errorMessage != 0):
        print(Fore.RED + errorMessage + '! Please check it again.')
        print(Style.RESET_ALL)
        exit()
    if(len(out) == 0):
        print(Fore.RED + 'Error Couldn\'t assemble the file! Please check it again.')
        print(Style.RESET_ALL)
        exit()

labelCompile(out)

# write in file
# write out in
outConst = ['// instance=/processor/instr_fetch/instr_mem/memory\n',
            '// format=mti addressradix=d dataradix=h version=1.0 wordsperline=1\n']
fileOut = open(fileNameOut, "w")
for txt in outConst:
    fileOut.write(txt)
for key, vlaue in out.items():
    # formating the output
    line = str(key).zfill(8) + ': ' + \
        str(str(hex(int(vlaue)))[2:]).zfill(4) + '\n'
    fileOut.write(line)
fileOut.close()

print(Fore.GREEN + 'Assembled Successfully. File Name: ' + fileNameOut)
print(Fore.GREEN + 'Have Fun :)')
print(Style.RESET_ALL)
