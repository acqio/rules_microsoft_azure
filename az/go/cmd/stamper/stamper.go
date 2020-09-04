package main

import (
    "flag"
    "log"
    "bufio"
    "os"
    "strings"
    "fmt"

    "github.com/acqio/rules_microsoft_azure/az/go/pkg/utils"
)

var (
    format        = flag.String("format", "", "The format string containing stamp variables.")
    output        = flag.String("output", "", "The filename into which we write the result.")
    stampInfoFile utils.ArrayStringFlags
)

func main() {

    flag.Var(&stampInfoFile,"stamp-info-file", "A list of files from which to read substitutions\n" +
                                               "to make in the provided --name, e.g. {BUILD_USER}")
    flag.Parse()

    if *format == "" {
        log.Fatalln("Required option -format was not specified.")
    }
    if *output == "" {
        log.Fatalln("Required option -output was not specified.")
    }
    if len(stampInfoFile) == 0 {
        log.Fatalln("Required option --stamp-info-file is required.")
    }

    format_args := make(map[string]string)

    for _, filePath := range stampInfoFile {
        readFile, err := os.Open(filePath)

        if err != nil {
            log.Fatalf("failed to open file: %s", err)
        }

        fileScanner := bufio.NewScanner(readFile)
        fileScanner.Split(bufio.ScanLines)
        var fileTextLines []string

        for fileScanner.Scan() {
            fileTextLines = append(fileTextLines, fileScanner.Text())
        }

        readFile.Close()

        for _, eachline := range fileTextLines {
            line := strings.Split(eachline, " ")
            if len(line) != 2 {
                log.Fatalf("Malformed line: %s", line)
            }
            key := fmt.Sprintf("{%s}", line[0])
            value := line[1]
            if v, err := format_args[key]; err {
                log.Printf("WARNING: Duplicate value for key '%s': using '%s'", line[0], v)
            }
            format_args[key] = value
        }
    }

    if value, err := format_args[*format]; err {
        writeFile, err := os.Create(*output)

        if err != nil {
            log.Fatalf("failed to create file: %s", err)
        }
        writeFile.WriteString(value)
        defer writeFile.Close()
    } else {
        log.Fatalf("ERROR: The stamp: '%s' not exists", *format)
    }
}
