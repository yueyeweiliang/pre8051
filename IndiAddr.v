//////////////////////////////////////////////////////////////////////
////                                                              ////
////  8051 indirect address                                       ////
////                                                              ////
////  This file is part of the 8051 cores project                 ////
////  http://www.opencores.org/cores/8051/                        ////
////                                                              ////
////  Description                                                 ////
////   Contains ragister 0 and register 1. used for indirrect     ////
////   addressing.                                                ////
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

module IndiAddr (clk, rst, addr, data_in, wr, wr_bit, data_out, sel, bank);
// clk          clock
// rst          reset
// addr         write address
// data_in      data input (alu destination1)
// wr           write
// wr_bit       write bit addresable
// data_out     data output
// sel          select (byte 1 [7]
// bank         bank: psw[4:3]


input clk, rst, wr, sel, wr_bit;
input [1:0] bank;
input [7:0] addr, data_in;

output data_out;
reg [7:0] data_out;

reg [7:0] buff [7:0];

//
//write to buffer
always @(posedge clk or rst)
begin
  if (rst) begin
    buff[3'b000] <= #1 8'h00;
    buff[3'b001] <= #1 8'h00;
    buff[3'b010] <= #1 8'h00;
    buff[3'b011] <= #1 8'h00;
    buff[3'b100] <= #1 8'h00;
    buff[3'b101] <= #1 8'h00;
    buff[3'b110] <= #1 8'h00;
    buff[3'b111] <= #1 8'h00;
  end else begin
    if ((wr) & !(wr_bit)) begin
      case (addr)
        8'h00: buff[3'b000] <= #1 data_in;
        8'h01: buff[3'b001] <= #1 data_in;
        8'h08: buff[3'b010] <= #1 data_in;
        8'h09: buff[3'b011] <= #1 data_in;
        8'h10: buff[3'b100] <= #1 data_in;
        8'h11: buff[3'b101] <= #1 data_in;
        8'h18: buff[3'b110] <= #1 data_in;
        8'h19: buff[3'b111] <= #1 data_in;
      endcase
    end
  end
end

//
//read from buffer
always @(sel or bank or data_in or wr or addr)
begin
  if (({3'b000, bank, 2'b00, sel}==addr) & (wr))
    data_out = data_in;
  else
    data_out = buff[{bank, sel}];
end

endmodule