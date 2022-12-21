# get file id number from the command line
fileNum=$1

#get the relative file path
filePath=$(find ./test_codes/ -iname $fileNum"_*")

echo $filePath

#execute the file 
python assembler.py $filePath instructionMemory.mem

#move this file to the project
mv instructionMemory.mem ../verilog\ files/simulation\ files/instructionMemory.mem