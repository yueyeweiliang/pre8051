//////////////////////////////////////////////////////////////////////
////                                                              ////
////  8051 ram select                                             ////
////                                                              ////
////  This file is part of the 8051 cores project                 ////
////  http://www.opencores.org/cores/8051/                        ////
////                                                              ////
////  Description                                                 ////
////   Multiplexer wiht whitch we select data send to alu source  ////
////   select.                                                    ////
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

module ram_sel (addr, bit_in, in_ram, psw, acc, dptr_hi, port0, port1, port2, port3, bit_out, out_data);
// addr         address
// bit_in       bit input (from ram)
// in_ram       imput from ram
// psw          program status word input
// acc          accumulator input
// dptr_hi      data pointer high bits input
// port0, port1, port2, port3   ports input
// bit_out      bit output
// out_data     data (byte) output


input bit_in;
input [7:0] addr, in_ram, psw, acc, dptr_hi, port0, port1, port2, port3;
output out_data, bit_out;

reg bit_out;
reg [7:0] out_data;


//
//set output in case of address (byte)
always @(addr or in_ram or psw or acc or dptr_hi or port0 or port1 or port2 or port3)
begin
  case (addr)
    `SFR_ACC: out_data = acc;
    `SFR_PSW: out_data = psw;
    `SFR_P0: out_data = port0;
    `SFR_P1: out_data = port1;
    `SFR_P2: out_data = port2;
    `SFR_P3: out_data = port3;
    `SFR_DPTR_HI: out_data = dptr_hi;
    default: out_data = in_ram;
  endcase
end


//
//set output in case of address (bit)
always @(addr or bit_in or psw or acc or port0 or port1 or port2 or port3)
begin
  case (addr[7:3])
    `SFR_B_ACC: bit_out = acc[addr[2:0]];
    `SFR_B_PSW: bit_out = psw[addr[2:0]];
    `SFR_B_P0: bit_out = port0[addr[2:0]];
    `SFR_B_P1: bit_out = port1[addr[2:0]];
    `SFR_B_P2: bit_out = port2[addr[2:0]];
    `SFR_B_P3: bit_out = port3[addr[2:0]];
    default: bit_out = bit_in;
  endcase

end

endmodule