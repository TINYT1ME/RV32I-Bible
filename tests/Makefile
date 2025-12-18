# Makefile

# 1. Simulator Setup
SIM ?= verilator
TOPLEVEL_LANG ?= verilog

EXTRA_ARGS += --trace --trace-structs

# 2. File Paths
# PWD is the current directory (tests/)
PWD=$(shell pwd)

# Go up one level to 'rtl' folder
VERILOG_SOURCES = $(PWD)/../rtl/*.sv

# 3. Test Configuration
TOPLEVEL = cpu_top
MODULE = im_test

# 4. Standard Cocotb Include
# This works automatically on Linux
include $(shell cocotb-config --makefiles)/Makefile.sim