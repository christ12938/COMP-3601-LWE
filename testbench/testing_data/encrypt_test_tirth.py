f = open("encryption_v2_debug_bit_0.txt", "r")
q = 3347
samples = f.readlines()
sumation_a = [0,0,0,0,0,0,0,0]
sumation_b = 0
u = [0,0,0,0,0,0,0,0]
v = 0
for i in range(0, len(samples)):
    samples[i] = samples[i].replace("'", "")
    samples[i] = samples[i].split()


for i in range(0,len(samples)-1):
  for j in range(1,9):
    sumation_a[j-1] += int(samples[i][j])
  sumation_b += int(samples[i][9])
  print(samples[i])

print("Calculated U = ", [item % q for item in sumation_a])
print("Encryptor U = " , samples[-1][0:8])
if int(samples[-1][9]) == 0:
  print("Calculated V = " , sumation_b%q)
elif int(samples[-1][9]) == 1:
  print("Calculated V = " , (sumation_b + round(q/2))%q)
print("Encryptor V = ", samples[-1][8])
print("M = ",  samples[-1][9] )
