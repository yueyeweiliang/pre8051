//////////////////////////////////////////////////////////////////////
////                                                              ////
////  8051 ram write select                                       ////
////                                                              ////
////  This file is part of the 8051 cores project                 ////
////  http://www.opencores.org/cores/8051/                        ////
////                                                              ////
////  Description                                                 ////
////   Multiplexer wiht whitch we define ram write address        ////
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

module ram_wr_sel (sel, sp, rn, imm, ri, imm2, out);
// sel  select (look defines)
// sp   stack ponter
// ri   indirect addressing
// rn   registers
// imm  immediate (direct addresing)
// out  output


input [2:0] sel;
input [4:0] rn;
input [7:0] sp, imm, ri, imm2;

output out;
reg [7:0] out;

//
//
always @(sel or sp or rn or imm)
begin
  case (sel)
    `RWS_RN : out = {3'b000, rn};
    `RWS_I : out = ri;
    `RWS_D : out = imm;
    `RWS_SP : out = sp;
    `RWS_ACC : out = `SFR_ACC;
    `RWS_D3 : out = imm2;
    `RWS_DPTR : out = `SFR_DPTR_LO;
    `RWS_B : out = `SFR_B;
    default : out = 2'bxx;
  endcase

end

endmodule
