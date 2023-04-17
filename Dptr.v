//////////////////////////////////////////////////////////////////////
////                                                              ////
////  8051 data pointer                                           ////
////                                                              ////
////  This file is part of the 8051 cores project                 ////
////  http://www.opencores.org/cores/8051/                        ////
////                                                              ////
////  Description                                                 ////
////   8051 special function register: data pointer               ////
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

module dptr(clk, rst, addr, data_in, data2_in, wr, wd2, wr_bit, data_hi, data_lo);
// clk          clock
// rst          reset
// addr         write address input
// data_in      destination 1 from alu
// data2_in     destination 2 from alu
// wr           write to ram
// wd2          write from destination 2
// wr_bit       write bit addresable
// data_hi      output (high bits)
// data_lo      output (low bits)


input clk, rst, wr, wr_bit;
input [2:0] wd2;
input [7:0] addr, data_in, data2_in;

output data_hi, data_lo;

reg [7:0] data_hi, data_lo;

always @(posedge clk or rst)
begin
  if (rst) begin
    data_hi <= #1 `RST_DPH;
    data_lo <= #1 `RST_DPL;
  end else if (wd2==`RWS_DPTR) begin
//
//write from destination 2 and 1
    data_hi <= #1 data2_in;
    data_lo <= #1 data_in;
  end else if ((addr==`SFR_DPTR_HI) & (wr) & !(wr_bit))
//
//case of writing to dptr
    data_hi <= #1 data_in;
  else if ((addr==`SFR_DPTR_LO) & (wr) & !(wr_bit))
    data_lo <= #1 data_in;
end

endmodule

