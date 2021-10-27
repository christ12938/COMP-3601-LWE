f = open("vhdl_output.txt", "r")
file1 = open('matlab_input.txt', 'w')
prev = ''
for x in f:

    file1.write(str(int(x, 2)) + "\n")