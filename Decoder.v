//////////////////////////////////////////////////////////////////////
////                                                              ////
////  8051 core decoder                                           ////
////                                                              ////
////  This file is part of the 8051 cores project                 ////
////  http://www.opencores.org/cores/8051/                        ////
////                                                              ////
////  Description                                                 ////
////   Main 8051 core module. decodes instruction and creates     ////
////   control sigals.                                            ////
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



module decoder (clk, rst, op_in, ram_rd_sel, ram_wr_sel, wr_bit, wr, src_sel1, src_sel2, src_sel3, alu_op, psw_set, cy_sel, imm_sel, pc_wr, pc_sel,
                comp_sel, eq, rom_addr_sel, ext_addr_sel, wad2, rd, write_x, reti);

// clk          clock
// rst          reset
// op_in        operation code
// ram_rd_sel   select, whitch address will be send to ram for read
// ram_wr_sel   select, whitch address will be send to ram for write
// wr           write - if 1 then we will write to ram
// src_sel1     select alu source 1
// src_sel2     select alu source 2
// src_sel3     select alu source 3
// alu_op       alu operation
// psw_set      will we remember cy, ac, ov from alu
// cy_sel       carry in alu select
// comp_sel     compare source select
// eq   compare result
// wr_bit       if write bit addresable
// wad2         wrihe acc from destination 2
// imm_sel      immediate select
// pc_wr        pc write
// pc_sel       pc select
// rom_addr_sel rom address select (alu destination or pc)
// ext_addr_sel external address select (dptr or Ri)
// rd           read from rom
// write_x      write to external rom
// reti         return from interrupt


input clk, rst, eq;
input [7:0] op_in;
output ram_rd_sel, ram_wr_sel, src_sel1, src_sel2, psw_set, alu_op, cy_sel, imm_sel, wr, pc_wr, pc_sel, comp_sel, wr_bit;
output src_sel3, rom_addr_sel, ext_addr_sel, wad2, rd, reti, write_x;

reg reti, write_x;
reg [1:0] psw_set, ram_rd_sel, src_sel1, src_sel2, imm_sel, pc_sel, cy_sel;
reg [3:0] alu_op;
reg wr,  wr_bit, src_sel3, rom_addr_sel, ext_addr_sel, pc_wr, wad2;
reg [2:0] comp_sel, ram_wr_sel;

//
// state        if 2'b00 then normal execution, sle instructin that need more than one clock
// op           instruction buffer
reg [1:0] state;
reg [7:0] op;

//
// if state = 2'b00 then read nex instruction
assign rd = !state[0] & !state[1];

//
// main block
// case of instruction set control signals
always @(rst or op_in or eq or state)
begin
  if (rst) begin
    ram_rd_sel = 2'bxx;
    ram_wr_sel = `RWS_DC;
    src_sel1 = `ASS_DC;
    src_sel2 = `ASS_DC;
    alu_op = `ALU_NOP;
    imm_sel = `IDS_DC;
    wr = 1'b0;
    psw_set = `PS_NOT;
    cy_sel = `CY_0;
    pc_wr = `PCW_N;
    pc_sel = `PIS_DC;
    comp_sel = `CSS_DC;
    wr_bit = 1'b0;
    src_sel3 = `AS3_DC;
    rom_addr_sel = `RAS_PC;
    ext_addr_sel = `EAS_DC;
    wad2 = `WAD_N;
  end else begin
    case (state)
      2'b01: begin
    casex (op)
      `ACALL :begin
          ram_rd_sel = 2'bxx;
          ram_wr_sel = `RWS_SP;
          src_sel1 = `ASS_IMM;
          src_sel2 = 2'bxx;
          alu_op = `ALU_NOP;
          imm_sel = `IDS_PCH;
          wr = 1'b1;
          psw_set = `PS_NOT;
          cy_sel = `CY_0;
          pc_wr = `PCW_N;
          pc_sel = `PIS_DC;
          comp_sel = `CSS_DC;
          src_sel3 = `AS3_DC;
          comp_sel = `CSS_DC;
          wr_bit = 1'b0;
          wad2 = `WAD_N;
          rom_addr_sel = `RAS_PC;
          ext_addr_sel = `EAS_DC;
        end
      `AJMP : begin
          ram_rd_sel = 2'bxx;
          ram_wr_sel = `RWS_DC;
          src_sel1 = `ASS_DC;
          src_sel2 = 2'bxx;
          alu_op = `ALU_NOP;
          imm_sel = `IDS_DC;
          wr = 1'b0;
          psw_set = `PS_NOT;
          cy_sel = `CY_0;
          pc_wr = `PCW_N;
          pc_sel = `PIS_DC;
          comp_sel = `CSS_DC;
          src_sel3 = `AS3_DC;
          comp_sel = `CSS_DC;
          wr_bit = 1'b0;
          wad2 = `WAD_N;
          rom_addr_sel = `RAS_PC;
          ext_addr_sel = `EAS_DC;
        end
      `LCALL :begin
          ram_rd_sel = 2'bxx;
          ram_wr_sel = `RWS_SP;
          src_sel1 = `ASS_IMM;
          src_sel2 = 2'bxx;
          alu_op = `ALU_NOP;
          imm_sel = `IDS_PCH;
          wr = 1'b1;
          psw_set = `PS_NOT;
          cy_sel = `CY_0;
          pc_wr = `PCW_N;
          pc_sel = `PIS_DC;
          comp_sel = `CSS_DC;
          src_sel3 = `AS3_DC;
          comp_sel = `CSS_DC;
          wr_bit = 1'b0;
          wad2 = `WAD_N;
          rom_addr_sel = `RAS_PC;
          ext_addr_sel = `EAS_DC;
        end
      default begin
          ram_rd_sel = `RRS_DC;
          ram_wr_sel = `RWS_DC;
          src_sel1 = `ASS_DC;
          src_sel2 = `ASS_DC;
          alu_op = `ALU_NOP;
          wr = 1'b0;
          psw_set = `PS_NOT;
          cy_sel = `CY_0;
          pc_wr = `PCW_N;
          pc_sel = `PIS_DC;
          imm_sel = `IDS_DC;
          src_sel3 = `AS3_DC;
          comp_sel = `CSS_DC;
          wr_bit = 1'b0;
          wad2 = `WAD_N;
          rom_addr_sel = `RAS_PC;
          ext_addr_sel = `EAS_DC;
      end
    endcase
    end
    2'b10:
    casex (op)
      `CJNE_R : begin
          ram_rd_sel = `RRS_DC;
          ram_wr_sel = `RWS_DC;
          src_sel1 = `ASS_DC;
          src_sel2 = `ASS_DC;
          alu_op = `ALU_NOP;
          wr = 1'b0;
          psw_set = `PS_NOT;
          cy_sel = `CY_0;
          pc_wr = !eq;
          pc_sel = `PIS_ALU;
          imm_sel = `IDS_DC;
          src_sel3 = `AS3_DC;
          comp_sel = `CSS_DES;
          wr_bit = 1'b0;
          wad2 = `WAD_N;
          rom_addr_sel = `RAS_PC;
          ext_addr_sel = `EAS_DC;
        end
      `CJNE_I : begin
          ram_rd_sel = `RRS_DC;
          ram_wr_sel = `RWS_DC;
          src_sel1 = `ASS_DC;
          src_sel2 = `ASS_DC;
          alu_op = `ALU_NOP;
          wr = 1'b0;
          psw_set = `PS_NOT;
          cy_sel = `CY_0;
          pc_wr = !eq;
          pc_sel = `PIS_ALU;
          imm_sel = `IDS_DC;
          src_sel3 = `AS3_DC;
          comp_sel = `CSS_DES;
          wr_bit = 1'b0;
          wad2 = `WAD_N;
          rom_addr_sel = `RAS_PC;
          ext_addr_sel = `EAS_DC;
        end
      `CJNE_D : begin
          ram_rd_sel = `RRS_DC;
          ram_wr_sel = `RWS_DC;
          src_sel1 = `ASS_DC;
          src_sel2 = `ASS_DC;
          alu_op = `ALU_NOP;
          wr = 1'b0;
          psw_set = `PS_NOT;
          cy_sel = `CY_0;
          pc_wr = !eq;
          pc_sel = `PIS_ALU;
          imm_sel = `IDS_DC;
          src_sel3 = `AS3_DC;
          comp_sel = `CSS_DES;
          wr_bit = 1'b0;
          wad2 = `WAD_N;
          rom_addr_sel = `RAS_PC;
          ext_addr_sel = `EAS_DC;
        end
      `CJNE_C : begin
          ram_rd_sel = `RRS_DC;
          ram_wr_sel = `RWS_DC;
          src_sel1 = `ASS_DC;
          src_sel2 = `ASS_DC;
          alu_op = `ALU_NOP;
          wr = 1'b0;
          psw_set = `PS_NOT;
          cy_sel = `CY_0;
          pc_wr = !eq;
          pc_sel = `PIS_ALU;
          imm_sel = `IDS_DC;
          src_sel3 = `AS3_DC;
          comp_sel = `CSS_DES;
          wr_bit = 1'b0;
          wad2 = `WAD_N;
          rom_addr_sel = `RAS_PC;
          ext_addr_sel = `EAS_DC;
        end
      `DJNZ_R : begin
          ram_rd_sel = `RRS_DC;
          ram_wr_sel = `RWS_DC;
          src_sel1 = `ASS_DC;
          src_sel2 = `ASS_DC;
          alu_op = `ALU_NOP;
          wr = 1'b0;
          psw_set = `PS_NOT;
          cy_sel = `CY_0;
          pc_wr = eq;
          pc_sel = `PIS_ALU;
          imm_sel = `IDS_DC;
          src_sel3 = `AS3_DC;
          comp_sel = `CSS_DES;
          wr_bit = 1'b0;
          wad2 = `WAD_N;
          rom_addr_sel = `RAS_PC;
          ext_addr_sel = `EAS_DC;
        end
      `DJNZ_D : begin
          ram_rd_sel = `RRS_DC;
          ram_wr_sel = `RWS_DC;
          src_sel1 = `ASS_DC;
          src_sel2 = `ASS_DC;
          alu_op = `ALU_NOP;
          wr = 1'b0;
          psw_set = `PS_NOT;
          cy_sel = `CY_0;
          pc_wr = eq;
          pc_sel = `PIS_ALU;
          imm_sel = `IDS_DC;
          src_sel3 = `AS3_DC;
          comp_sel = `CSS_DES;
          wr_bit = 1'b0;
          wad2 = `WAD_N;
          rom_addr_sel = `RAS_PC;
          ext_addr_sel = `EAS_DC;
        end
      `JB : begin
          ram_rd_sel = `RRS_DC;
          ram_wr_sel = `RWS_DC;
          src_sel1 = `ASS_DC;
          src_sel2 = `ASS_DC;
          alu_op = `ALU_NOP;
          wr = 1'b0;
          psw_set = `PS_NOT;
          cy_sel = `CY_0;
          pc_wr = eq;
          pc_sel = `PIS_ALU;
          imm_sel = `IDS_DC;
          src_sel3 = `AS3_DC;
          comp_sel = `CSS_BIT;
          wr_bit = 1'b0;
          wad2 = `WAD_N;
          rom_addr_sel = `RAS_PC;
          ext_addr_sel = `EAS_DC;
        end
      `JBC : begin
          ram_rd_sel = `RRS_DC;
          ram_wr_sel = `RWS_D;
          src_sel1 = `ASS_DC;
          src_sel2 = `ASS_DC;
          alu_op = `ALU_NOP;
          wr = 1'b1;
          psw_set = `PS_NOT;
          cy_sel = `CY_0;
          pc_wr = eq;
          pc_sel = `PIS_ALU;
          imm_sel = `IDS_DC;
          src_sel3 = `AS3_DC;
          comp_sel = `CSS_BIT;
          wr_bit = 1'b1;
          wad2 = `WAD_N;
          rom_addr_sel = `RAS_PC;
          ext_addr_sel = `EAS_DC;
        end
      `JC : begin
          ram_rd_sel = `RRS_DC;
          ram_wr_sel = `RWS_DC;
          src_sel1 = `ASS_DC;
          src_sel2 = `ASS_DC;
          alu_op = `ALU_NOP;
          wr = 1'b0;
          psw_set = `PS_NOT;
          cy_sel = `CY_0;
          pc_wr = eq;
          pc_sel = `PIS_ALU;
          imm_sel = `IDS_DC;
          src_sel3 = `AS3_DC;
          comp_sel = `CSS_CY;
          wr_bit = 1'b0;
          wad2 = `WAD_N;
          rom_addr_sel = `RAS_PC;
          ext_addr_sel = `EAS_DC;
        end
      `JMP : begin
          ram_rd_sel = `RRS_DC;
          ram_wr_sel = `RWS_DC;
          src_sel1 = `ASS_DC;
          src_sel2 = `ASS_DC;
          alu_op = `ALU_NOP;
          wr = 1'b0;
          psw_set = `PS_NOT;
          cy_sel = `CY_0;
          pc_wr = `PCW_Y;
          pc_sel = `PIS_ALU;
          imm_sel = `IDS_DC;
          src_sel3 = `AS3_DC;
          comp_sel = `CSS_BIT;
          wr_bit = 1'b0;
          wad2 = `WAD_N;
          rom_addr_sel = `RAS_PC;
          ext_addr_sel = `EAS_DC;
        end
      `JNB : begin
          ram_rd_sel = `RRS_DC;
          ram_wr_sel = `RWS_DC;
          src_sel1 = `ASS_DC;
          src_sel2 = `ASS_DC;
          alu_op = `ALU_NOP;
          wr = 1'b0;
          psw_set = `PS_NOT;
          cy_sel = `CY_0;
          pc_wr = !eq;
          pc_sel = `PIS_ALU;
          imm_sel = `IDS_DC;
          src_sel3 = `AS3_DC;
          comp_sel = `CSS_BIT;
          wr_bit = 1'b0;
          wad2 = `WAD_N;
          rom_addr_sel = `RAS_PC;
          ext_addr_sel = `EAS_DC;
        end
      `JNC : begin
          ram_rd_sel = `RRS_DC;
          ram_wr_sel = `RWS_DC;
          src_sel1 = `ASS_DC;
          src_sel2 = `ASS_DC;
          alu_op = `ALU_NOP;
          wr = 1'b0;
          psw_set = `PS_NOT;
          cy_sel = `CY_0;
          pc_wr = !eq;
          pc_sel = `PIS_ALU;
          imm_sel = `IDS_DC;
          src_sel3 = `AS3_DC;
          comp_sel = `CSS_CY;
          wr_bit = 1'b0;
          wad2 = `WAD_N;
          rom_addr_sel = `RAS_PC;
          ext_addr_sel = `EAS_DC;
        end
      `JNZ : begin
          ram_rd_sel = `RRS_DC;
          ram_wr_sel = `RWS_DC;
          src_sel1 = `ASS_DC;
          src_sel2 = `ASS_DC;
          alu_op = `ALU_NOP;
          wr = 1'b0;
          psw_set = `PS_NOT;
          cy_sel = `CY_0;
          pc_wr = !eq;
          pc_sel = `PIS_ALU;
          imm_sel = `IDS_DC;
          src_sel3 = `AS3_DC;
          comp_sel = `CSS_AZ;
          wr_bit = 1'b0;
          wad2 = `WAD_N;
          rom_addr_sel = `RAS_PC;
          ext_addr_sel = `EAS_DC;
        end
      `JZ : begin
          ram_rd_sel = `RRS_DC;
          ram_wr_sel = `RWS_DC;
          src_sel1 = `ASS_DC;
          src_sel2 = `ASS_DC;
          alu_op = `ALU_NOP;
          wr = 1'b0;
          psw_set = `PS_NOT;
          cy_sel = `CY_0;
          pc_wr = eq;
          pc_sel = `PIS_ALU;
          imm_sel = `IDS_DC;
          src_sel3 = `AS3_DC;
          comp_sel = `CSS_AZ;
          wr_bit = 1'b0;
          wad2 = `WAD_N;
          rom_addr_sel = `RAS_PC;
          ext_addr_sel = `EAS_DC;
        end
      `MOVC_DP :begin
          ram_rd_sel = `RRS_DC;
          ram_wr_sel = `RWS_DC;
          src_sel1 = `ASS_DC;
          src_sel2 = `ASS_DC;
          alu_op = `ALU_NOP;
          wr = 1'b0;
          psw_set = `PS_NOT;
          cy_sel = `CY_0;
          pc_wr = `PCW_N;
          pc_sel = `PIS_DC;
          imm_sel = 2'bxx;
          src_sel3 = `AS3_DP;
          comp_sel = `CSS_DC;
          wr_bit = 1'b0;
          wad2 = `WAD_Y;
          rom_addr_sel = `RAS_DES;
          ext_addr_sel = `EAS_DC;
        end
      `MOVC_PC :begin
          ram_rd_sel = `RRS_DC;
          ram_wr_sel = `RWS_DC;
          src_sel1 = `ASS_DC;
          src_sel2 = `ASS_DC;
          alu_op = `ALU_NOP;
          wr = 1'b0;
          psw_set = `PS_NOT;
          cy_sel = `CY_0;
          pc_wr = `PCW_N;
          pc_sel = `PIS_DC;
          imm_sel = 2'bxx;
          src_sel3 = `AS3_DP;
          comp_sel = `CSS_DC;
          wr_bit = 1'b0;
          wad2 = `WAD_Y;
          rom_addr_sel = `RAS_DES;
          ext_addr_sel = `EAS_DC;
        end
      `SJMP : begin
          ram_rd_sel = `RRS_DC;
          ram_wr_sel = `RWS_DC;
          src_sel1 = `ASS_DC;
          src_sel2 = `ASS_DC;
          alu_op = `ALU_NOP;
          wr = 1'b0;
          psw_set = `PS_NOT;
          cy_sel = `CY_0;
          pc_wr = `PCW_Y;
          pc_sel = `PIS_ALU;
          imm_sel = `IDS_DC;
          src_sel3 = `AS3_DC;
          comp_sel = `CSS_DC;
          wr_bit = 1'b0;
          wad2 = `WAD_N;
          rom_addr_sel = `RAS_PC;
          ext_addr_sel = `EAS_DC;
        end
      default begin
          ram_rd_sel = `RRS_DC;
          ram_wr_sel = `RWS_DC;
          src_sel1 = `ASS_DC;
          src_sel2 = `ASS_DC;
          alu_op = `ALU_NOP;
          wr = 1'b0;
          psw_set = `PS_NOT;
          cy_sel = `CY_0;
          pc_wr = `PCW_N;
          pc_sel = `PIS_DC;
          imm_sel = `IDS_DC;
          src_sel3 = `AS3_DC;
          comp_sel = `CSS_DC;
          wr_bit = 1'b0;
          wad2 = `WAD_N;
          rom_addr_sel = `RAS_PC;
          ext_addr_sel = `EAS_DC;
      end
    endcase

    2'b11:
    casex (op)
      `CJNE_R : begin
          ram_rd_sel = `RRS_DC;
          ram_wr_sel = `RWS_DC;
          src_sel1 = `ASS_IMM;
          src_sel2 = `ASS_OP2;
          alu_op = `ALU_PCS;
          wr = 1'b0;
          psw_set = `PS_NOT;
          cy_sel = `CY_0;
          pc_wr = `PCW_N;
          pc_sel = `PIS_DC;
          imm_sel = `IDS_OP3;
          src_sel3 = `AS3_PC;
          comp_sel = `CSS_DC;
          wr_bit = 1'b0;
          wad2 = `WAD_N;
          rom_addr_sel = `RAS_PC;
          ext_addr_sel = `EAS_DC;
        end
      `CJNE_I : begin
          ram_rd_sel = `RRS_DC;
          ram_wr_sel = `RWS_DC;
          src_sel1 = `ASS_IMM;
          src_sel2 = `ASS_OP2;
          alu_op = `ALU_PCS;
          wr = 1'b0;
          psw_set = `PS_NOT;
          cy_sel = `CY_0;
          pc_wr = `PCW_N;
          pc_sel = `PIS_DC;
          imm_sel = `IDS_OP3;
          src_sel3 = `AS3_PC;
          comp_sel = `CSS_DC;
          wr_bit = 1'b0;
          wad2 = `WAD_N;
          rom_addr_sel = `RAS_PC;
          ext_addr_sel = `EAS_DC;
        end
      `CJNE_D : begin
          ram_rd_sel = `RRS_DC;
          ram_wr_sel = `RWS_DC;
          src_sel1 = `ASS_IMM;
          src_sel2 = `ASS_OP2;
          alu_op = `ALU_PCS;
          wr = 1'b0;
          psw_set = `PS_NOT;
          cy_sel = `CY_0;
          pc_wr = `PCW_N;
          pc_sel = `PIS_DC;
          imm_sel = `IDS_OP3;
          src_sel3 = `AS3_PC;
          comp_sel = `CSS_DC;
          wr_bit = 1'b0;
          wad2 = `WAD_N;
          rom_addr_sel = `RAS_PC;
          ext_addr_sel = `EAS_DC;
        end
      `CJNE_C : begin
          ram_rd_sel = `RRS_DC;
          ram_wr_sel = `RWS_DC;
          src_sel1 = `ASS_IMM;
          src_sel2 = `ASS_OP2;
          alu_op = `ALU_PCS;
          wr = 1'b0;
          psw_set = `PS_NOT;
          cy_sel = `CY_0;
          pc_wr = `PCW_N;
          pc_sel = `PIS_DC;
          imm_sel = `IDS_OP3;
          src_sel3 = `AS3_PC;
          comp_sel = `CSS_DC;
          wr_bit = 1'b0;
          wad2 = `WAD_N;
          rom_addr_sel = `RAS_PC;
          ext_addr_sel = `EAS_DC;
        end
      `DJNZ_R : begin
          ram_rd_sel = `RRS_DC;
          ram_wr_sel = `RWS_DC;
          src_sel1 = `ASS_IMM;
          src_sel2 = `ASS_OP2;
          alu_op = `ALU_PCS;
          wr = 1'b0;
          psw_set = `PS_NOT;
          cy_sel = `CY_0;
          pc_wr = `PCW_N;
          pc_sel = `PIS_DC;
          imm_sel = `IDS_OP2;
          src_sel3 = `AS3_PC;
          comp_sel = `CSS_DC;
          wr_bit = 1'b0;
          wad2 = `WAD_N;
          rom_addr_sel = `RAS_PC;
          ext_addr_sel = `EAS_DC;
        end
      `DJNZ_D : begin
          ram_rd_sel = `RRS_DC;
          ram_wr_sel = `RWS_DC;
          src_sel1 = `ASS_IMM;
          src_sel2 = `ASS_OP2;
          alu_op = `ALU_PCS;
          wr = 1'b0;
          psw_set = `PS_NOT;
          cy_sel = `CY_0;
          pc_wr = `PCW_N;
          pc_sel = `PIS_DC;
          imm_sel = `IDS_OP3;
          src_sel3 = `AS3_PC;
          comp_sel = `CSS_DC;
          wr_bit = 1'b0;
          wad2 = `WAD_N;
          rom_addr_sel = `RAS_PC;
          ext_addr_sel = `EAS_DC;
        end
      `RET : begin
          ram_rd_sel = `RRS_SP;
          ram_wr_sel = `RWS_DC;
          src_sel1 = `ASS_RAM;
          src_sel2 = `ASS_DC;
          alu_op = `ALU_NOP;
          wr = 1'b0;
          psw_set = `PS_NOT;
          cy_sel = `CY_0;
          pc_wr = `PCW_Y;
          pc_sel = `PIS_SP;
          imm_sel = `IDS_DC;
          src_sel3 = `AS3_DC;
          comp_sel = `CSS_DC;
          wr_bit = 1'b0;
          wad2 = `WAD_N;
          rom_addr_sel = `RAS_PC;
          ext_addr_sel = `EAS_DC;
        end
      `RETI : begin
          ram_rd_sel = `RRS_SP;
          ram_wr_sel = `RWS_DC;
          src_sel1 = `ASS_RAM;
          src_sel2 = `ASS_DC;
          alu_op = `ALU_NOP;
          wr = 1'b0;
          psw_set = `PS_NOT;
          cy_sel = `CY_0;
          pc_wr = `PCW_Y;
          pc_sel = `PIS_SP;
          imm_sel = `IDS_DC;
          src_sel3 = `AS3_DC;
          comp_sel = `CSS_DC;
          wr_bit = 1'b0;
          wad2 = `WAD_N;
          rom_addr_sel = `RAS_PC;
          ext_addr_sel = `EAS_DC;
        end
      default begin
          ram_rd_sel = `RRS_DC;
          ram_wr_sel = `RWS_DC;
          src_sel1 = `ASS_DC;
          src_sel2 = `ASS_DC;
          alu_op = `ALU_NOP;
          wr = 1'b0;
          psw_set = `PS_NOT;
          cy_sel = `CY_0;
          pc_wr = `PCW_N;
          pc_sel = `PIS_DC;
          imm_sel = `IDS_DC;
          src_sel3 = `AS3_DC;
          comp_sel = `CSS_DC;
          wr_bit = 1'b0;
          wad2 = `WAD_N;
          rom_addr_sel = `RAS_PC;
          ext_addr_sel = `EAS_DC;
      end
    endcase
    default: begin
    casex (op_in)
      `ACALL :begin
          ram_rd_sel = 2'bxx;
          ram_wr_sel = `RWS_SP;
          src_sel1 = `ASS_IMM;
          src_sel2 = 2'bxx;
          alu_op = `ALU_NOP;
          imm_sel = `IDS_PCL;
          wr = 1'b1;
          psw_set = `PS_NOT;
          cy_sel = `CY_0;
          pc_wr = `PCW_Y;
          pc_sel = `PIS_I11;
          src_sel3 = `AS3_DC;
          comp_sel = `CSS_DC;
          wr_bit = 1'b0;
          wad2 = `WAD_N;
          rom_addr_sel = `RAS_PC;
          ext_addr_sel = `EAS_DC;
        end
      `AJMP : begin
          ram_rd_sel = 2'bxx;
          ram_wr_sel = 2'bxx;
          src_sel1 = 2'bxx;
          src_sel2 = 2'bxx;
          alu_op = 4'bxxxx;
          imm_sel = 2'bxx;
          wr = 1'b0;
          psw_set = `PS_NOT;
          cy_sel = `CY_0;
          pc_wr = `PCW_Y;
          pc_sel = `PIS_I11;
          src_sel3 = `AS3_DC;
          comp_sel = `CSS_DC;
          wr_bit = 1'b0;
          wad2 = `WAD_N;
          rom_addr_sel = `RAS_PC;
          ext_addr_sel = `EAS_DC;
        end


      `ADD_R : begin
	  ram_rd_sel = `RRS_RN;
	  ram_wr_sel = `RWS_ACC;
	  src_sel1 = `ASS_ACC;
	  src_sel2 = `ASS_RAM;
	  alu_op = `ALU_ADD;
          wr = 1'b1;
	  psw_set = `PS_AC;
	  cy_sel = `CY_0;
          pc_wr = `PCW_N;
          pc_sel = `PIS_DC;
          imm_sel = 2'bxx;
          src_sel3 = `AS3_DC;
          comp_sel = `CSS_DC;
          wr_bit = 1'b0;
          wad2 = `WAD_N;
          rom_addr_sel = `RAS_PC;
          ext_addr_sel = `EAS_DC;
        end
      `ADDC_R : begin
	  ram_rd_sel = `RRS_RN;
	  ram_wr_sel = `RWS_ACC;
	  src_sel1 = `ASS_ACC;
	  src_sel2 = `ASS_RAM;
	  alu_op = `ALU_ADD;
          wr = 1'b1;
	  psw_set = `PS_AC;
	  cy_sel = `CY_PSW;
          pc_wr = `PCW_N;
          pc_sel = `PIS_DC;
          imm_sel = 2'bxx;
          src_sel3 = `AS3_DC;
          comp_sel = `CSS_DC;
          wr_bit = 1'b0;
          wad2 = `WAD_N;
          rom_addr_sel = `RAS_PC;
          ext_addr_sel = `EAS_DC;
        end
      `ANL_R : begin
          ram_rd_sel = `RRS_RN;
          ram_wr_sel = `RWS_ACC;
          src_sel1 = `ASS_ACC;
          src_sel2 = `ASS_RAM;
          alu_op = `ALU_AND;
          wr = 1'b1;
          psw_set = `PS_NOT;
          cy_sel = `CY_0;
          pc_wr = `PCW_N;
          pc_sel = `PIS_DC;
          imm_sel = 2'bxx;
          src_sel3 = `AS3_DC;
          comp_sel = `CSS_DC;
          wr_bit = 1'b0;
          wad2 = `WAD_N;
          rom_addr_sel = `RAS_PC;
          ext_addr_sel = `EAS_DC;
        end
      `CJNE_R : begin
          ram_rd_sel = `RRS_RN;
          ram_wr_sel = `RWS_DC;
          src_sel1 = `ASS_IMM;
          src_sel2 = `ASS_RAM;
          alu_op = `ALU_SUB;
          wr = 1'b0;
          psw_set = `PS_CY;
          cy_sel = `CY_0;
          pc_wr = `PCW_N;
          pc_sel = `PIS_DC;
          imm_sel = `IDS_OP2;
          src_sel3 = `AS3_DC;
          comp_sel = `CSS_DC;
          wr_bit = 1'b0;
          wad2 = `WAD_N;
          rom_addr_sel = `RAS_PC;
          ext_addr_sel = `EAS_DC;
        end
      `DEC_R : begin
          ram_rd_sel = `RRS_RN;
          ram_wr_sel = `RWS_RN;
          src_sel1 = `ASS_RAM;
          src_sel2 = `ASS_ZERO;
          alu_op = `ALU_SUB;
          wr = 1'b1;
          psw_set = `PS_NOT;
          cy_sel = `CY_1;
          pc_wr = `PCW_N;
          pc_sel = `PIS_DC;
          imm_sel = `IDS_DC;
          src_sel3 = `AS3_DC;
          comp_sel = `CSS_DC;
          wr_bit = 1'b0;
          wad2 = `WAD_N;
          rom_addr_sel = `RAS_PC;
          ext_addr_sel = `EAS_DC;
        end
      `DJNZ_R : begin
          ram_rd_sel = `RRS_RN;
          ram_wr_sel = `RWS_RN;
          src_sel1 = `ASS_RAM;
          src_sel2 = `ASS_ZERO;
          alu_op = `ALU_SUB;
          wr = 1'b1;
          psw_set = `PS_NOT;
          cy_sel = `CY_1;
          pc_wr = `PCW_N;
          pc_sel = `PIS_DC;
          imm_sel = 2'bxx;
          src_sel3 = `AS3_DC;
          comp_sel = `CSS_DC;
          wr_bit = 1'b0;
          wad2 = `WAD_N;
          rom_addr_sel = `RAS_PC;
          ext_addr_sel = `EAS_DC;
        end
      `INC_R : begin
          ram_rd_sel = `RRS_RN;
          ram_wr_sel = `RWS_RN;
          src_sel1 = `ASS_RAM;
          src_sel2 = `ASS_ZERO;
          alu_op = `ALU_ADD;
          wr = 1'b1;
          psw_set = `PS_NOT;
          cy_sel = `CY_1;
          pc_wr = `PCW_N;
          pc_sel = `PIS_DC;
          imm_sel = `IDS_DC;
          src_sel3 = `AS3_DC;
          comp_sel = `CSS_DC;
          wr_bit = 1'b0;
          wad2 = `WAD_N;
          rom_addr_sel = `RAS_PC;
          ext_addr_sel = `EAS_DC;
        end
      `MOV_R : begin
          ram_rd_sel = `RRS_RN;
          ram_wr_sel = `RWS_ACC;
          src_sel1 = `ASS_RAM;
          src_sel2 = `ASS_DC;
          alu_op = `ALU_NOP;
          wr = 1'b1;
          psw_set = `PS_NOT;
          cy_sel = `CY_0;
          pc_wr = `PCW_N;
          pc_sel = `PIS_DC;
          imm_sel = `IDS_DC;
          src_sel3 = `AS3_DC;
          comp_sel = `CSS_DC;
          wr_bit = 1'b0;
          wad2 = `WAD_N;
          rom_addr_sel = `RAS_PC;
          ext_addr_sel = `EAS_DC;
        end
      `MOV_AR : begin
          ram_rd_sel = `RRS_DC;
          ram_wr_sel = `RWS_RN;
          src_sel1 = `ASS_ACC;
          src_sel2 = `ASS_DC;
          alu_op = `ALU_NOP;
          wr = 1'b1;
          psw_set = `PS_NOT;
          cy_sel = `CY_0;
          pc_wr = `PCW_N;
          pc_sel = `PIS_DC;
          imm_sel = `IDS_DC;
          src_sel3 = `AS3_DC;
          comp_sel = `CSS_DC;
          wr_bit = 1'b0;
          wad2 = `WAD_N;
          rom_addr_sel = `RAS_PC;
          ext_addr_sel = `EAS_DC;
        end
      `MOV_DR : begin
          ram_rd_sel = `RRS_D;
          ram_wr_sel = `RWS_RN;
          src_sel1 = `ASS_RAM;
          src_sel2 = `ASS_DC;
          alu_op = `ALU_NOP;
          wr = 1'b1;
          psw_set = `PS_NOT;
          cy_sel = `CY_0;
          pc_wr = `PCW_N;
          pc_sel = `PIS_DC;
          imm_sel = `IDS_DC;
          src_sel3 = `AS3_DC;
          comp_sel = `CSS_DC;
          wr_bit = 1'b0;
          wad2 = `WAD_N;
          rom_addr_sel = `RAS_PC;
          ext_addr_sel = `EAS_DC;
        end
      `MOV_CR : begin
          ram_rd_sel = `RRS_DC;
          ram_wr_sel = `RWS_RN;
          src_sel1 = `ASS_IMM;
          src_sel2 = `ASS_DC;
          alu_op = `ALU_NOP;
          wr = 1'b1;
          psw_set = `PS_NOT;
          cy_sel = `CY_0;
          pc_wr = `PCW_N;
          pc_sel = `PIS_DC;
          imm_sel = `IDS_OP2;
          src_sel3 = `AS3_DC;
          comp_sel = `CSS_DC;
          wr_bit = 1'b0;
          wad2 = `WAD_N;
          rom_addr_sel = `RAS_PC;
          ext_addr_sel = `EAS_DC;
        end
      `MOV_RD : begin
          ram_rd_sel = `RRS_RN;
          ram_wr_sel = `RWS_D;
          src_sel1 = `ASS_RAM;
          src_sel2 = `ASS_DC;
          alu_op = `ALU_NOP;
          wr = 1'b1;
          psw_set = `PS_NOT;
          cy_sel = `CY_0;
          pc_wr = `PCW_N;
          pc_sel = `PIS_DC;
          imm_sel = `IDS_DC;
          src_sel3 = `AS3_DC;
          comp_sel = `CSS_DC;
          wr_bit = 1'b0;
          wad2 = `WAD_N;
          rom_addr_sel = `RAS_PC;
          ext_addr_sel = `EAS_DC;
        end
      `ORL_R : begin
          ram_rd_sel = `RRS_RN;
          ram_wr_sel = `RWS_ACC;
          src_sel1 = `ASS_RAM;
          src_sel2 = `ASS_ACC;
          alu_op = `ALU_OR;
          wr = 1'b1;
          psw_set = `PS_NOT;
          cy_sel = `CY_0;
          pc_wr = `PCW_N;
          pc_sel = `PIS_DC;
          imm_sel = `IDS_DC;
          src_sel3 = `AS3_DC;
          comp_sel = `CSS_DC;
          wr_bit = 1'b0;
          wad2 = `WAD_N;
          rom_addr_sel = `RAS_PC;
          ext_addr_sel = `EAS_DC;
        end
      `SUBB_R : begin
          ram_rd_sel = `RRS_RN;
          ram_wr_sel = `RWS_ACC;
          src_sel1 = `ASS_RAM;
          src_sel2 = `ASS_ACC;
          alu_op = `ALU_SUB;
          wr = 1'b1;
          psw_set = `PS_AC;
          cy_sel = `CY_PSW;
          pc_wr = `PCW_N;
          pc_sel = `PIS_DC;
          imm_sel = `IDS_DC;
          src_sel3 = `AS3_DC;
          comp_sel = `CSS_DC;
          wr_bit = 1'b0;
          wad2 = `WAD_N;
          rom_addr_sel = `RAS_PC;
          ext_addr_sel = `EAS_DC;
        end
      `XCH_R : begin 
          ram_rd_sel = `RRS_RN;
          ram_wr_sel = `RWS_RN;
          src_sel1 = `ASS_RAM;
          src_sel2 = `ASS_ACC;
          alu_op = `ALU_XCH;
          wr = 1'b1;
          psw_set = `PS_NOT;
          cy_sel = `CY_1;
          pc_wr = `PCW_N;
          pc_sel = `PIS_DC;
          imm_sel = 2'bxx;
          src_sel3 = `AS3_DC;
          comp_sel = `CSS_DC;
          wr_bit = 1'b0;
          wad2 = `WAD_Y;
          rom_addr_sel = `RAS_PC;
          ext_addr_sel = `EAS_DC;
        end
      `XRL_R : begin
          ram_rd_sel = `RRS_RN;
          ram_wr_sel = `RWS_ACC;
          src_sel1 = `ASS_RAM;
          src_sel2 = `ASS_ACC;
          alu_op = `ALU_XOR;
          wr = 1'b1;
          psw_set = `PS_NOT;
          cy_sel = `CY_0;
          pc_wr = `PCW_N;
          pc_sel = `PIS_DC;
          imm_sel = `IDS_DC;
          src_sel3 = `AS3_DC;
          comp_sel = `CSS_DC;
          wr_bit = 1'b0;
          wad2 = `WAD_N;
          rom_addr_sel = `RAS_PC;
          ext_addr_sel = `EAS_DC;
        end

//op_code [7:1]
      `ADD_I : begin
          ram_rd_sel = `RRS_I;
          ram_wr_sel = `RWS_ACC;
          src_sel1 = `ASS_ACC;
          src_sel2 = `ASS_RAM;
          alu_op = `ALU_ADD;
          wr = 1'b1;
          psw_set = `PS_AC;
          cy_sel = `CY_0;
          pc_wr = `PCW_N;
          pc_sel = `PIS_DC;
          imm_sel = 2'bxx;
          src_sel3 = `AS3_DC;
          comp_sel = `CSS_DC;
          wr_bit = 1'b0;
          wad2 = `WAD_N;
          rom_addr_sel = `RAS_PC;
          ext_addr_sel = `EAS_DC;
        end
      `ADDC_I : begin
          ram_rd_sel = `RRS_I;
          ram_wr_sel = `RWS_ACC;
          src_sel1 = `ASS_ACC;
          src_sel2 = `ASS_RAM;
          alu_op = `ALU_ADD;
          wr = 1'b1;
          psw_set = `PS_AC;
          cy_sel = `CY_PSW;
          pc_wr = `PCW_N;
          pc_sel = `PIS_DC;
          imm_sel = 2'bxx;
          src_sel3 = `AS3_DC;
          comp_sel = `CSS_DC;
          wr_bit = 1'b0;
          wad2 = `WAD_N;
          rom_addr_sel = `RAS_PC;
          ext_addr_sel = `EAS_DC;
        end
      `ANL_I : begin
          ram_rd_sel = `RRS_I;
          ram_wr_sel = `RWS_ACC;
          src_sel1 = `ASS_ACC;
          src_sel2 = `ASS_RAM;
          alu_op = `ALU_AND;
          wr = 1'b1;
          psw_set = `PS_NOT;
          cy_sel = `CY_0;
          pc_wr = `PCW_N;
          pc_sel = `PIS_DC;
          imm_sel = 2'bxx;
          src_sel3 = `AS3_DC;
          comp_sel = `CSS_DC;
          wr_bit = 1'b0;
          wad2 = `WAD_N;
          rom_addr_sel = `RAS_PC;
          ext_addr_sel = `EAS_DC;
        end
      `CJNE_I : begin
          ram_rd_sel = `RRS_I;
          ram_wr_sel = `RWS_DC;
          src_sel1 = `ASS_IMM;
          src_sel2 = `ASS_RAM;
          alu_op = `ALU_SUB;
          wr = 1'b0;
          psw_set = `PS_CY;
          cy_sel = `CY_0;
          pc_wr = `PCW_N;
          pc_sel = `PIS_DC;
          imm_sel = `IDS_OP2;
          src_sel3 = `AS3_DC;
          comp_sel = `CSS_DC;
          wr_bit = 1'b0;
          wad2 = `WAD_N;
          rom_addr_sel = `RAS_PC;
          ext_addr_sel = `EAS_DC;
        end
      `DEC_I : begin
          ram_rd_sel = `RRS_I;
          ram_wr_sel = `RWS_I;
          src_sel1 = `ASS_RAM;
          src_sel2 = `ASS_ZERO;
          alu_op = `ALU_SUB;
          wr = 1'b1;
          psw_set = `PS_NOT;
          cy_sel = `CY_1;
          pc_wr = `PCW_N;
          pc_sel = `PIS_DC;
          imm_sel = `IDS_DC;
          src_sel3 = `AS3_DC;
          comp_sel = `CSS_DC;
          wr_bit = 1'b0;
          wad2 = `WAD_N;
          rom_addr_sel = `RAS_PC;
          ext_addr_sel = `EAS_DC;
        end
      `INC_I : begin
          ram_rd_sel = `RRS_I;
          ram_wr_sel = `RWS_I;
          src_sel1 = `ASS_RAM;
          src_sel2 = `ASS_ZERO;
          alu_op = `ALU_ADD;
          wr = 1'b1;
          psw_set = `PS_NOT;
          cy_sel = `CY_1;
          pc_wr = `PCW_N;
          pc_sel = `PIS_DC;
          imm_sel = `IDS_DC;
          src_sel3 = `AS3_DC;
          comp_sel = `CSS_DC;
          wr_bit = 1'b0;
          wad2 = `WAD_N;
          rom_addr_sel = `RAS_PC;
          ext_addr_sel = `EAS_DC;
        end
      `MOV_I : begin
          ram_rd_sel = `RRS_I;
          ram_wr_sel = `RWS_ACC;
          src_sel1 = `ASS_RAM;
          src_sel2 = `ASS_DC;
          alu_op = `ALU_NOP;
          wr = 1'b1;
          psw_set = `PS_NOT;
          cy_sel = `CY_0;
          pc_wr = `PCW_N;
          pc_sel = `PIS_DC;
          imm_sel = `IDS_DC;
          src_sel3 = `AS3_DC;
          comp_sel = `CSS_DC;
          wr_bit = 1'b0;
          wad2 = `WAD_N;
          rom_addr_sel = `RAS_PC;
          ext_addr_sel = `EAS_DC;
        end
      `MOV_ID : begin
          ram_rd_sel = `RRS_I;
          ram_wr_sel = `RWS_D;
          src_sel1 = `ASS_RAM;
          src_sel2 = `ASS_DC;
          alu_op = `ALU_NOP;
          wr = 1'b1;
          psw_set = `PS_NOT;
          cy_sel = `CY_0;
          pc_wr = `PCW_N;
          pc_sel = `PIS_DC;
          imm_sel = `IDS_DC;
          src_sel3 = `AS3_DC;
          comp_sel = `CSS_DC;
          wr_bit = 1'b0;
          wad2 = `WAD_N;
          rom_addr_sel = `RAS_PC;
          ext_addr_sel = `EAS_DC;
        end
      `MOV_AI : begin
          ram_rd_sel = `RRS_DC;
          ram_wr_sel = `RWS_I;
          src_sel1 = `ASS_ACC;
          src_sel2 = `ASS_DC;
          alu_op = `ALU_NOP;
          wr = 1'b1;
          psw_set = `PS_NOT;
          cy_sel = `CY_0;
          pc_wr = `PCW_N;
          pc_sel = `PIS_DC;
          imm_sel = `IDS_DC;
          src_sel3 = `AS3_DC;
          comp_sel = `CSS_DC;
          wr_bit = 1'b0;
          wad2 = `WAD_N;
          rom_addr_sel = `RAS_PC;
          ext_addr_sel = `EAS_DC;
        end
      `MOV_DI : begin
          ram_rd_sel = `RRS_D;
          ram_wr_sel = `RWS_I;
          src_sel1 = `ASS_RAM;
          src_sel2 = `ASS_DC;
          alu_op = `ALU_NOP;
          wr = 1'b1;
          psw_set = `PS_NOT;
          cy_sel = `CY_0;
          pc_wr = `PCW_N;
          pc_sel = `PIS_DC;
          imm_sel = `IDS_DC;
          src_sel3 = `AS3_DC;
          comp_sel = `CSS_DC;
          wr_bit = 1'b0;
          wad2 = `WAD_N;
          rom_addr_sel = `RAS_PC;
          ext_addr_sel = `EAS_DC;
        end
      `MOV_CI : begin
          ram_rd_sel = `RRS_DC;
          ram_wr_sel = `RWS_I;
          src_sel1 = `ASS_IMM;
          src_sel2 = `ASS_DC;
          alu_op = `ALU_NOP;
          wr = 1'b1;
          psw_set = `PS_NOT;
          cy_sel = `CY_0;
          pc_wr = `PCW_N;
          pc_sel = `PIS_DC;
          imm_sel = `IDS_OP2;
          src_sel3 = `AS3_DC;
          comp_sel = `CSS_DC;
          wr_bit = 1'b0;
          wad2 = `WAD_N;
          rom_addr_sel = `RAS_PC;
          ext_addr_sel = `EAS_DC;
        end
      `MOVX_IA : begin
          ram_rd_sel = `RRS_DC;
          ram_wr_sel = `RWS_ACC;
          src_sel1 = `ASS_XRAM;
          src_sel2 = `ASS_DC;
          alu_op = `ALU_NOP;
          wr = 1'b1;
          psw_set = `PS_NOT;
          cy_sel = `CY_0;
          pc_wr = `PCW_N;
          pc_sel = `PIS_DC;
          imm_sel = `IDS_OP2;
          src_sel3 = `AS3_DC;
          comp_sel = `CSS_DC;
          wr_bit = 1'b0;
          wad2 = `WAD_N;
          rom_addr_sel = `RAS_PC;
          ext_addr_sel = `EAS_RI;
        end
      `MOVX_AI :begin
          ram_rd_sel = `RRS_DC;
          ram_wr_sel = `RWS_ACC;
          src_sel1 = `ASS_DC;
          src_sel2 = `ASS_DC;
          alu_op = `ALU_NOP;
          wr = 1'b0;
          psw_set = `PS_NOT;
          cy_sel = `CY_0;
          pc_wr = `PCW_N;
          pc_sel = `PIS_DC;
          imm_sel = `IDS_OP2;
          src_sel3 = `AS3_DC;
          comp_sel = `CSS_DC;
          wr_bit = 1'b0;
          wad2 = `WAD_N;
          rom_addr_sel = `RAS_PC;
          ext_addr_sel = `EAS_RI;
        end
      `ORL_I : begin
          ram_rd_sel = `RRS_I;
          ram_wr_sel = `RWS_ACC;
          src_sel1 = `ASS_RAM;
          src_sel2 = `ASS_ACC;
          alu_op = `ALU_OR;
          wr = 1'b1;
          psw_set = `PS_NOT;
          cy_sel = `CY_0;
          pc_wr = `PCW_N;
          pc_sel = `PIS_DC;
          imm_sel = `IDS_DC;
          src_sel3 = `AS3_DC;
          comp_sel = `CSS_DC;
          wr_bit = 1'b0;
          wad2 = `WAD_N;
          rom_addr_sel = `RAS_PC;
          ext_addr_sel = `EAS_DC;
        end
      `SUBB_I : begin
          ram_rd_sel = `RRS_I;
          ram_wr_sel = `RWS_ACC;
          src_sel1 = `ASS_RAM;
          src_sel2 = `ASS_ACC;
          alu_op = `ALU_SUB;
          wr = 1'b1;
          psw_set = `PS_AC;
          cy_sel = `CY_PSW;
          pc_wr = `PCW_N;
          pc_sel = `PIS_DC;
          imm_sel = `IDS_DC;
          src_sel3 = `AS3_DC;
          comp_sel = `CSS_DC;
          wr_bit = 1'b0;
          wad2 = `WAD_N;
          rom_addr_sel = `RAS_PC;
          ext_addr_sel = `EAS_DC;
        end
      `XCH_I : begin
          ram_rd_sel = `RRS_I;
          ram_wr_sel = `RWS_I;
          src_sel1 = `ASS_RAM;
          src_sel2 = `ASS_ACC;
          alu_op = `ALU_XCH;
          wr = 1'b1;
          psw_set = `PS_NOT;
          cy_sel = `CY_1;
          pc_wr = `PCW_N;
          pc_sel = `PIS_DC;
          imm_sel = 2'bxx;
          src_sel3 = `AS3_DC;
          comp_sel = `CSS_DC;
          wr_bit = 1'b0;
          wad2 = `WAD_Y;
          rom_addr_sel = `RAS_PC;
          ext_addr_sel = `EAS_DC;
        end
      `XCHD :begin
          ram_rd_sel = `RRS_I;
          ram_wr_sel = `RWS_I;
          src_sel1 = `ASS_RAM;
          src_sel2 = `ASS_ACC;
          alu_op = `ALU_XCH;
          wr = 1'b1;
          psw_set = `PS_NOT;
          cy_sel = `CY_0;
          pc_wr = `PCW_N;
          pc_sel = `PIS_DC;
          imm_sel = 2'bxx;
          src_sel3 = `AS3_DC;
          comp_sel = `CSS_DC;
          wr_bit = 1'b0;
          wad2 = `WAD_Y;
          rom_addr_sel = `RAS_PC;
          ext_addr_sel = `EAS_DC;
        end
      `XRL_I : begin
          ram_rd_sel = `RRS_I;
          ram_wr_sel = `RWS_ACC;
          src_sel1 = `ASS_RAM;
          src_sel2 = `ASS_ACC;
          alu_op = `ALU_XOR;
          wr = 1'b1;
          psw_set = `PS_NOT;
          cy_sel = `CY_0;
          pc_wr = `PCW_N;
          pc_sel = `PIS_DC;
          imm_sel = `IDS_DC;
          src_sel3 = `AS3_DC;
          comp_sel = `CSS_DC;
          wr_bit = 1'b0;
          wad2 = `WAD_N;
          rom_addr_sel = `RAS_PC;
          ext_addr_sel = `EAS_DC;
        end

//op_code [7:0]
      `ADD_D : begin
          ram_rd_sel = `RRS_D;
          ram_wr_sel = `RWS_ACC;
          src_sel1 = `ASS_ACC;
          src_sel2 = `ASS_RAM;
          alu_op = `ALU_ADD;
          wr = 1'b1;
          psw_set = `PS_AC;
          cy_sel = `CY_0;
          pc_wr = `PCW_N;
          pc_sel = `PIS_DC;
          imm_sel = 2'bxx;
          src_sel3 = `AS3_DC;
          comp_sel = `CSS_DC;
          wr_bit = 1'b0;
          wad2 = `WAD_N;
          rom_addr_sel = `RAS_PC;
          ext_addr_sel = `EAS_DC;
        end
      `ADD_C : begin
          ram_rd_sel = 2'bxx;
          ram_wr_sel = `RWS_ACC;
          src_sel1 = `ASS_IMM;
          src_sel2 = `ASS_ACC;
          alu_op = `ALU_ADD;
          wr = 1'b1;
          psw_set = `PS_AC;
          cy_sel = `CY_0;
          pc_wr = `PCW_N;
          pc_sel = `PIS_DC;
          imm_sel = `IDS_OP2;
          src_sel3 = `AS3_DC;
          comp_sel = `CSS_DC;
          wr_bit = 1'b0;
          wad2 = `WAD_N;
          rom_addr_sel = `RAS_PC;
          ext_addr_sel = `EAS_DC;
        end
      `ADDC_D : begin
          ram_rd_sel = `RRS_D;
          ram_wr_sel = `RWS_ACC;
          src_sel1 = `ASS_ACC;
          src_sel2 = `ASS_RAM;
          alu_op = `ALU_ADD;
          wr = 1'b1;
          psw_set = `PS_AC;
          cy_sel = `CY_PSW;
          pc_wr = `PCW_N;
          pc_sel = `PIS_DC;
          imm_sel = 2'bxx;
          src_sel3 = `AS3_DC;
          comp_sel = `CSS_DC;
          wr_bit = 1'b0;
          wad2 = `WAD_N;
          rom_addr_sel = `RAS_PC;
          ext_addr_sel = `EAS_DC;
        end
      `ADDC_C : begin
          ram_rd_sel = 2'bxx;
          ram_wr_sel = `RWS_ACC;
          src_sel1 = `ASS_IMM;
          src_sel2 = `ASS_ACC;
          alu_op = `ALU_ADD;
          wr = 1'b1;
          psw_set = `PS_AC;
          cy_sel = `CY_PSW;
          pc_wr = `PCW_N;
          pc_sel = `PIS_DC;
          imm_sel = `IDS_OP2;
          src_sel3 = `AS3_DC;
          comp_sel = `CSS_DC;
          wr_bit = 1'b0;
          wad2 = `WAD_N;
          rom_addr_sel = `RAS_PC;
          ext_addr_sel = `EAS_DC;
        end
      `ANL_D : begin
          ram_rd_sel = `RRS_D;
          ram_wr_sel = `RWS_ACC;
          src_sel1 = `ASS_ACC;
          src_sel2 = `ASS_RAM;
          alu_op = `ALU_AND;
          wr = 1'b1;
          psw_set = `PS_NOT;
          cy_sel = `CY_0;
          pc_wr = `PCW_N;
          pc_sel = `PIS_DC;
          imm_sel = 2'bxx;
          src_sel3 = `AS3_DC;
          comp_sel = `CSS_DC;
          wr_bit = 1'b0;
          wad2 = `WAD_N;
          rom_addr_sel = `RAS_PC;
          ext_addr_sel = `EAS_DC;
        end
      `ANL_C : begin
          ram_rd_sel = 2'bxx;
          ram_wr_sel = `RWS_ACC;
          src_sel1 = `ASS_IMM;
          src_sel2 = `ASS_ACC;
          alu_op = `ALU_AND;
          wr = 1'b1;
          psw_set = `PS_NOT;
          cy_sel = `CY_0;
          pc_wr = `PCW_N;
          pc_sel = `PIS_DC;
          imm_sel = `IDS_OP2;
          src_sel3 = `AS3_DC;
          comp_sel = `CSS_DC;
          wr_bit = 1'b0;
          wad2 = `WAD_N;
          rom_addr_sel = `RAS_PC;
          ext_addr_sel = `EAS_DC;
        end
      `ANL_DD : begin
          ram_rd_sel = `RRS_D;
          ram_wr_sel = `RWS_D;
          src_sel1 = `ASS_ACC;
          src_sel2 = `ASS_RAM;
          alu_op = `ALU_AND;
          wr = 1'b1;
          psw_set = `PS_NOT;
          cy_sel = `CY_0;
          pc_wr = `PCW_N;
          pc_sel = `PIS_DC;
          imm_sel = 2'bxx;
          src_sel3 = `AS3_DC;
          comp_sel = `CSS_DC;
          wr_bit = 1'b0;
          wad2 = `WAD_N;
          rom_addr_sel = `RAS_PC;
          ext_addr_sel = `EAS_DC;
        end
      `ANL_DC : begin
          ram_rd_sel = `RRS_D;
          ram_wr_sel = `RWS_D;
          src_sel1 = `ASS_IMM;
          src_sel2 = `ASS_RAM;
          alu_op = `ALU_AND;
          wr = 1'b1;
          psw_set = `PS_NOT;
          cy_sel = `CY_0;
          pc_wr = `PCW_N;
          pc_sel = `PIS_DC;
          imm_sel = `IDS_OP3;
          src_sel3 = `AS3_DC;
          comp_sel = `CSS_DC;
          wr_bit = 1'b0;
          wad2 = `WAD_N;
          rom_addr_sel = `RAS_PC;
          ext_addr_sel = `EAS_DC;
        end
      `ANL_B : begin
          ram_rd_sel = `RRS_D;
          ram_wr_sel = `RWS_DC;
          src_sel1 = `ASS_DC;
          src_sel2 = `ASS_DC;
          alu_op = `ALU_AND;
          wr = 1'b0;
          psw_set = `PS_CY;
          cy_sel = `CY_PSW;
          pc_wr = `PCW_N;
          pc_sel = `PIS_DC;
          imm_sel = `IDS_DC;
          src_sel3 = `AS3_DC;
          comp_sel = `CSS_DC;
          wr_bit = 1'b0;
          wad2 = `WAD_N;
          rom_addr_sel = `RAS_PC;
          ext_addr_sel = `EAS_DC;
        end
      `ANL_NB : begin
          ram_rd_sel = `RRS_D;
          ram_wr_sel = `RWS_DC;
          src_sel1 = `ASS_DC;
          src_sel2 = `ASS_DC;
          alu_op = `ALU_RR;
          wr = 1'b0;
          psw_set = `PS_CY;
          cy_sel = `CY_PSW;
          pc_wr = `PCW_N;
          pc_sel = `PIS_DC;
          imm_sel = `IDS_DC;
          src_sel3 = `AS3_DC;
          comp_sel = `CSS_DC;
          wr_bit = 1'b0;
          wad2 = `WAD_N;
          rom_addr_sel = `RAS_PC;
          ext_addr_sel = `EAS_DC;
        end
      `CJNE_D : begin
          ram_rd_sel = `RRS_D;
          ram_wr_sel = `RWS_DC;
          src_sel1 = `ASS_RAM;
          src_sel2 = `ASS_ACC;
          alu_op = `ALU_SUB;
          wr = 1'b0;
          psw_set = `PS_CY;
          cy_sel = `CY_0;
          pc_wr = `PCW_N;
          pc_sel = `PIS_DC;
          imm_sel = `IDS_DC;
          src_sel3 = `AS3_DC;
          comp_sel = `CSS_DC;
          wr_bit = 1'b0;
          wad2 = `WAD_N;
          rom_addr_sel = `RAS_PC;
          ext_addr_sel = `EAS_DC;
        end
      `CJNE_C : begin
          ram_rd_sel = `RRS_DC;
          ram_wr_sel = `RWS_DC;
          src_sel1 = `ASS_IMM;
          src_sel2 = `ASS_ACC;
          alu_op = `ALU_SUB;
          wr = 1'b0;
          psw_set = `PS_CY;
          cy_sel = `CY_0;
          pc_wr = `PCW_N;
          pc_sel = `PIS_DC;
          imm_sel = `IDS_OP2;
          src_sel3 = `AS3_DC;
          comp_sel = `CSS_DC;
          wr_bit = 1'b0;
          wad2 = `WAD_N;
          rom_addr_sel = `RAS_PC;
          ext_addr_sel = `EAS_DC;
        end
      `CLR_A : begin
          ram_rd_sel = `RRS_DC;
          ram_wr_sel = `RWS_DC;
          src_sel1 = `ASS_ACC;
          src_sel2 = `ASS_ACC;
          alu_op = `ALU_SUB;
          wr = 1'b1;
          psw_set = `PS_NOT;
          cy_sel = `CY_0;
          pc_wr = `PCW_N;
          pc_sel = `PIS_DC;
          imm_sel = `IDS_DC;
          src_sel3 = `AS3_PC;
          comp_sel = `CSS_DC;
          wr_bit = 1'b0;
          wad2 = `WAD_N;
          rom_addr_sel = `RAS_PC;
          ext_addr_sel = `EAS_DC;
        end
      `CLR_C : begin
          ram_rd_sel = `RRS_DC;
          ram_wr_sel = `RWS_DC;
          src_sel1 = `ASS_DC;
          src_sel2 = `ASS_DC;
          alu_op = `ALU_NOP;
          wr = 1'b0;
          psw_set = `PS_CY;
          cy_sel = `CY_0;
          pc_wr = `PCW_N;
          pc_sel = `PIS_DC;
          imm_sel = `IDS_DC;
          src_sel3 = `AS3_PC;
          comp_sel = `CSS_DC;
          wr_bit = 1'b0;
          wad2 = `WAD_N;
          rom_addr_sel = `RAS_PC;
          ext_addr_sel = `EAS_DC;
        end
      `CLR_B : begin
          ram_rd_sel = `RRS_DC;
          ram_wr_sel = `RWS_D;
          src_sel1 = `ASS_DC;
          src_sel2 = `ASS_DC;
          alu_op = `ALU_NOP;
          wr = 1'b1;
          psw_set = `PS_NOT;
          cy_sel = `CY_0;
          pc_wr = `PCW_N;
          pc_sel = `PIS_DC;
          imm_sel = `IDS_DC;
          src_sel3 = `AS3_PC;
          comp_sel = `CSS_DC;
          wr_bit = 1'b1;
          wad2 = `WAD_N;
          rom_addr_sel = `RAS_PC;
          ext_addr_sel = `EAS_DC;
        end
      `CPL_A : begin
          ram_rd_sel = `RRS_DC;
          ram_wr_sel = `RWS_ACC;
          src_sel1 = `ASS_ACC;
          src_sel2 = `ASS_DC;
          alu_op = `ALU_NOT;
          wr = 1'b1;
          psw_set = `PS_NOT;
          cy_sel = `CY_0;
          pc_wr = `PCW_N;
          pc_sel = `PIS_DC;
          imm_sel = `IDS_OP3;
          src_sel3 = `AS3_DC;
          comp_sel = `CSS_DC;
          wr_bit = 1'b0;
          wad2 = `WAD_N;
          rom_addr_sel = `RAS_PC;
          ext_addr_sel = `EAS_DC;
        end
      `CPL_C : begin
          ram_rd_sel = `RRS_DC;
          ram_wr_sel = `RWS_DC;
          src_sel1 = `ASS_DC;
          src_sel2 = `ASS_DC;
          alu_op = `ALU_NOT;
          wr = 1'b0;
          psw_set = `PS_CY;
          cy_sel = `CY_PSW;
          pc_wr = `PCW_N;
          pc_sel = `PIS_DC;
          imm_sel = `IDS_OP3;
          src_sel3 = `AS3_DC;
          comp_sel = `CSS_DC;
          wr_bit = 1'b0;
          wad2 = `WAD_N;
          rom_addr_sel = `RAS_PC;
          ext_addr_sel = `EAS_DC;
        end
      `CPL_B : begin
          ram_rd_sel = `RRS_D;
          ram_wr_sel = `RWS_D;
          src_sel1 = `ASS_DC;
          src_sel2 = `ASS_DC;
          alu_op = `ALU_NOT;
          wr = 1'b1;
          psw_set = `PS_NOT;
          cy_sel = `CY_RAM;
          pc_wr = `PCW_N;
          pc_sel = `PIS_DC;
          imm_sel = `IDS_OP3;
          src_sel3 = `AS3_DC;
          comp_sel = `CSS_DC;
          wr_bit = 1'b1;
          wad2 = `WAD_N;
          rom_addr_sel = `RAS_PC;
          ext_addr_sel = `EAS_DC;
        end
      `DA : begin
          ram_rd_sel = `RRS_DC;
          ram_wr_sel = `RWS_ACC;
          src_sel1 = `ASS_ACC;
          src_sel2 = `ASS_DC;
          alu_op = `ALU_DA;
          wr = 1'b1;
          psw_set = `PS_CY;
          cy_sel = `CY_DC;
          pc_wr = `PCW_N;
          pc_sel = `PIS_DC;
          imm_sel = `IDS_DC;
          src_sel3 = `AS3_DC;
          comp_sel = `CSS_DC;
          wr_bit = 1'b1;
          wad2 = `WAD_N;
          rom_addr_sel = `RAS_PC;
          ext_addr_sel = `EAS_DC;
        end
      `DEC_A : begin
          ram_rd_sel = `RRS_DC;
          ram_wr_sel = `RWS_ACC;
          src_sel1 = `ASS_ACC;
          src_sel2 = `ASS_ZERO;
          alu_op = `ALU_SUB;
          wr = 1'b1;
          psw_set = `PS_NOT;
          cy_sel = `CY_1;
          pc_wr = `PCW_N;
          pc_sel = `PIS_DC;
          imm_sel = `IDS_DC;
          src_sel3 = `AS3_DC;
          comp_sel = `CSS_DC;
          wr_bit = 1'b0;
          wad2 = `WAD_N;
          rom_addr_sel = `RAS_PC;
          ext_addr_sel = `EAS_DC;
        end
      `DEC_D : begin
          ram_rd_sel = `RRS_D;
          ram_wr_sel = `RWS_D;
          src_sel1 = `ASS_RAM;
          src_sel2 = `ASS_ZERO;
          alu_op = `ALU_SUB;
          wr = 1'b1;
          psw_set = `PS_NOT;
          cy_sel = `CY_1;
          pc_wr = `PCW_N;
          pc_sel = `PIS_DC;
          imm_sel = `IDS_DC;
          src_sel3 = `AS3_DC;
          comp_sel = `CSS_DC;
          wr_bit = 1'b0;
          wad2 = `WAD_N;
          rom_addr_sel = `RAS_PC;
          ext_addr_sel = `EAS_DC;
        end
      `DIV : begin
          ram_rd_sel = `RRS_D;
          ram_wr_sel = `RWS_B;
          src_sel1 = `ASS_ACC;
          src_sel2 = `ASS_RAM;
          alu_op = `ALU_DIV;
          wr = 1'b1;
          psw_set = `PS_OV;
          cy_sel = `CY_0;
          pc_wr = `PCW_N;
          pc_sel = `PIS_DC;
          imm_sel = `IDS_DC;
          src_sel3 = `AS3_DC;
          comp_sel = `CSS_DC;
          wr_bit = 1'b0;
          wad2 = `WAD_Y;
          rom_addr_sel = `RAS_PC;
          ext_addr_sel = `EAS_DC;
        end
      `DJNZ_D : begin
	  ram_rd_sel = `RRS_D;
	  ram_wr_sel = `RWS_D;
	  src_sel1 = `ASS_RAM;
	  src_sel2 = `ASS_ZERO;
	  alu_op = `ALU_SUB;
          wr = 1'b1;
	  psw_set = `PS_NOT;
	  cy_sel = `CY_1;
          pc_wr = `PCW_N;
          pc_sel = `PIS_DC;
          imm_sel = 2'bxx;
          src_sel3 = `AS3_DC;
          comp_sel = `CSS_DC;
          wr_bit = 1'b0;
          wad2 = `WAD_N;
          rom_addr_sel = `RAS_PC;
          ext_addr_sel = `EAS_DC;
        end
      `INC_A : begin
          ram_rd_sel = `RRS_DC;
          ram_wr_sel = `RWS_ACC;
          src_sel1 = `ASS_ACC;
          src_sel2 = `ASS_ZERO;
          alu_op = `ALU_ADD;
          wr = 1'b1;
          psw_set = `PS_NOT;
          cy_sel = `CY_1;
          pc_wr = `PCW_N;
          pc_sel = `PIS_DC;
          imm_sel = `IDS_DC;
          src_sel3 = `AS3_DC;
          comp_sel = `CSS_DC;
          wr_bit = 1'b0;
          wad2 = `WAD_N;
          rom_addr_sel = `RAS_PC;
          ext_addr_sel = `EAS_DC;
        end
      `INC_D : begin
          ram_rd_sel = `RRS_D;
          ram_wr_sel = `RWS_D;
          src_sel1 = `ASS_RAM;
          src_sel2 = `ASS_ZERO;
          alu_op = `ALU_ADD;
          wr = 1'b1;
          psw_set = `PS_NOT;
          cy_sel = `CY_1;
          pc_wr = `PCW_N;
          pc_sel = `PIS_DC;
          imm_sel = `IDS_DC;
          src_sel3 = `AS3_DC;
          comp_sel = `CSS_DC;
          wr_bit = 1'b0;
          wad2 = `WAD_N;
          rom_addr_sel = `RAS_PC;
          ext_addr_sel = `EAS_DC;
        end
      `INC_DP : begin
	  ram_rd_sel = `RRS_D;
	  ram_wr_sel = `RWS_DPTR;
	  src_sel1 = `ASS_RAM;
	  src_sel2 = `ASS_ZERO;
	  alu_op = `ALU_ADD;
          wr = 1'b1;
	  psw_set = `PS_NOT;
	  cy_sel = `CY_1;
          pc_wr = `PCW_N;
          pc_sel = `PIS_DC;
          imm_sel = 2'bxx;
          src_sel3 = `AS3_DP;
          comp_sel = `CSS_DC;
          wr_bit = 1'b0;
          wad2 = `WAD_N;
          rom_addr_sel = `RAS_PC;
          ext_addr_sel = `EAS_DC;
        end
      `JB : begin
          ram_rd_sel = `RRS_D;
          ram_wr_sel = `RWS_DC;
          src_sel1 = `ASS_IMM;
          src_sel2 = `ASS_OP2;
          alu_op = `ALU_PCS;
          wr = 1'b0;
          psw_set = `PS_NOT;
          cy_sel = `CY_0;
          pc_wr = `PCW_N;
          pc_sel = `PIS_DC;
          imm_sel = `IDS_OP3;
          src_sel3 = `AS3_PC;
          comp_sel = `CSS_BIT;
          wr_bit = 1'b0;
          wad2 = `WAD_N;
          rom_addr_sel = `RAS_PC;
          ext_addr_sel = `EAS_DC;
        end
      `JBC :begin
          ram_rd_sel = `RRS_D;
          ram_wr_sel = `RWS_DC;
          src_sel1 = `ASS_IMM;
          src_sel2 = `ASS_OP2;
          alu_op = `ALU_PCS;
          wr = 1'b0;
          psw_set = `PS_NOT;
          cy_sel = `CY_0;
          pc_wr = `PCW_N;
          pc_sel = `PIS_DC;
          imm_sel = `IDS_OP3;
          src_sel3 = `AS3_PC;
          comp_sel = `CSS_BIT;
          wr_bit = 1'b0;
          wad2 = `WAD_N;
          rom_addr_sel = `RAS_PC;
          ext_addr_sel = `EAS_DC;
        end
      `JC : begin
          ram_rd_sel = `RRS_DC;
          ram_wr_sel = `RWS_DC;
          src_sel1 = `ASS_IMM;
          src_sel2 = `ASS_OP2;
          alu_op = `ALU_PCS;
          wr = 1'b0;
          psw_set = `PS_NOT;
          cy_sel = `CY_0;
          pc_wr = `PCW_N;
          pc_sel = `PIS_DC;
          imm_sel = `IDS_OP2;
          src_sel3 = `AS3_PC;
          comp_sel = `CSS_CY;
          wr_bit = 1'b0;
          wad2 = `WAD_N;
          rom_addr_sel = `RAS_PC;
          ext_addr_sel = `EAS_DC;
        end
      `JMP : begin
          ram_rd_sel = `RRS_D;
          ram_wr_sel = `RWS_DC;
          src_sel1 = `ASS_ACC;
          src_sel2 = `ASS_RAM;
          alu_op = `ALU_ADD;
          wr = 1'b0;
          psw_set = `PS_NOT;
          cy_sel = `CY_0;
          pc_wr = `PCW_N;
          pc_sel = `PIS_DC;
          imm_sel = `IDS_DC;
          src_sel3 = `AS3_DP;
          comp_sel = `CSS_BIT;
          wr_bit = 1'b0;
          wad2 = `WAD_N;
          rom_addr_sel = `RAS_PC;
          ext_addr_sel = `EAS_DC;
        end
      `JNB : begin
          ram_rd_sel = `RRS_D;
          ram_wr_sel = `RWS_DC;
          src_sel1 = `ASS_IMM;
          src_sel2 = `ASS_OP2;
          alu_op = `ALU_PCS;
          wr = 1'b0;
          psw_set = `PS_NOT;
          cy_sel = `CY_0;
          pc_wr = `PCW_N;
          pc_sel = `PIS_DC;
          imm_sel = `IDS_OP3;
          src_sel3 = `AS3_PC;
          comp_sel = `CSS_BIT;
          wr_bit = 1'b0;
          wad2 = `WAD_N;
          rom_addr_sel = `RAS_PC;
          ext_addr_sel = `EAS_DC;
        end
      `JNC : begin
          ram_rd_sel = `RRS_DC;
          ram_wr_sel = `RWS_DC;
          src_sel1 = `ASS_IMM;
          src_sel2 = `ASS_OP2;
          alu_op = `ALU_PCS;
          wr = 1'b0;
          psw_set = `PS_NOT;
          cy_sel = `CY_0;
          pc_wr = `PCW_N;
          pc_sel = `PIS_DC;
          imm_sel = `IDS_OP2;
          src_sel3 = `AS3_PC;
          comp_sel = `CSS_CY;
          wr_bit = 1'b0;
          wad2 = `WAD_N;
          rom_addr_sel = `RAS_PC;
          ext_addr_sel = `EAS_DC;
        end
      `JNZ :begin
          ram_rd_sel = `RRS_DC;
          ram_wr_sel = `RWS_DC;
          src_sel1 = `ASS_IMM;
          src_sel2 = `ASS_OP2;
          alu_op = `ALU_PCS;
          wr = 1'b0;
          psw_set = `PS_NOT;
          cy_sel = `CY_0;
          pc_wr = `PCW_N;
          pc_sel = `PIS_DC;
          imm_sel = `IDS_OP2;
          src_sel3 = `AS3_PC;
          comp_sel = `CSS_AZ;
          wr_bit = 1'b0;
          wad2 = `WAD_N;
          rom_addr_sel = `RAS_PC;
          ext_addr_sel = `EAS_DC;
        end
      `JZ : begin
          ram_rd_sel = `RRS_DC;
          ram_wr_sel = `RWS_DC;
          src_sel1 = `ASS_IMM;
          src_sel2 = `ASS_OP2;
          alu_op = `ALU_PCS;
          wr = 1'b0;
          psw_set = `PS_NOT;
          cy_sel = `CY_0;
          pc_wr = `PCW_N;
          pc_sel = `PIS_DC;
          imm_sel = `IDS_OP2;
          src_sel3 = `AS3_PC;
          comp_sel = `CSS_AZ;
          wr_bit = 1'b0;
          wad2 = `WAD_N;
          rom_addr_sel = `RAS_PC;
          ext_addr_sel = `EAS_DC;
        end
      `LCALL :begin
          ram_rd_sel = 2'bxx;
          ram_wr_sel = `RWS_SP;
          src_sel1 = `ASS_IMM;
          src_sel2 = 2'bxx;
          alu_op = `ALU_NOP;
          imm_sel = `IDS_PCL;
          wr = 1'b1;
          psw_set = `PS_NOT;
          cy_sel = `CY_0;
          pc_wr = `PCW_Y;
          pc_sel = `PIS_I16;
          src_sel3 = `AS3_DC;
          comp_sel = `CSS_DC;
          wr_bit = 1'b0;
          wad2 = `WAD_N;
          rom_addr_sel = `RAS_PC;
          ext_addr_sel = `EAS_DC;
        end
      `LJMP : begin
          ram_rd_sel = 2'bxx;
          ram_wr_sel = 2'bxx;
          src_sel1 = 2'bxx;
          src_sel2 = 2'bxx;
          alu_op = 4'bxxxx;
          imm_sel = 2'bxx;
          wr = 1'b0;
          psw_set = `PS_NOT;
          cy_sel = `CY_0;
          pc_wr = `PCW_Y;
          pc_sel = `PIS_I16;
          src_sel3 = `AS3_DC;
          comp_sel = `CSS_DC;
          wr_bit = 1'b0;
          wad2 = `WAD_N;
          rom_addr_sel = `RAS_PC;
          ext_addr_sel = `EAS_DC;
        end
      `MOV_D : begin
          ram_rd_sel = `RRS_D;
          ram_wr_sel = `RWS_ACC;
          src_sel1 = `ASS_RAM;
          src_sel2 = `ASS_DC;
          alu_op = `ALU_NOP;
          wr = 1'b1;
          psw_set = `PS_NOT;
          cy_sel = `CY_0;
          pc_wr = `PCW_N;
          pc_sel = `PIS_DC;
          imm_sel = `IDS_DC;
          src_sel3 = `AS3_DC;
          comp_sel = `CSS_DC;
          wr_bit = 1'b0;
          wad2 = `WAD_N;
          rom_addr_sel = `RAS_PC;
          ext_addr_sel = `EAS_DC;
        end
      `MOV_C : begin
          ram_rd_sel = `RRS_DC;
          ram_wr_sel = `RWS_ACC;
          src_sel1 = `ASS_IMM;
          src_sel2 = `ASS_DC;
          alu_op = `ALU_NOP;
          wr = 1'b1;
          psw_set = `PS_NOT;
          cy_sel = `CY_0;
          pc_wr = `PCW_N;
          pc_sel = `PIS_DC;
          imm_sel = `IDS_OP2;
          src_sel3 = `AS3_DC;
          comp_sel = `CSS_DC;
          wr_bit = 1'b0;
          wad2 = `WAD_N;
          rom_addr_sel = `RAS_PC;
          ext_addr_sel = `EAS_DC;
        end

      `MOV_DA : begin
          ram_rd_sel = `RRS_DC;
          ram_wr_sel = `RWS_D;
          src_sel1 = `ASS_ACC;
          src_sel2 = `ASS_DC;
          alu_op = `ALU_NOP;
          wr = 1'b1;
          psw_set = `PS_NOT;
          cy_sel = `CY_0;
          pc_wr = `PCW_N;
          pc_sel = `PIS_DC;
          imm_sel = `IDS_DC;
          src_sel3 = `AS3_DC;
          comp_sel = `CSS_DC;
          wr_bit = 1'b0;
          wad2 = `WAD_N;
          rom_addr_sel = `RAS_PC;
          ext_addr_sel = `EAS_DC;
        end
      `MOV_DD : begin
          ram_rd_sel = `RRS_D;
          ram_wr_sel = `RWS_D3;
          src_sel1 = `ASS_RAM;
          src_sel2 = `ASS_DC;
          alu_op = `ALU_NOP;
          wr = 1'b1;
          psw_set = `PS_NOT;
          cy_sel = `CY_0;
          pc_wr = `PCW_N;
          pc_sel = `PIS_DC;
          imm_sel = `IDS_OP2;
          src_sel3 = `AS3_DC;
          comp_sel = `CSS_DC;
          wr_bit = 1'b0;
          wad2 = `WAD_N;
          rom_addr_sel = `RAS_PC;
          ext_addr_sel = `EAS_DC;
        end
      `MOV_CD : begin
          ram_rd_sel = `RRS_DC;
          ram_wr_sel = `RWS_D;
          src_sel1 = `ASS_IMM;
          src_sel2 = `ASS_DC;
          alu_op = `ALU_NOP;
          wr = 1'b1;
          psw_set = `PS_NOT;
          cy_sel = `CY_0;
          pc_wr = `PCW_N;
          pc_sel = `PIS_DC;
          imm_sel = `IDS_OP3;
          src_sel3 = `AS3_DC;
          comp_sel = `CSS_DC;
          wr_bit = 1'b0;
          wad2 = `WAD_N;
          rom_addr_sel = `RAS_PC;
          ext_addr_sel = `EAS_DC;
        end
      `MOV_BC : begin
          ram_rd_sel = `RRS_D;
          ram_wr_sel = `RWS_DC;
          src_sel1 = `ASS_DC;
          src_sel2 = `ASS_DC;
          alu_op = `ALU_NOP;
          wr = 1'b0;
          psw_set = `PS_CY;
          cy_sel = `CY_RAM;
          pc_wr = `PCW_N;
          pc_sel = `PIS_DC;
          imm_sel = `IDS_DC;
          src_sel3 = `AS3_DC;
          comp_sel = `CSS_DC;
          wr_bit = 1'b0;
          wad2 = `WAD_N;
          rom_addr_sel = `RAS_PC;
          ext_addr_sel = `EAS_DC;
        end
      `MOV_CB : begin
          ram_rd_sel = `RRS_DC;
          ram_wr_sel = `RWS_D;
          src_sel1 = `ASS_DC;
          src_sel2 = `ASS_DC;
          alu_op = `ALU_NOP;
          wr = 1'b1;
          psw_set = `PS_NOT;
          cy_sel = `CY_PSW;
          pc_wr = `PCW_N;
          pc_sel = `PIS_DC;
          imm_sel = `IDS_OP3;
          src_sel3 = `AS3_DC;
          comp_sel = `CSS_DC;
          wr_bit = 1'b1;
          wad2 = `WAD_N;
          rom_addr_sel = `RAS_PC;
          ext_addr_sel = `EAS_DC;
        end
      `MOV_DP : begin
          ram_rd_sel = `RRS_DC;
          ram_wr_sel = `RWS_DPTR;
          src_sel1 = `ASS_IMM;
          src_sel2 = `ASS_OP2;
          alu_op = `ALU_NOP;
          wr = 1'b1;
          psw_set = `PS_NOT;
          cy_sel = `CY_0;
          pc_wr = `PCW_N;
          pc_sel = `PIS_DC;
          imm_sel = `IDS_OP3;
          src_sel3 = `AS3_DC;
          comp_sel = `CSS_DC;
          wr_bit = 1'b0;
          wad2 = `WAD_N;
          rom_addr_sel = `RAS_PC;
          ext_addr_sel = `EAS_DC;
        end
      `MOVC_DP :begin
          ram_rd_sel = `RRS_D;
          ram_wr_sel = `RWS_DC;
          src_sel1 = `ASS_ACC;
          src_sel2 = `ASS_RAM;
          alu_op = `ALU_ADD;
          wr = 1'b0;
          psw_set = `PS_NOT;
          cy_sel = `CY_0;
          pc_wr = `PCW_N;
          pc_sel = `PIS_DC;
          imm_sel = 2'bxx;
          src_sel3 = `AS3_DP;
          comp_sel = `CSS_DC;
          wr_bit = 1'b0;
          wad2 = `WAD_N;
          rom_addr_sel = `RAS_PC;
          ext_addr_sel = `EAS_DC;
        end
      `MOVC_PC : begin
          ram_rd_sel = `RRS_DC;
          ram_wr_sel = `RWS_DC;
          src_sel1 = `ASS_ACC;
          src_sel2 = `ASS_OP2;
          alu_op = `ALU_ADD;
          wr = 1'b0;
          psw_set = `PS_NOT;
          cy_sel = `CY_0;
          pc_wr = `PCW_N;
          pc_sel = `PIS_DC;
          imm_sel = 2'bxx;
          src_sel3 = `AS3_DP;
          comp_sel = `CSS_DC;
          wr_bit = 1'b0;
          wad2 = `WAD_N;
          rom_addr_sel = `RAS_PC;
          ext_addr_sel = `EAS_DC;
        end
      `MOVX_PA : begin
          ram_rd_sel = `RRS_DC;
          ram_wr_sel = `RWS_ACC;
          src_sel1 = `ASS_XRAM;
          src_sel2 = `ASS_DC;
          alu_op = `ALU_NOP;
          wr = 1'b1;
          psw_set = `PS_NOT;
          cy_sel = `CY_0;
          pc_wr = `PCW_N;
          pc_sel = `PIS_DC;
          imm_sel = `IDS_OP2;
          src_sel3 = `AS3_DC;
          comp_sel = `CSS_DC;
          wr_bit = 1'b0;
          wad2 = `WAD_N;
          rom_addr_sel = `RAS_PC;
          ext_addr_sel = `EAS_DPTR;
        end
      `MOVX_AP : begin
          ram_rd_sel = `RRS_DC;
          ram_wr_sel = `RWS_DC;
          src_sel1 = `ASS_XRAM;
          src_sel2 = `ASS_DC;
          alu_op = `ALU_NOP;
          wr = 1'b0;
          psw_set = `PS_NOT;
          cy_sel = `CY_0;
          pc_wr = `PCW_N;
          pc_sel = `PIS_DC;
          imm_sel = `IDS_DC;
          src_sel3 = `AS3_DC;
          comp_sel = `CSS_DC;
          wr_bit = 1'b0;
          wad2 = `WAD_N;
          rom_addr_sel = `RAS_PC;
          ext_addr_sel = `EAS_DPTR;
        end
      `MUL : begin
          ram_rd_sel = `RRS_D;
          ram_wr_sel = `RWS_B;
          src_sel1 = `ASS_ACC;
          src_sel2 = `ASS_RAM;
          alu_op = `ALU_MUL;
          wr = 1'b1;
          psw_set = `PS_OV;
          cy_sel = `CY_0;
          pc_wr = `PCW_N;
          pc_sel = `PIS_DC;
          imm_sel = `IDS_DC;
          src_sel3 = `AS3_DC;
          comp_sel = `CSS_DC;
          wr_bit = 1'b0;
          wad2 = `WAD_Y;
          rom_addr_sel = `RAS_PC;
          ext_addr_sel = `EAS_DC;
        end
      `ORL_D : begin
          ram_rd_sel = `RRS_D;
          ram_wr_sel = `RWS_ACC;
          src_sel1 = `ASS_RAM;
          src_sel2 = `ASS_ACC;
          alu_op = `ALU_OR;
          wr = 1'b1;
          psw_set = `PS_NOT;
          cy_sel = `CY_0;
          pc_wr = `PCW_N;
          pc_sel = `PIS_DC;
          imm_sel = `IDS_DC;
          src_sel3 = `AS3_DC;
          comp_sel = `CSS_DC;
          wr_bit = 1'b0;
          wad2 = `WAD_N;
          rom_addr_sel = `RAS_PC;
          ext_addr_sel = `EAS_DC;
        end
      `ORL_C : begin
          ram_rd_sel = `RRS_DC;
          ram_wr_sel = `RWS_ACC;
          src_sel1 = `ASS_IMM;
          src_sel2 = `ASS_ACC;
          alu_op = `ALU_OR;
          wr = 1'b1;
          psw_set = `PS_NOT;
          cy_sel = `CY_0;
          pc_wr = `PCW_N;
          pc_sel = `PIS_DC;
          imm_sel = `IDS_OP2;
          src_sel3 = `AS3_DC;
          comp_sel = `CSS_DC;
          wr_bit = 1'b0;
          wad2 = `WAD_N;
          rom_addr_sel = `RAS_PC;
          ext_addr_sel = `EAS_DC;
        end
      `ORL_AD : begin
          ram_rd_sel = `RRS_D;
          ram_wr_sel = `RWS_D;
          src_sel1 = `ASS_RAM;
          src_sel2 = `ASS_ACC;
          alu_op = `ALU_OR;
          wr = 1'b1;
          psw_set = `PS_NOT;
          cy_sel = `CY_0;
          pc_wr = `PCW_N;
          pc_sel = `PIS_DC;
          imm_sel = `IDS_DC;
          src_sel3 = `AS3_DC;
          comp_sel = `CSS_DC;
          wr_bit = 1'b0;
          wad2 = `WAD_N;
          rom_addr_sel = `RAS_PC;
          ext_addr_sel = `EAS_DC;
        end
      `ORL_CD : begin
          ram_rd_sel = `RRS_D;
          ram_wr_sel = `RWS_D;
          src_sel1 = `ASS_IMM;
          src_sel2 = `ASS_RAM;
          alu_op = `ALU_OR;
          wr = 1'b1;
          psw_set = `PS_NOT;
          cy_sel = `CY_0;
          pc_wr = `PCW_N;
          pc_sel = `PIS_DC;
          imm_sel = `IDS_OP3;
          src_sel3 = `AS3_DC;
          comp_sel = `CSS_DC;
          wr_bit = 1'b0;
          wad2 = `WAD_N;
          rom_addr_sel = `RAS_PC;
          ext_addr_sel = `EAS_DC;
        end
      `ORL_B : begin
          ram_rd_sel = `RRS_D;
          ram_wr_sel = `RWS_DC;
          src_sel1 = `ASS_DC;
          src_sel2 = `ASS_DC;
          alu_op = `ALU_OR;
          wr = 1'b1;
          psw_set = `PS_CY;
          cy_sel = `CY_PSW;
          pc_wr = `PCW_N;
          pc_sel = `PIS_DC;
          imm_sel = `IDS_DC;
          src_sel3 = `AS3_DC;
          comp_sel = `CSS_DC;
          wr_bit = 1'b1;
          wad2 = `WAD_N;
          rom_addr_sel = `RAS_PC;
          ext_addr_sel = `EAS_DC;
        end
      `ORL_NB : begin
          ram_rd_sel = `RRS_D;
          ram_wr_sel = `RWS_DC;
          src_sel1 = `ASS_DC;
          src_sel2 = `ASS_DC;
          alu_op = `ALU_RL;
          wr = 1'b0;
          psw_set = `PS_CY;
          cy_sel = `CY_PSW;
          pc_wr = `PCW_N;
          pc_sel = `PIS_DC;
          imm_sel = `IDS_DC;
          src_sel3 = `AS3_DC;
          comp_sel = `CSS_DC;
          wr_bit = 1'b0;
          wad2 = `WAD_N;
          rom_addr_sel = `RAS_PC;
          ext_addr_sel = `EAS_DC;
        end
      `POP : begin
          ram_rd_sel = `RRS_SP;
          ram_wr_sel = `RWS_D;
          src_sel1 = `ASS_RAM;
          src_sel2 = `ASS_DC;
          alu_op = `ALU_NOP;
          wr = 1'b1;
          psw_set = `PS_NOT;
          cy_sel = `CY_0;
          pc_wr = `PCW_N;
          pc_sel = `PIS_DC;
          imm_sel = `IDS_DC;
          src_sel3 = `AS3_DC;
          comp_sel = `CSS_DC;
          wr_bit = 1'b0;
          wad2 = `WAD_N;
          rom_addr_sel = `RAS_PC;
          ext_addr_sel = `EAS_DC;
        end
      `PUSH : begin
          ram_rd_sel = `RRS_D;
          ram_wr_sel = `RWS_SP;
          src_sel1 = `ASS_RAM;
          src_sel2 = `ASS_DC;
          alu_op = `ALU_NOP;
          wr = 1'b1;
          psw_set = `PS_NOT;
          cy_sel = `CY_0;
          pc_wr = `PCW_N;
          pc_sel = `PIS_DC;
          imm_sel = `IDS_DC;
          src_sel3 = `AS3_DC;
          comp_sel = `CSS_DC;
          wr_bit = 1'b0;
          wad2 = `WAD_N;
          rom_addr_sel = `RAS_PC;
          ext_addr_sel = `EAS_DC;
        end
      `RET : begin
          ram_rd_sel = `RRS_SP;
          ram_wr_sel = `RWS_DC;
          src_sel1 = `ASS_RAM;
          src_sel2 = `ASS_DC;
          alu_op = `ALU_NOP;
          wr = 1'b0;
          psw_set = `PS_NOT;
          cy_sel = `CY_0;
          pc_wr = `PCW_N;
          pc_sel = `PIS_DC;
          imm_sel = `IDS_DC;
          src_sel3 = `AS3_DC;
          comp_sel = `CSS_DC;
          wr_bit = 1'b0;
          wad2 = `WAD_N;
          rom_addr_sel = `RAS_PC;
          ext_addr_sel = `EAS_DC;
        end
      `RETI : begin
          ram_rd_sel = `RRS_SP;
          ram_wr_sel = `RWS_DC;
          src_sel1 = `ASS_RAM;
          src_sel2 = `ASS_DC;
          alu_op = `ALU_NOP;
          wr = 1'b0;
          psw_set = `PS_NOT;
          cy_sel = `CY_0;
          pc_wr = `PCW_N;
          pc_sel = `PIS_DC;
          imm_sel = `IDS_DC;
          src_sel3 = `AS3_DC;
          comp_sel = `CSS_DC;
          wr_bit = 1'b0;
          wad2 = `WAD_N;
          rom_addr_sel = `RAS_PC;
          ext_addr_sel = `EAS_DC;
        end
      `RL : begin
          ram_rd_sel = `RRS_DC;
          ram_wr_sel = `RWS_ACC;
          src_sel1 = `ASS_ACC;
          src_sel2 = `ASS_DC;
          alu_op = `ALU_RL;
          wr = 1'b1;
          psw_set = `PS_NOT;
          cy_sel = `CY_0;
          pc_wr = `PCW_N;
          pc_sel = `PIS_DC;
          imm_sel = `IDS_DC;
          src_sel3 = `AS3_DC;
          comp_sel = `CSS_DC;
          wr_bit = 1'b0;
          wad2 = `WAD_N;
          rom_addr_sel = `RAS_PC;
          ext_addr_sel = `EAS_DC;
        end
      `RLC : begin
          ram_rd_sel = `RRS_DC;
          ram_wr_sel = `RWS_ACC;
          src_sel1 = `ASS_ACC;
          src_sel2 = `ASS_DC;
          alu_op = `ALU_RLC;
          wr = 1'b1;
          psw_set = `PS_CY;
          cy_sel = `CY_PSW;
          pc_wr = `PCW_N;
          pc_sel = `PIS_DC;
          imm_sel = `IDS_DC;
          src_sel3 = `AS3_DC;
          comp_sel = `CSS_DC;
          wr_bit = 1'b0;
          wad2 = `WAD_N;
          rom_addr_sel = `RAS_PC;
          ext_addr_sel = `EAS_DC;
        end
      `RR : begin
          ram_rd_sel = `RRS_DC;
          ram_wr_sel = `RWS_ACC;
          src_sel1 = `ASS_ACC;
          src_sel2 = `ASS_DC;
          alu_op = `ALU_RR;
          wr = 1'b1;
          psw_set = `PS_NOT;
          cy_sel = `CY_0;
          pc_wr = `PCW_N;
          pc_sel = `PIS_DC;
          imm_sel = `IDS_DC;
          src_sel3 = `AS3_DC;
          comp_sel = `CSS_DC;
          wr_bit = 1'b0;
          wad2 = `WAD_N;
          rom_addr_sel = `RAS_PC;
          ext_addr_sel = `EAS_DC;
        end
      `RRC : begin
          ram_rd_sel = `RRS_DC;
          ram_wr_sel = `RWS_ACC;
          src_sel1 = `ASS_ACC;
          src_sel2 = `ASS_DC;
          alu_op = `ALU_RRC;
          wr = 1'b1;
          psw_set = `PS_CY;
          cy_sel = `CY_PSW;
          pc_wr = `PCW_N;
          pc_sel = `PIS_DC;
          imm_sel = `IDS_DC;
          src_sel3 = `AS3_DC;
          comp_sel = `CSS_DC;
          wr_bit = 1'b0;
          wad2 = `WAD_N;
          rom_addr_sel = `RAS_PC;
          ext_addr_sel = `EAS_DC;
        end
      `SETB_C : begin
          ram_rd_sel = `RRS_DC;
          ram_wr_sel = `RWS_DC;
          src_sel1 = `ASS_DC;
          src_sel2 = `ASS_DC;
          alu_op = `ALU_NOP;
          wr = 1'b0;
          psw_set = `PS_CY;
          cy_sel = `CY_1;
          pc_wr = `PCW_N;
          pc_sel = `PIS_DC;
          imm_sel = `IDS_DC;
          src_sel3 = `AS3_PC;
          comp_sel = `CSS_DC;
          wr_bit = 1'b0;
          wad2 = `WAD_N;
          rom_addr_sel = `RAS_PC;
          ext_addr_sel = `EAS_DC;
        end
      `SETB_B : begin
          ram_rd_sel = `RRS_DC;
          ram_wr_sel = `RWS_D;
          src_sel1 = `ASS_DC;
          src_sel2 = `ASS_DC;
          alu_op = `ALU_NOP;
          wr = 1'b1;
          psw_set = `PS_NOT;
          cy_sel = `CY_1;
          pc_wr = `PCW_N;
          pc_sel = `PIS_DC;
          imm_sel = `IDS_DC;
          src_sel3 = `AS3_PC;
          comp_sel = `CSS_DC;
          wr_bit = 1'b1;
          wad2 = `WAD_N;
          rom_addr_sel = `RAS_PC;
          ext_addr_sel = `EAS_DC;
        end
      `SJMP : begin
          ram_rd_sel = `RRS_DC;
          ram_wr_sel = `RWS_DC;
          src_sel1 = `ASS_IMM;
          src_sel2 = `ASS_OP2;
          alu_op = `ALU_PCS;
          wr = 1'b0;
          psw_set = `PS_NOT;
          cy_sel = `CY_0;
          pc_wr = `PCW_N;
          pc_sel = `PIS_DC;
          imm_sel = `IDS_OP2;
          src_sel3 = `AS3_PC;
          comp_sel = `CSS_DC;
          wr_bit = 1'b0;
          wad2 = `WAD_N;
          rom_addr_sel = `RAS_PC;
          ext_addr_sel = `EAS_DC;
        end
      `SUBB_D : begin
          ram_rd_sel = `RRS_D;
          ram_wr_sel = `RWS_ACC;
          src_sel1 = `ASS_RAM;
          src_sel2 = `ASS_ACC;
          alu_op = `ALU_SUB;
          wr = 1'b1;
          psw_set = `PS_AC;
          cy_sel = `CY_PSW;
          pc_wr = `PCW_N;
          pc_sel = `PIS_DC;
          imm_sel = `IDS_DC;
          src_sel3 = `AS3_DC;
          comp_sel = `CSS_DC;
          wr_bit = 1'b0;
          wad2 = `WAD_N;
          rom_addr_sel = `RAS_PC;
          ext_addr_sel = `EAS_DC;
        end
      `SUBB_C : begin
          ram_rd_sel = `RRS_DC;
          ram_wr_sel = `RWS_ACC;
          src_sel1 = `ASS_IMM;
          src_sel2 = `ASS_ACC;
          alu_op = `ALU_SUB;
          wr = 1'b1;
          psw_set = `PS_AC;
          cy_sel = `CY_PSW;
          pc_wr = `PCW_N;
          pc_sel = `PIS_DC;
          imm_sel = `IDS_OP2;
          src_sel3 = `AS3_DC;
          comp_sel = `CSS_DC;
          wr_bit = 1'b0;
          wad2 = `WAD_N;
          rom_addr_sel = `RAS_PC;
          ext_addr_sel = `EAS_DC;
        end
      `SWAP : begin
          ram_rd_sel = `RRS_DC;
          ram_wr_sel = `RWS_DC;
          src_sel1 = `ASS_ACC;
          src_sel2 = `ASS_DC;
          alu_op = `ALU_RLC;
          wr = 1'b0;
          psw_set = `PS_NOT;
          cy_sel = `CY_0;
          pc_wr = `PCW_N;
          pc_sel = `PIS_DC;
          imm_sel = `IDS_DC;
          src_sel3 = `AS3_DC;
          comp_sel = `CSS_DC;
          wr_bit = 1'b0;
          wad2 = `WAD_Y;
          rom_addr_sel = `RAS_PC;
          ext_addr_sel = `EAS_DC;
        end
      `XCH_D : begin
          ram_rd_sel = `RRS_D;
          ram_wr_sel = `RWS_D;
          src_sel1 = `ASS_RAM;
          src_sel2 = `ASS_ACC;
          alu_op = `ALU_XCH;
          wr = 1'b1;
          psw_set = `PS_NOT;
          cy_sel = `CY_1;
          pc_wr = `PCW_N;
          pc_sel = `PIS_DC;
          imm_sel = 2'bxx;
          src_sel3 = `AS3_DC;
          comp_sel = `CSS_DC;
          wr_bit = 1'b0;
          wad2 = `WAD_Y;
          rom_addr_sel = `RAS_PC;
          ext_addr_sel = `EAS_DC;
        end
      `XRL_D : begin
          ram_rd_sel = `RRS_D;
          ram_wr_sel = `RWS_ACC;
          src_sel1 = `ASS_RAM;
          src_sel2 = `ASS_ACC;
          alu_op = `ALU_XOR;
          wr = 1'b1;
          psw_set = `PS_NOT;
          cy_sel = `CY_0;
          pc_wr = `PCW_N;
          pc_sel = `PIS_DC;
          imm_sel = `IDS_DC;
          src_sel3 = `AS3_DC;
          comp_sel = `CSS_DC;
          wr_bit = 1'b0;
          wad2 = `WAD_N;
          rom_addr_sel = `RAS_PC;
          ext_addr_sel = `EAS_DC;
        end
      `XRL_C : begin
          ram_rd_sel = `RRS_DC;
          ram_wr_sel = `RWS_ACC;
          src_sel1 = `ASS_IMM;
          src_sel2 = `ASS_ACC;
          alu_op = `ALU_XOR;
          wr = 1'b1;
          psw_set = `PS_NOT;
          cy_sel = `CY_0;
          pc_wr = `PCW_N;
          pc_sel = `PIS_DC;
          imm_sel = `IDS_OP2;
          src_sel3 = `AS3_DC;
          comp_sel = `CSS_DC;
          wr_bit = 1'b0;
          wad2 = `WAD_N;
          rom_addr_sel = `RAS_PC;
          ext_addr_sel = `EAS_DC;
        end
      `XRL_AD : begin
          ram_rd_sel = `RRS_D;
          ram_wr_sel = `RWS_D;
          src_sel1 = `ASS_RAM;
          src_sel2 = `ASS_ACC;
          alu_op = `ALU_XOR;
          wr = 1'b1;
          psw_set = `PS_NOT;
          cy_sel = `CY_0;
          pc_wr = `PCW_N;
          pc_sel = `PIS_DC;
          imm_sel = `IDS_DC;
          src_sel3 = `AS3_DC;
          comp_sel = `CSS_DC;
          wr_bit = 1'b0;
          wad2 = `WAD_N;
          rom_addr_sel = `RAS_PC;
          ext_addr_sel = `EAS_DC;
        end
      `XRL_CD : begin
          ram_rd_sel = `RRS_D;
          ram_wr_sel = `RWS_D;
          src_sel1 = `ASS_IMM;
          src_sel2 = `ASS_RAM;
          alu_op = `ALU_XOR;
          wr = 1'b1;
          psw_set = `PS_NOT;
          cy_sel = `CY_0;
          pc_wr = `PCW_N;
          pc_sel = `PIS_DC;
          imm_sel = `IDS_OP3;
          src_sel3 = `AS3_DC;
          comp_sel = `CSS_DC;
          wr_bit = 1'b0;
          wad2 = `WAD_N;
          rom_addr_sel = `RAS_PC;
          ext_addr_sel = `EAS_DC;
        end
      default: begin
          ram_rd_sel = 2'bxx;
          ram_wr_sel = 2'bxx;
          src_sel1 = 2'bxx;
          src_sel2 = 2'bxx;
          alu_op = `ALU_NOP;
          imm_sel = 2'bxx;
          wr = 1'b0;
          psw_set = `PS_NOT;
          cy_sel = `CY_0;
          pc_wr = `PCW_N;
          pc_sel = `PIS_DC;
          src_sel3 = `AS3_DC;
          comp_sel = `CSS_DC;
          wr_bit = 1'b0;
          wad2 = `WAD_N;
          rom_addr_sel = `RAS_PC;
          ext_addr_sel = `EAS_DC;
       end

    endcase
    end
    endcase
  end
end

//
// remember current instruction
always @(posedge clk)
  if (state==2'b00)
    op <= #1 op_in;

//
// in case of instructions that needs more than one clock set state
always @(posedge clk)
begin
  if (rst)
    state <= #1 1'b0;
  else begin
    case (state)
      2'b00: begin
        casex (op_in)
          `ACALL :state <= #1 2'b01;
          `AJMP : state <= #1 2'b01;
          `CJNE_R :state <= #1 2'b11;
          `CJNE_I :state <= #1 2'b11;
          `CJNE_D : state <= #1 2'b11;
          `CJNE_C : state <= #1 2'b11;
          `LJMP : state <= #1 2'b01;
          `DJNZ_R :state <= #1 2'b11;
          `DJNZ_D :state <= #1 2'b11;
          `LCALL :state <= #1 2'b01;
          `MOVC_DP :state <= #1 2'b10;
          `MOVC_PC :state <= #1 2'b10;
          `RET : state <= #1 2'b11;
          `RETI : state <= #1 2'b11;
          `SJMP : state <= #1 2'b10;
          `JB : state <= #1 2'b10;
          `JBC : state <= #1 2'b10;
          `JC : state <= #1 2'b10;
          `JMP : state <= #1 2'b10;
          `JNC : state <= #1 2'b10;
          `JNB : state <= #1 2'b10;
          `JNZ : state <= #1 2'b10;
          `JZ : state <= #1 2'b10;
          default: state <= #1 2'b00;
        endcase
      end
      2'b01: state <= #1 2'b00;
      2'b10: state <= #1 2'b01;
      2'b11: state <= #1 2'b10;
      default: state <= #1 2'b00;
    endcase
  end
end

//
//in case of reti
always @(posedge clk)
  if (op==`RETI) reti <= #1 1'b1;
  else reti <= #1 1'b1;

//
//in case of writing to external ram
always @(op_in or rst or rd)
begin
  if (rst)
    write_x = 1'b0;
  else if (rd)
  begin
    casex (op_in)
      `MOVX_AI : write_x = 1'b1;
      `MOVX_AP : write_x = 1'b1;
      default : write_x = 1'b0;
    endcase
  end else write_x = 1'b0;
end


endmodule

