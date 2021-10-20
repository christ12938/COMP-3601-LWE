f = open("vhdl_output.txt", "r")
file1 = open('matlab_input.txt', 'w')
for x in f:
    if 'U' in x:
        continue
    file1.write(str(int(x, 2)) + "\n")