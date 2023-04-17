//////////////////////////////////////////////////////////////////////
////                                                              ////
////  8051 stack pointer                                          ////
////                                                              ////
////  This file is part of the 8051 cores project                 ////
////  http://www.opencores.org/cores/8051/                        ////
////                                                              ////
////  Description                                                 ////
////   8051 special function register: stack pointer.             ////
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

module sp (clk, rst, ram_rd_sel, ram_wr_sel, wr_addr, wr, wr_bit, data_in, data_out);
// clk          clock
// rst          reset
// ram_rd_sel   ram read select, used tu calculate next value
// ram_wr_sel   ram write select, used tu calculate next value
// wr           write
// wr_bit       write bit addresable
// data_in      data input (from alu destiantion 1)
// wr_addr      write address (if is addres of sp and white high must be written to sp)
// data_out     data output


input clk, rst, wr, wr_bit;
input [1:0] ram_rd_sel;
input [2:0] ram_wr_sel;
input [7:0] data_in, wr_addr;
output data_out;

reg [7:0] data_out;

//
//case of writing to stack pointer
always @(posedge clk)
begin
  if (rst)
    data_out <= #1 `RST_SP;
  else if ((wr_addr==`SFR_SP) & (wr) & !(wr_bit))
    data_out <= #1 data_in;
end

//
// pop
always @(posedge clk)
begin
  if (ram_rd_sel==`RRS_SP) data_out <= #1 data_out-1'b1;
end

//
// push
always @(posedge clk)
begin
  if (ram_wr_sel==`RWS_SP) data_out <= #1 data_out+1'b1;
end

endmodule