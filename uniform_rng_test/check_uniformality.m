% system('convert.exe');
f1 = 'truerng.txt';
f2 = 'python_rng_out.txt';
f3 = 'seedgen64.txt';

fileId1 = fopen(f1, 'r');
fileId2 = fopen(f2, 'r');
fileId3 = fopen(f3, 'r');

formatSpec = '%d';

data1 = fscanf(fileId1, formatSpec);
data2 = fscanf(fileId2, formatSpec);
data3 = fscanf(fileId3, formatSpec);

subplot(1,3,1);
histogram(data1, 'BinWidth', 1);
title('VHDL Distribution with True Random Seed');
ylim([0, 25])

subplot(1,3,2);
histogram(data2, 'BinWidth', 1);
title('Python Benchmark');
ylim([0, 25])

subplot(1,3,3);
histogram(data3, 'BinWidth', 1);
title('VHDL Distribution with Seed Generator');
ylim([0, 25])

fprintf('truerng.txt: Min: %d\nAverage: %d\nMax: %d\n',min(data1),mean(data1), max(data1));
fprintf('python_rng_out.txt: Min: %d\nAverage: %d\nMax: %d\n',min(data2),mean(data2), max(data2));
fprintf('seedgen: Min: %d\nAverage: %d\nMax: %d\n',min(data3),mean(data3), max(data3));

fclose(fileId1);
fclose(fileId2);
fclose(fileId3);
