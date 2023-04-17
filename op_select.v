//////////////////////////////////////////////////////////////////////
////                                                              ////
////  8051 instruction select                                     ////
////                                                              ////
////  This file is part of the 8051 cores project                 ////
////  http://www.opencores.org/cores/8051/                        ////
////                                                              ////
////  Description                                                 ////
////   module that stops current program and insert long call     ////
////   in case of interrupt                                       ////
////                                                              ////
////  To Do:                                                      ////
////   nothing                                                    ////
////                                                              ////
////  Author(s):                                                  ////
////      - Simon Teran, simont@opencores.org                     ////
////                                                              ////
//////////////////////////////////////////////////////////////////////
////                                                              ////
//// Copyright (C) 2000 Authors and OPENCORES.ORG                 ////
////                                                              ////
//// This source file may be used and distributed without         ////
//// restriction provided that this copyright statement is not    ////
//// removed from the file and that any derivative work contains  ////
//// the original copyright notice and the associated disclaimer. ////
////                                                              ////
//// This source file is free software; you can redistribute it   ////
//// and/or modify it under the terms of the GNU Lesser General   ////
//// Public License as published by the Free Software Foundation; ////
//// either version 2.1 of the License, or (at your option) any   ////
//// later version.                                               ////
////                                                              ////
//// This source is distributed in the hope that it will be       ////
//// useful, but WITHOUT ANY WARRANTY; without even the implied   ////
//// warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR      ////
//// PURPOSE.  See the GNU Lesser General Public License for more ////
//// details.                                                     ////
////                                                              ////
//// You should have received a copy of the GNU Lesser General    ////
//// Public License along with this source; if not, download it   ////
//// from http://www.opencores.org/lgpl.shtml                     ////
////                                                              ////
//////////////////////////////////////////////////////////////////////
//
// ver: 1
//

module op_select (clk, int, , rd, pc, int_v, op1, op2, op3, op1_out, op2_out, op2_direct, op3_out);
// clk          clock
// int          interrupt
// int_v        interrupt vector (low byte)
// op1, op2, op3 input from rom (instruction bytes)
// op1_out      byte 1 output
// op2_out      byte 2 output
// op2_direct   byte 2 output (used for direct addressing)
// op3_out      byte 3 output
// rd           read from rom
// pc           pc input (used for some instructions to calculate next address)


input clk, int, rd; input [7:0] op1, op2, op3, int_v, pc;
output [7:0] op1_out, op3_out;
output op2_out, op2_direct;

reg int_ack;
reg [7:0] op2_out, op2_direct;
reg [7:0] op1_buff, op2_buff, op3_buff;
reg [7:0] op1_o, op2_o, op3_o;

wire [7:0] op2_tmp;

//
// assigning outputs
// case rd = 1'b0 don't change output
assign op1_out = rd ? op1_o : op1_buff;
assign op3_out = rd ? op3_o : op3_buff;
assign op2_tmp = rd ? op2_o : op2_buff;

//
// in case of interrupts
always @(op1 or op2 or op3 or int or int_v) begin
  if (int_ack) begin
    op1_o = `LCALL;
    op2_o = 8'h00;
    op3_o = int_v;
  end else begin
    op1_o = op1;
    op2_o = op2;
    op3_o = op3;
  end
end

//
// remember inputs
always @(posedge clk)
begin
  op1_buff <= #1 op1_o;
  op2_buff <= #1 op2_o;
  op3_buff <= #1 op3_o;
end

//
// remember interrupt
// we don't want to interrupt instruction in the middle of execution
always @(posedge clk)
 if (int) int_ack <= #1 1'b1;
 else int_ack <= #1 1'b0;


//
// in some instructions we need pc instead byte 2
always @(op1_out or op2_tmp or pc)
begin
  casex (op1_out)
    `CJNE_R : op2_out = pc;
    `CJNE_I : op2_out = pc;
    `CJNE_D : op2_out = pc;
    `CJNE_C : op2_out = pc;
    `DJNZ_R : op2_out = pc;
    `DJNZ_D : op2_out = pc;
    `JB : op2_out = pc;
    `JBC: op2_out = pc;
    `JC: op2_out = pc;
    `JNC : op2_out = pc;
    `JNB : op2_out = pc;
    `JNZ : op2_out = pc;
    `JZ : op2_out = pc;
    `SJMP : op2_out = pc;
    `MOVC_PC : op2_out = pc;
    default: op2_out = op2_tmp;
  endcase
end


//
// some instructions write to known addresses
always @(op1_out or op2_tmp)
begin
  if ((op1_out==`MOV_DP) | (op1_out==`INC_DP) | (op1_out==`JMP) | (op1_out==`MOVC_DP))
    op2_direct  = `SFR_DPTR_LO;
  else if ((op1_out==`MUL) | (op1_out == `DIV))
    op2_direct  = `SFR_B;
  else op2_direct  = op2_tmp;
end


endmodule
