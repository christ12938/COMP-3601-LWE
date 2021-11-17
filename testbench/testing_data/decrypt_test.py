import sys


# Config 2
Q: int = 3347
A_WIDTH: int = 8
A_HEIGHT: int = 8192
S: list = [2439, 2796, 2369, 977, 1959, 2756, 2046, 722]
FILE_NAME : str = "data0/encryption_v2_debug_bit_"


# Config 3
# FILE_NAME : str = "config3_0/encryption_v2_debug_bit_"
# A_HEIGHT : int = 32768
# A_WIDTH : int = 16
# Q : int = 35879
# # S : list = [11660, 25516, 56130, 6196, 47329, 61026, 5759, 42909, 38708, 27503, 6512, 38187, 45894, 16844, 43821, 19374] # old
# S: list = [31906, 24068, 33371, 13914, 31096, 22534, 16570, 1563, 15420, 11907, 12533, 15122, 22317, 20355, 24102, 16798]

DEBUG = False

def main():
    if len(sys.argv) != 2:
        print(f"Usage: {sys.argv[0]} <number of files>", file=sys.stderr)
        sys.exit(1)

    num_files = int(sys.argv[1])

    for i in range(num_files):
        with open(FILE_NAME + str(i) + ".txt", "r") as file:
            print(f"Opening file {i}")
            run_decrypt(file.readlines())
            # return


def run_decrypt(data: list):
    for j in range(len(data)):
        data[j] = data[j].strip()
        data[j] = data[j].replace("'", "")
        data[j] = data[j].split(" ")
        data[j] = [int(x) for x in data[j]]

    u: list = []
    for j in range(A_WIDTH):
        u.append(data[A_HEIGHT // 4][j])

    v: int = data[A_HEIGHT // 4][A_WIDTH]
    encrypted_m: int = data[A_HEIGHT // 4][A_WIDTH + 1]

    if DEBUG:
        print(f"DEBUG: u = {u}, v = {v}, expected_m = {encrypted_m}")

    u_dot_s: int = row_multiplication(u, S)

    dec: int = (v - u_dot_s) % Q
    decrypted_m: int = condition(dec)

    if DEBUG:
        print(f"DEBUG: u_dot_s = {u_dot_s}")
        print(f"DEBUG: v - u_dot_s = {v - u_dot_s}")
        print(f"DEBUG: dec = {dec}")
        print(f"DEBUG: decrypted_m = {decrypted_m}")

    if decrypted_m == encrypted_m:
        print("OK")
    else:
        print("FAIL")


def condition(dec: int) -> int:
    # M <= '0' when ((q / 4) <= dec and dec <= (3 * q / 4)) else '1';
    if DEBUG:
        print(f"Q // 4 = {Q // 4}, 3 * Q // 4 = {3 * Q // 4}")
    assert dec >= 0
    return 0 if Q // 4 <= dec and dec <= 3 * Q // 4 else 1
    # return 1 if dec <= Q // 2 else 0


def row_multiplication(u: list, v: list) -> int:
    sum: int = 0
    assert len(u) == len(v)

    for i in range(len(u)):
        sum += u[i] * v[i]
    return sum


if __name__ == '__main__':
    main()
