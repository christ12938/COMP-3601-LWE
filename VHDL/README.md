## logic of random number generator

### LWE requirements
A , s -> uniformly distributed random numbers for indexes\
e -> normally distributed random numbers for indexes\

### logic 
There are different LFS implementation but for now we use this implementation *will probably change later but good for now*[]( "https://hforsten.com/generating-normally-distributed-pseudorandom-numbers-on-a-fpga.html") 

To get random number in the range of MOD of q:\
    1. get log of q (index of most significant bit)\
    2. set the length of random number to log q\
    3. compare the generated random number with q if bigger return: rand - q 
    ** since we are setting the length of rand to log of q the maximum value we get is 2 ^ (logq) so rand number is max q + q-1 **

