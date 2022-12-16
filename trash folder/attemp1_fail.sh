# take the number of the file to run
FileNumber=$1

# get the current directory number
CurrnetDirectory="$(dirname "$(realpath "$0")")"

# the directory of the codes
codeDir='/test_codes/'

# get the directory of the text file
#textFileToExecute=$CurrnetirectDory

#get the exact text file to execute
fileToExecute="$CurrnetDirectory$codeDir""test1.txt";

cat "$CurrnetDirectory$codeDir""test1.txt";

# get the path of that text file
#FileName=

# print the contents of the variable on screen
#echo "$CurrnetDirectory$codeDir"