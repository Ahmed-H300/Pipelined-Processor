# get file id number from the command line
fileNum=$1

#get the relative file path
filePath=$(find ./test_codes/ -iname "*_$fileNum.txt")

#execute the file 
python assembler.py $filePath instructionMemory.mem 

#copy this file to the project
cp instructionMemory.mem ../verilog\ files/simulation\ files/isntr.mem