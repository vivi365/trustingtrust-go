package main

import (
	"fmt"
	"os/exec"
)

func main() {
	fmt.Println("Initializing login program.")
	cmd := exec.Command("echo", "starting some background service")
	err := cmd.Run()
	if err != nil {
		fmt.Println("Error:", err)
		return
	}
}
