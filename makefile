UNAME_S := $(shell uname -s)

all: main.c
	gcc main.c -std=c99 -m64 -O3 -o build/bed2cov_$(UNAME_S)
