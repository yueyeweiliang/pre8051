//////////////////////////////////////////////////////////////////////
////                                                              ////
////  8051 rom address select                                     ////
////                                                              ////
////  This file is part of the 8051 cores project                 ////
////  http://www.opencores.org/cores/8051/                        ////
////                                                              ////
////  Description                                                 ////
////   Multiplexer wiht whitch we select rom address              ////
////   (program counter or alu destination)                       ////
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

module rom_addr_sel (clk, rst, select, des1, des2, pc, op1, out_data, out_addr);
// clk          clock
// rst          reset
// select       output select
// des1, des2   alu destination input
// pc           pc input
// op1          byte 1 from rom
// out_data     output data (alu des2)
// out_addr     output address (to program rom)


input clk, rst, select;
input [7:0] des1, des2, op1;
input [15:0] pc;
output [7:0] out_data;
output [15:0] out_addr;

reg sel_buff;

//
// output data is operation byte 1
// output address is alu destination
// (instructions MOVC)
assign out_data = sel_buff ? op1 : des2;
assign out_addr = select ? {des2, des1} : pc;

//
// data output is delayed for one clock
always @(posedge clk or rst)
begin
  if (rst)
    sel_buff <= #1 1'b0;
  else
    sel_buff  <= #1 select;
end

endmodule