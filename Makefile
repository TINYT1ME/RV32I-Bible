SIM ?= verilator
TOPLEVEL_LANG ?= verilog

VERILOG_SOURCES += $(PWD)/*.sv


COCOTB_TOPLEVEL = branch_unit


COCOTB_TEST_MODULES = test_branch_unit

include $(shell cocotb-config --makefiles)/Makefile.sim
