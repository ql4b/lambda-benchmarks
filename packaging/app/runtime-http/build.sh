#!/bin/bash

go build -ldflags="-w -s" \
    -o build/bootstrap \
    main.go