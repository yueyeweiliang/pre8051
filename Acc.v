//////////////////////////////////////////////////////////////////////
////                                                              ////
////  8051 cores acccumulator                                     ////
////                                                              ////
////  This file is part of the 8051 cores project                 ////
////  http://www.opencores.org/cores/8051/                        ////
////                                                              ////
////  Description                                                 ////
////   accumulaor register for 8051 core                          ////
////                                                              ////
////  To Do:                                                      ////
////   Nothing                                                    ////
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

module acc (clk, rst, bit_in, data_in, data2_in, wr, wr_bit, wad2, wr_addr, data_out, p);
// clk          clock
// rst          reset
// bit_in       bit input - used in case of writing bits to acc (bit adddressable memory space - alu carry)
// data_in      data input - used to write to acc (from alu destiantion 1)
// data2_in     data 2 input - write to acc, from alu detination 2 - instuctions mul and div
// wr           write - actine high
// wr_bit       write bit addresable - actine high
// wad2         write data 2
// wr_addr      write address (if is addres of acc and white high must be written to acc)
// data_out     data output
// p            parity


input clk, rst, wr, wr_bit, wad2, bit_in;
input [7:0] wr_addr, data_in, data2_in;

output data_out, p;

reg [7:0] data_out;

//
//calculates parity
assign p = ^data_out;

//
//writing to acc
//must check if write high and correct address
always @(posedge clk or rst)
begin
  if (rst)
    data_out <= #1 `RST_ACC;
  else if (wad2)
    data_out <= #1 data2_in;
  else
    case ({wr, wr_bit})
      2'b10: begin
        if (wr_addr==`SFR_ACC)
          data_out <= #1 data_in;
      end
      2'b11: begin
        if (wr_addr[7:3]==`SFR_B_ACC)
          data_out[wr_addr[2:0]] <= #1 data_in;
      end
    endcase
end

endmodule
