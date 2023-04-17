//////////////////////////////////////////////////////////////////////
////                                                              ////
////  8051 data ram                                               ////
////                                                              ////
////  This file is part of the 8051 cores project                 ////
////  http://www.opencores.org/cores/8051/                        ////
////                                                              ////
////  Description                                                 ////
////   data ram                                                   ////
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


module ram (rst, clk, rd_addr, rd_data, wr_addr, wr_bit, wr_data, wr, bit_data_in, bit_data_out);
// clk          clock
// rst          reset
// rd_addr      read addres
// rd_data      read data
// wr_addr      write addres
// wr_bit       write bit addresable
// wr_data      write data
// wr           write
// bti_data_in  bit data input
// bti_data_out bit data output


input rst, clk, wr, wr_bit, bit_data_in;
input [7:0] rd_addr, wr_addr, wr_data;
output rd_data, bit_data_out;

reg bit_data, bit_data_out;
reg [7:0] rd_data;

//
// buffer
reg [2048:0] buff;


always @(posedge clk)
begin
  if (rst)
  begin
//
// set reset values of specila function registers
    buff [{`SFR_ACC, 3'b111}:{`SFR_ACC, 3'b000}] <= #1 `RST_ACC;
    buff [{`SFR_B, 3'b111}:{`SFR_B, 3'b000}] <= #1 `RST_B;
    buff [{`SFR_PSW, 3'b111}:{`SFR_PSW, 3'b000}] <= #1 `RST_PSW;
    buff [{`SFR_P0, 3'b111}:{`SFR_P0, 3'b000}] <= #1 `RST_P0;
    buff [{`SFR_P1, 3'b111}:{`SFR_P1, 3'b000}] <= #1 `RST_P1;
    buff [{`SFR_P2, 3'b111}:{`SFR_P2, 3'b000}] <= #1 `RST_P2;
    buff [{`SFR_P3, 3'b111}:{`SFR_P3, 3'b000}] <= #1 `RST_P3;
    buff [{`SFR_DPTR_LO, 3'b111}:{`SFR_DPTR_LO, 3'b000}] <= #1 `RST_DPL;
    buff [{`SFR_DPTR_HI, 3'b111}:{`SFR_DPTR_HI, 3'b000}] <= #1 `RST_DPH;
    buff [{`SFR_IP, 3'b111}:{`SFR_IP, 3'b000}] <= #1 `RST_IP;
    buff [{`SFR_IE, 3'b111}:{`SFR_IE, 3'b000}] <= #1 `RST_IE;
    buff [{`SFR_TMOD, 3'b111}:{`SFR_TMOD, 3'b000}] <= #1 `RST_TMOD;
    buff [{`SFR_TCON, 3'b111}:{`SFR_TCON, 3'b000}] <= #1 `RST_TCON;
    buff [{`SFR_TH0, 3'b111}:{`SFR_TH0, 3'b000}] <= #1 `RST_TH0;
    buff [{`SFR_TL0, 3'b111}:{`SFR_TL0, 3'b000}] <= #1 `RST_TL0;
    buff [{`SFR_TH1, 3'b111}:{`SFR_TH1, 3'b000}] <= #1 `RST_TH1;
    buff [{`SFR_TL1, 3'b111}:{`SFR_TL1, 3'b000}] <= #1 `RST_TL1;
    buff [{`SFR_SCON, 3'b111}:{`SFR_SCON, 3'b000}] <= #1 `RST_SCON;

  end else if (wr)
//
//case of writing to ram
  begin
    if (wr_bit)
    begin
//
// write bit addressable
      if (wr_addr[7])
//
//sfr's;  high address area -- h80:hff
        buff [{wr_addr[7:3], 3'b000, wr_addr[2:0]}] <= #1 bit_data_in;
      else
//
//bit addressable segment -- h00:h7f
        buff [{3'b001, wr_addr}] <= #1 bit_data_in;

    end else begin
//
// write byte addressable
      buff [{wr_addr, 3'b000}] <= #1 wr_data[0];
      buff [{wr_addr, 3'b001}] <= #1 wr_data[1];
      buff [{wr_addr, 3'b010}] <= #1 wr_data[2];
      buff [{wr_addr, 3'b011}] <= #1 wr_data[3];
      buff [{wr_addr, 3'b100}] <= #1 wr_data[4];
      buff [{wr_addr, 3'b101}] <= #1 wr_data[5];
      buff [{wr_addr, 3'b110}] <= #1 wr_data[6];
      buff [{wr_addr, 3'b111}] <= #1 wr_data[7];
    end
  end
end

//
// reading from ram
always @(posedge clk)
begin
//
// case that we want to write and read fron same address
  if ((rd_addr == wr_addr) & wr)
  begin
    rd_data <= #1 wr_data;
    bit_data_out <= #1 bit_data_in;
  end else begin
//
// normal read
    rd_data[0] <= #1 buff [{rd_addr, 3'b000}];
    rd_data[1] <= #1 buff [{rd_addr, 3'b001}];
    rd_data[2] <= #1 buff [{rd_addr, 3'b010}];
    rd_data[3] <= #1 buff [{rd_addr, 3'b011}];
    rd_data[4] <= #1 buff [{rd_addr, 3'b100}];
    rd_data[5] <= #1 buff [{rd_addr, 3'b101}];
    rd_data[6] <= #1 buff [{rd_addr, 3'b110}];
    rd_data[7] <= #1 buff [{rd_addr, 3'b111}];

//
// bit addresable read
    if (wr_addr[7])
//
//sfr's;  high address area -- h80:hff
      bit_data_out <= #1 buff [{rd_addr[7:3], 3'b000, rd_addr[2:0]}];
    else
//
//bit addressable segment -- h00:h7f
      bit_data_out <= #1 buff [{3'b001, rd_addr}];

  end
end


endmodule