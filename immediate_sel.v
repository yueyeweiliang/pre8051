//////////////////////////////////////////////////////////////////////
////                                                              ////
////  8051 immediate data select                                  ////
////                                                              ////
////  This file is part of the 8051 cores project                 ////
////  http://www.opencores.org/cores/8051/                        ////
////                                                              ////
////  Description                                                 ////
////   Multiplexer wiht whitch we select immediate data           ////
////   (byte 2, byte 3, program counter high or low)              ////
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

module immediate_sel (sel, op2, op3, pch, pcl, out);
// sel  select (from decoder)
// op2  byte 2
// op3  byte 3
// pch  pc high
// pcl  pc low
// out  output


input [1:0] sel; input [7:0] op2, op3, pch, pcl;
output out;
reg [7:0] out;

always @(sel or op2 or op3 or pch or pcl)
begin
  case (sel)
    `IDS_OP2: out= op2;
    `IDS_OP3: out= op3;
    `IDS_PCH: out= pch;
    `IDS_PCL: out= pcl;
    default out=2'bxx;
  endcase
end

endmodule