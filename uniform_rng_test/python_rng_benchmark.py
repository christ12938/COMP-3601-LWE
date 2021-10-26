import random


def main():
    with open("python_rng_out.txt", "w") as f:
        for _ in range(0, 8192):
            for _ in range(0, 8):
                f.write(f"{random.randint(0, 8192 - 1)} ")
            f.write('\n')




if __name__ == "__main__":
    main()
