//////////////////////////////////////////////////////////////////////
////                                                              ////
////  8051 alu source 1 select module                             ////
////                                                              ////
////  This file is part of the 8051 cores project                 ////
////  http://www.opencores.org/cores/8051/                        ////
////                                                              ////
////  Description                                                 ////
////   Multiplexer wiht whitch we select data on alu source 1     ////
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

module alu_src1_sel (sel, immediate, acc, ram, ext, des);
//
// sel          select signals (from decoder, delayd one clock)
// immediate    input from immediate_sel1
// acc          acc input
// ram          ram input
// ext          external ram input
// des          output (alu sorce 1)


input [1:0] sel; input [7:0] immediate, acc, ram, ext;
output des;
reg [7:0] des;

always @(sel or immediate or acc or ram or ext)
begin
  case (sel)
    `ASS_RAM: des= ram;
    `ASS_ACC: des= acc;
    `ASS_XRAM: des= ext;
    `ASS_IMM: des= immediate;
    default: des= 2'bxx;
  endcase
end

endmodule
