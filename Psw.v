//////////////////////////////////////////////////////////////////////
////                                                              ////
////  8051 program status word                                    ////
////                                                              ////
////  This file is part of the 8051 cores project                 ////
////  http://www.opencores.org/cores/8051/                        ////
////                                                              ////
////  Description                                                 ////
////   program status word                                        ////
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

module psw (clk, rst, addr, bit_in, data_in, wr, wr_bit, data_out, p, cy_in, ac_in, ov_in, set);

// clk          clock
// rst          reset
// addr         write address (if is addres of sp and white high must be written to sp)
// bit_in       bit input
// data_in      data input (from alu destiantion 1)
// wr           write
// wr_bit       write bit addresable
// data_out     data output
// p            parity (input from acc)
// cy_in        input bit data (carry from alu)
// ac_in        ac from alu
// ov_in        overflov input from alu
// set          set psw (write to caryy, carry and overflov or carry, owerflov and ac)


input clk, rst, wr, p, cy_in, ac_in, ov_in, bit_in, wr_bit;
input [1:0] set;
input [7:0] addr, data_in;

output data_out;

reg [7:0] data_out;

//
//case writing to psw
always @(posedge clk)
begin
  if (rst)
    data_out <= #1 `RST_PSW;
  else begin
    casex ({wr, wr_bit, set})
      5'b10xxx: begin
//
// write to psw (byte addressable)
        if (addr==`SFR_PSW)
          data_out <= #1 data_in;
      end
      5'b11xxx: begin
//
// write to psw (bit addressable)
        if (addr[7:3]==`SFR_B_ACC)
          data_out[addr[2:0]] <= #1 cy_in;
      end
      {2'b00, `PS_CY}: begin
//
//write carry
          data_out[7] <= #1 cy_in;
          data_out[0] <= #1 p;
        end
      {2'b00, `PS_OV}: begin
//
//write carry and overflov
          data_out[7] <= #1 cy_in;
          data_out[2] <= #1 ov_in;
          data_out[0] <= #1 p;
        end
      {2'b00, `PS_AC}:begin
//
//write carry, overflov and ac
          data_out[7] <= #1 cy_in;
          data_out[6] <= #1 ac_in;
          data_out[2] <= #1 ov_in;
          data_out[0] <= #1 p;
        end
//
// write parity
      default: data_out[0] <= #1 p;
    endcase
  end
end


endmodule
