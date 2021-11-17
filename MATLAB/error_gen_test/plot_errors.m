f = 'file.txt';
fp = fopen(f, 'r');
data = fscanf(fp, "%d");

fprintf("STDDEV = %f\n", std(data));
fprintf("SAMPLE MEAN = %f\n", mean(data));
fprintf("MIN = %d, MAX = %d\n", min(data), max(data));
histogram(data);
