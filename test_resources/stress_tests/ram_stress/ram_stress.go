package main

import (
	"bufio"
	"fmt"
	"os"
	"strconv"
	"strings"
	"github.com/shirou/gopsutil/v4/mem"
)

func getMemoryInfo() (uint64, uint64, error) {
	vm, err := mem.VirtualMemory()
	if err != nil {
		return 0, 0, err
	}
	return vm.Total, vm.Available, nil
}

func parseSize(arg string) (int64, error) {
	arg = strings.ToLower(arg)
	if strings.HasSuffix(arg, "%") {
		percentage, err := strconv.ParseFloat(strings.TrimSuffix(arg, "%"), 64)
		if err != nil {
			return 0, fmt.Errorf("Invalid percentage value")
		}
		total, available, err := getMemoryInfo()
		if err != nil {
			return 0, fmt.Errorf("Could not read memory info: %v", err)
		}
		used := total - available
		currentPercentage := float64(used) / float64(total) * 100
		fmt.Printf("Current memory usage: %.2f/%.2f B | %.2f%%\n",
			float64(used), float64(total), currentPercentage)
		targetUsed := int64(float64(total) * (percentage / 100))
		toAllocate := targetUsed - int64(used)
		if toAllocate <= 0 {
			return 0, fmt.Errorf("Current memory usage is already at or above the target")
		}
		return toAllocate, nil
	}

	var multiplier int64
	switch {
		case strings.HasSuffix(arg, "ki"):
			multiplier = 1024
			arg = strings.TrimSuffix(arg, "ki")
		case strings.HasSuffix(arg, "mi"):
			multiplier = 1024 * 1024
			arg = strings.TrimSuffix(arg, "mi")
		case strings.HasSuffix(arg, "gi"):
			multiplier = 1024 * 1024 * 1024
			arg = strings.TrimSuffix(arg, "gi")
		case strings.HasSuffix(arg, "k"):
			multiplier = 1000
			arg = strings.TrimSuffix(arg, "k")
		case strings.HasSuffix(arg, "m"):
			multiplier = 1000 * 1000
			arg = strings.TrimSuffix(arg, "m")
		case strings.HasSuffix(arg, "g"):
			multiplier = 1000 * 1000 * 1000
			arg = strings.TrimSuffix(arg, "g")
		default:
			multiplier = 1
	}

	value, err := strconv.ParseInt(arg, 10, 64)
	if err != nil {
		return 0, fmt.Errorf("Invalid value")
	}
	if value < 0 {
		return 0, fmt.Errorf("Can't allocate negative value")
	}
	return value * multiplier, nil
}

func main() {
	var toAllocate int64
	var err error

	if len(os.Args) > 2 {
		fmt.Printf("Usage: %s nr(k,M,G,ki,Mi,Gi,%)\n", os.Args[0])
		os.Exit(1)
	}

	if len(os.Args) == 1 {
		fmt.Println("No value provided, defaulting to max: 1Gi")
		toAllocate = 1024 * 1024 * 1024
	} else {
		toAllocate, err = parseSize(os.Args[1])
		if err != nil {
			fmt.Println(err)
			if strings.Contains(err.Error(), "invalid value") {
				fmt.Println("Defaulting to max: 1Gi")
				toAllocate = 1024 * 1024 * 1024
			} else {
				os.Exit(1)
			}
		}
	}

	fmt.Printf("Allocating %.2fGi | %.2fMi | %.2fki | %.2fG | %.2fM | %.2fk\n",
		float64(toAllocate)/(1024*1024*1024),
		float64(toAllocate)/(1024*1024),
		float64(toAllocate)/1024,
		float64(toAllocate)/(1000*1000*1000),
		float64(toAllocate)/(1000*1000),
		float64(toAllocate)/1000)
	fmt.Println("Program may not respond to keyboard interrupt until allocation end")

	data := make([]byte, toAllocate)
	for i := range data {
		data[i] = 0 // Ensure memory is allocated
	}

	fmt.Println("Memory allocated. Press Enter to release and exit.")
	scanner := bufio.NewScanner(os.Stdin)
	scanner.Scan()
}
