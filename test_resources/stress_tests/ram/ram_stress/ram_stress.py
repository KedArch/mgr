#!/usr/bin/env python3
import sys

def get_memory_info():
    with open('/proc/meminfo', 'r') as f:
        total = 0
        available = 0
        for line in f:
            if line.startswith('MemTotal:'):
                total = int(line.split()[1]) * 1024
            if line.startswith('MemAvailable:'):
                available = int(line.split()[1]) * 1024
    return total, available

if __name__ == "__main__":
    try:
        if len(sys.argv) > 2:
            print(f"Usage: {sys.argv[0]} nr(k,M,G,ki,Mi,Gi,%)")
            sys.exit(1)
        elif sys.argv[1].startswith("-"):
            print("Can't allocate negative value")
            sys.exit(2)
        elif sys.argv[1].endswith("%"):
            target = float(sys.argv[1][:-1])
            total, available = get_memory_info()
            if total == 0:
                print("Error: Could not read memory info. Percentage option works on Linux only.")
                sys.exit(3)
            used = total - available
            current_percentage = (used/total) * 100
            print(f"Current memory usage: {used/(1024**3):.2f}/{total/(1024**3):.2f}|{current_percentage}%")
            target_used = total * (target/100)
            to_allocate = int(target_used - used)
            if to_allocate <= 0:
                print("Current memory usage is already at or above the target.")
                sys.exit(0)
        elif sys.argv[1].endswith(("ki", "Ki")):
            to_allocate = int(sys.argv[1][:-2]) * 1024
        elif sys.argv[1].endswith(("mi", "Mi")):
            to_allocate = int(sys.argv[1][:-2]) * 1024 ** 2
        elif sys.argv[1].endswith(("gi", "Gi")):
            to_allocate = int(sys.argv[1][:-2]) * 1024 ** 3
        elif sys.argv[1].endswith(("k", "K")):
            to_allocate = int(sys.argv[1][:-1]) * 1000
        elif sys.argv[1].endswith(("m", "M")):
            to_allocate = int(sys.argv[1][:-1]) * 1000 ** 2
        elif sys.argv[1].endswith(("g", "G")):
            to_allocate = int(sys.argv[1][:-1]) * 1000 ** 3
        else:
            to_allocate = int(sys.argv[1])
    except (ValueError, IndexError):
        print("Couldn't read value, defaulting to max: 1Gi")
        to_allocate = 1024**3
    try:
        print(f"Allocating {to_allocate/(1024**3):.2f}Gi|{to_allocate/(1024**2):.2f}Mi|{to_allocate/(1024):.2f}ki"
              + f"|{to_allocate/(1000**3):.2f}G|{to_allocate/(1000**2):.2f}M|{to_allocate/(1000):.2f}k")
        print("Program may not respond to keyboard interrupt until allocation end")
        data = b'\0' * to_allocate
        print("Memory allocated. Press Enter to release and exit.")
        _ = input()
    except MemoryError:
        print("Error: Not enough memory available to allocate.")
    except KeyboardInterrupt:
        pass
