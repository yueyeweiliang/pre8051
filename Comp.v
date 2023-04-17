//////////////////////////////////////////////////////////////////////
////                                                              ////
////  8051 compare                                                ////
////                                                              ////
////  This file is part of the 8051 cores project                 ////
////  http://www.opencores.org/cores/8051/                        ////
////                                                              ////
////  Description                                                 ////
////   compares selected inputs and set eq to 1 if they are equal ////
////   Is used for conditional jumps.                             ////
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

module comp (sel, eq, b_in, cy, acc, ram, op2, des);

// sel  select whithc sourses to compare (look defines.v)
// eq   if (src1 == src2) eq = 1
// b_in bit in
// acc  accumulator
// ram  input from ram
// op2  immediate data
// des  destination from alu


input [2:0] sel;
input b_in, cy;
input [7:0] acc, ram, op2, des;

output eq;
reg eq;

always @(sel or b_in or cy or acc or ram or op2 or des)
begin
  case (sel)
    `CSS_AZ : eq = (acc == 8'h00);
    `CSS_AR : eq = (acc == ram);
    `CSS_AC : eq = (acc == op2);
    `CSS_CR : eq = (op2 == ram);
    `CSS_DES : eq = (des == 8'h00);
    `CSS_CY : eq = cy;
    `CSS_BIT : eq = b_in;
    default: eq = 1'bx;
  endcase
end

endmodule
