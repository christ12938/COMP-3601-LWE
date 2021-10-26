fileID = fopen('matlab_input.txt','r');
type matlab_input.txt
formatSpec = '%d';
data = fscanf(fileID, formatSpec);
histogram(data, 'BinWidth',0.2);
fclose(fileID);