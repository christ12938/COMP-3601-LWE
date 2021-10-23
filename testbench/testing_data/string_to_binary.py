import sys


def main():
    user_input = sys.stdin.read()
    for char in user_input:
        print(format(ord(char), "08b"))


if __name__ == "__main__":
    main()
