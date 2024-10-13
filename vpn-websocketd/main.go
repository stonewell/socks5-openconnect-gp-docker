package main

import (
	"bufio"
	"encoding/hex"
	"flag"
	"io"
	"log"
	"net/http"
	"os"
	"os/exec"

	"github.com/olahol/melody"
)

func create_cmd(scriptPath string, m *melody.Melody) (*exec.Cmd, io.WriteCloser) {
	cmd := exec.Command(scriptPath)
	cmd.Stderr = os.Stderr
	stdin, err := cmd.StdinPipe()

	if nil != err {
		log.Fatalf("Error obtaining stdin: %s", err.Error())
	}
	stdout, err := cmd.StdoutPipe()
	if nil != err {
		log.Fatalf("Error obtaining stdout: %s", err.Error())
	}
	reader := bufio.NewReader(stdout)
	go func(reader io.Reader) {
		scanner := bufio.NewScanner(reader)
		for scanner.Scan() {
			log.Printf("Reading from subprocess: %s", scanner.Text())
			m.Broadcast([]byte(scanner.Text()))
		}
	}(reader)

	return cmd, stdin
}

func main() {
	var scriptPath string
	flag.StringVar(&scriptPath, "script", "", "the script to run")
	flag.StringVar(&scriptPath, "s", "", "the script to run")

	flag.Parse()

	if scriptPath == "" {
		log.Fatalf("must provide a script to run")
	}

	m := melody.New()

	http.HandleFunc("/", func(w http.ResponseWriter, r *http.Request) {
		http.ServeFile(w, r, "index.html")
	})

	http.HandleFunc("/ws", func(w http.ResponseWriter, r *http.Request) {
		m.HandleRequest(w, r)
	})

	var cmd *exec.Cmd
	var stdin io.WriteCloser

	m.HandleMessage(func(s *melody.Session, msg []byte) {
		log.Printf("Reading from websocket: %s, %s", string(msg), hex.EncodeToString(msg))
		m.Broadcast(msg)

		if string(msg) == "start" {
			go func() {
				cmd, stdin = create_cmd(scriptPath, m)
				if err := cmd.Start(); nil != err {
					log.Fatalf("Error starting program: %s, %s", cmd.Path, err.Error())
				}
				cmd.Wait()
				m.Broadcast([]byte("program finished"))
				cmd = nil
				stdin = nil
			}()
		} else if string(msg) == "stop" {
			log.Printf("stop process")
			if cmd != nil {
				cmd.Process.Kill()
			}
		} else {
			if stdin != nil {
				stdin.Write(msg)
				stdin.Write([]byte("\n"))
			}
		}
	})

	http.ListenAndServe(":5000", nil)
}
