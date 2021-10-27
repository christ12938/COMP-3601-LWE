"""
Reads characters from stdin and prints it in binary

Deprecated, this logic is done in VHDL now
"""


import sys


def main():
    user_input = sys.stdin.read()
    for char in user_input:
        print(format(ord(char), "08b"))


if __name__ == "__main__":
    main()
