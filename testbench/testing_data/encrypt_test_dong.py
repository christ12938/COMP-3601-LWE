"""
Usage: python3 `encrypt_test_dong.py 16`
The above will run the test on
    encryption_v2_debug_bit_0.txt
    encryption_v2_debug_bit_1.txt
    ...
    encryption_v2_debug_bit_15.txt
"""
import sys

Q: int = 3347
A_WIDTH: int = 8
A_HEIGHT: int = 8192

FILE_NAME : str = "config2/encryption_v2_debug_bit_"
# FILE_NAME : str = "config3_0/encryption_v2_debug_bit_"
# A_HEIGHT : int = 32768
# A_WIDTH : int = 16
# Q : int = 35879

def main():
    if len(sys.argv) != 2:
        print(f"{sys.argv[0]} <number of files>", file=sys.stderr)
        sys.exit(1)

    num_files : int = int(sys.argv[1])

    for i in range(num_files):
        with open(FILE_NAME + str(i) + ".txt", "r") as file:
            print(f"Opening file {i}")
            run_encrypt(file.readlines())
            # return


def run_encrypt(data: list):
    for i in range(len(data)):
        data[i] = data[i].strip()
        data[i] = data[i].replace("'", "")
        data[i] = data[i].split(" ")
        data[i] = [int(x) for x in data[i]]

    sum_a: list = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]
    u: list = []
    sum_b: int = 0
    v: int = 0

    # Do sum_a
    for j in range(A_WIDTH):
        for i in range(A_HEIGHT // 4):
            # print(i, j)
            sum_a[j] += data[i][j + 1]

    # Do sum_b
    for i in range(A_HEIGHT // 4):
        # print(f"{i} {A_WIDTH + 1}")
        sum_b += data[i][A_WIDTH + 1]

    # print(f"sum_a: {sum_a}, sum_b: {sum_b}")

    for i in range(A_WIDTH):
        u.append(sum_a[i] % Q)

    m: int = data[A_HEIGHT // 4][A_WIDTH + 1]
    v = (sum_b - (Q // 2) * m) % Q

    # print(f"m: {m}")
    # print(f"u: {u}")
    # print(f"v: {v}")

    if u == data[A_HEIGHT // 4][:A_WIDTH]:
        print("u OK")
    else:
        print("u ERROR")

    if v == data[A_HEIGHT // 4][A_WIDTH]:
        print("v OK")
    else:
        print("v ERROR")


if __name__ == "__main__":
    main()
