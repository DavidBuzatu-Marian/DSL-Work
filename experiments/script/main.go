package main

import (
	"bytes"
	"fmt"
	"log"
	"math/rand"
	"os"
	"os/exec"
	"strconv"
	"strings"
	"time"
)

func main() {
	app := "sudo"
	max := 100
	min := 0
	outputFile, err := os.OpenFile("experiment"+strconv.Itoa((rand.Intn(max-min)+min))+".log", os.O_APPEND|os.O_CREATE|os.O_WRONLY, 0644)
	if err != nil {
		fmt.Println(err)
	}
	defer outputFile.Close()
	for idx, name := range os.Args {
		if idx == 0 {
			continue
		}
		fmt.Println("Running experiment...")
		nameSplit := strings.Split(name, "-")
		podName := nameSplit[1]
		arg0 := "service"
		arg1 := "apply"
		arg2 := name
		arg3 := "-f"
		arg4 := "../" + podName + "/" + podName + "_" + nameSplit[0] + ".yaml"
		arg5 := "--concurrency-target=1"

		// Run Pod
		start := time.Now()
		cmd := exec.Command(app, "kn", arg0, arg1, arg2, arg3, arg4, arg5)
		var stderr bytes.Buffer
		cmd.Stderr = &stderr
		_, err := cmd.Output()
		elapsed := time.Since(start).Milliseconds()
		// Stop if any error occurs
		if err != nil {
			fmt.Println(err.Error(), stderr.String())
			return
		}

		// Write experiment to file
		experimentOutput := fmt.Sprintf("Run with pod: %s.\t Start container in: %v(ms)\n", podName, elapsed)
		if _, err := outputFile.WriteString(experimentOutput); err != nil {
			log.Println(err)
			log.Println(experimentOutput)
		}
		// Delete all kube resources
		fmt.Println("Cleaning up...")
		cmd = exec.Command("sudo", "kubectl", "delete", "all", "--all")
		cmd.Stderr = &stderr
		_, err = cmd.Output()
		if err != nil {
			fmt.Println(err.Error(), stderr.String())
			return
		}
	}
}
