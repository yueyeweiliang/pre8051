//////////////////////////////////////////////////////////////////////
////                                                              ////
////  8051 ram read select                                        ////
////                                                              ////
////  This file is part of the 8051 cores project                 ////
////  http://www.opencores.org/cores/8051/                        ////
////                                                              ////
////  Description                                                 ////
////   Multiplexer wiht whitch we define ram read address         ////
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


module ram_rd_sel (sel, sp, ri, rn, imm, out);
// sel  select (look defines)
// sp   stack ponter
// ri   indirect addresing
// rn   registers
// imm  immediate (direct addresing)
// out  output

input [1:0] sel;
input [4:0] rn;
input [7:0] sp, ri, imm;

output out;
reg [7:0] out;

//
// 
always @(sel or sp or ri or rn or imm)
begin
  case (sel)
    `RRS_RN : out = {3'b000, rn};
    `RRS_I : out = ri;
    `RRS_D : out = imm;
    `RRS_SP : out = sp;
    default : out = 2'bxx;
  endcase

end

endmodule