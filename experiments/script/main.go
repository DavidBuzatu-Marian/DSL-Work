package main

import (
	"fmt"
	"log"
	"os"
	"os/exec"
	"strings"
	"time"
)

func main() {
	app := "kn"
	outputFile, err := os.OpenFile("experiment.log", os.O_APPEND|os.O_CREATE|os.O_WRONLY, 0644)
	if err != nil {
		fmt.Println(err)
	}
	defer outputFile.Close()
	for _, name := range os.Args {
		fmt.Println("Running experiment...")
		podName := strings.Split(name, "-")[1]
		arg0 := "service"
		arg1 := "apply"
		arg2 := name
		arg3 := "-f"
		arg4 := "./" + podName + "/" + podName + "_base.yaml"
		arg5 := "--concurrency-target 1"

		// Run Pod
		start := time.Now()
		cmd := exec.Command(app, arg0, arg1, arg2, arg3, arg4, arg5)
		elapsed := time.Since(start)
		_, err := cmd.Output()

		// Stop if any error occurs
		if err != nil {
			fmt.Println(err.Error())
			return
		}

		// Write experiment to file
		experimentOutput := fmt.Sprintf("Run with pod: %s.\t Start container in: %s\n", podName, elapsed)
		if _, err := outputFile.WriteString(experimentOutput); err != nil {
			log.Println(err)
			log.Println(experimentOutput)
		}
		// Delete all kube resources
		fmt.Println("Cleaning up...")
		cmd = exec.Command("kubectl", "delete all", "--all")
		_, err = cmd.Output()
		if err != nil {
			fmt.Println(err.Error())
			return
		}
	}
}
