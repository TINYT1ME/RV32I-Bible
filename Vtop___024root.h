// Verilated -*- C++ -*-
// DESCRIPTION: Verilator output: Design internal header
// See Vtop.h for the primary calling header

#ifndef VERILATED_VTOP___024ROOT_H_
#define VERILATED_VTOP___024ROOT_H_  // guard

#include "verilated.h"


class Vtop__Syms;

class alignas(VL_CACHE_LINE_BYTES) Vtop___024root final {
  public:

    // DESIGN SPECIFIC STATE
    VL_IN8(branch,0,0);
    VL_IN8(funct3,2,0);
    VL_OUT8(take_branch,0,0);
    CData/*0:0*/ branch_unit__DOT__branch;
    CData/*2:0*/ branch_unit__DOT__funct3;
    CData/*0:0*/ branch_unit__DOT__take_branch;
    CData/*0:0*/ __VstlFirstIteration;
    CData/*0:0*/ __VicoFirstIteration;
    VL_IN(rs1_val,31,0);
    VL_IN(rs2_val,31,0);
    IData/*31:0*/ branch_unit__DOT__rs1_val;
    IData/*31:0*/ branch_unit__DOT__rs2_val;
    VlUnpacked<QData/*63:0*/, 1> __VstlTriggered;
    VlUnpacked<QData/*63:0*/, 1> __VicoTriggered;

    // INTERNAL VARIABLES
    Vtop__Syms* vlSymsp;
    const char* vlNamep;

    // CONSTRUCTORS
    Vtop___024root(Vtop__Syms* symsp, const char* namep);
    ~Vtop___024root();
    VL_UNCOPYABLE(Vtop___024root);

    // INTERNAL METHODS
    void __Vconfigure(bool first);
};


#endif  // guard
