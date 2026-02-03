SIM ?= verilator
TOPLEVEL_LANG ?= verilog

VERILOG_SOURCES += $(PWD)/../rtl/*.sv


COCOTB_TOPLEVEL = alu

COCOTB_TEST_MODULES = test_alu

include $(shell cocotb-config --makefiles)/Makefile.sim
