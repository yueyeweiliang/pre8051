//////////////////////////////////////////////////////////////////////
////                                                              ////
////  8051 port output                                            ////
////                                                              ////
////  This file is part of the 8051 cores project                 ////
////  http://www.opencores.org/cores/8051/                        ////
////                                                              ////
////  Description                                                 ////
////   8051 special function registers: port 0:3 - output         ////
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

module port_out (clk, rst, bit_in, data_in, wr, wr_bit, wr_addr, p0, p1, p2, p3);
// clk          clock
// rst          reset
// bit_in       bit input
// wr           write
// wr_bit       write bit addresable
// data_in      data input (from alu destiantion 1)
// wr_addr      write address (if is addres of sp and white high must be written to sp)
// p0, p1, p2, p3 port outputs


input clk, rst, wr, wr_bit, bit_in;
input [7:0] wr_addr, data_in;

output p0, p1, p2, p3;

reg [7:0] p0, p1, p2, p3;

//
// case of writing to port
always @(posedge clk)
begin
  if (rst) begin
    p0 <= #1 `RST_P0;
    p1 <= #1 `RST_P1;
    p2 <= #1 `RST_P2;
    p3 <= #1 `RST_P3;
  end else
    case ({wr, wr_bit})
      2'b10: begin
        case (wr_addr)
//
// byte addresable
          `SFR_P0: p0 <= #1 data_in;
          `SFR_P1: p1 <= #1 data_in;
          `SFR_P2: p2 <= #1 data_in;
          `SFR_P3: p3 <= #1 data_in;
        endcase
      end
      2'b11: begin
        case (wr_addr[7:3])
//
// bit addressable
          `SFR_B_P0: p0[wr_addr[2:0]] <= #1 data_in;
          `SFR_B_P1: p1[wr_addr[2:0]] <= #1 data_in;
          `SFR_B_P2: p2[wr_addr[2:0]] <= #1 data_in;
          `SFR_B_P3: p3[wr_addr[2:0]] <= #1 data_in;
        endcase
      end
    endcase
end

endmodule

