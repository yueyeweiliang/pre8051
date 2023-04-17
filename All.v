//////////////////////////////////////////////////////////////////////
////                                                              ////
////  8051 cores top level module                                 ////
////                                                              ////
////  This file is part of the 8051 cores project                 ////
////  http://www.opencores.org/cores/8051/                        ////
////                                                              ////
////  Description                                                 ////
////  8051 definitions.                                           ////
////                                                              ////
////  To Do:                                                      ////
////   Interrupt prioriti register                                ////
////   timer/counter                                              ////
////   serial port                                                ////
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

`include "defines.v"


module all (rst, clk, rom_addr, int, int_v, reti, data_in, data_out, ext_addr, write, p0_in, p1_in, p2_in, p3_in, p0_out, p1_out, p2_out, p3_out);
// rst           reset - pin
// clk           clock - pin
// rom_addr      program rom addres (pin + internal)
// int           interrupt (internal)
// int_v         interrupt vector (internal)
// reti          return from interrupt (internal)
// data_in       exteranal ram input(pin)
// data_out      exteranal ram output (pin)
// ext_addr      external address
// write         write to external ram
// p0_in, p1_in, p2_in, p3_in   port inputs
// p0_out, p1_out, p2_out, p3_out       port outputs



input rst, clk, int; input [7:0] int_v, data_in, p0_in, p1_in, p2_in, p3_in;

output rom_addr, reti, data_out, ext_addr, write, p0_out, p1_out, p2_out, p3_out;

wire [7:0] op1, op2, op3, dptr_hi, dptr_lo, ri, ri_r, data_out, acc, p0_out, p1_out, p2_out, p3_out;

wire [15:0] rom_addr, pc, ext_addr;

//
// data output is always from accumulator
assign data_out = acc;

//
// ram_rd_sel    ram read (internal)
// ram_wr_sel    ram write (internal)
// ram_wr_sel_r  ram write (internal, registred)
// src_sel1, src_sel2    from decoder to register
// imm_sel       immediate select
wire [1:0] ram_rd_sel, src_sel1, src_sel2, imm_sel;
wire [2:0] ram_wr_sel, ram_wr_sel_r;

//
// wr_addr       ram write addres
// ram_out       data from ram
// sp            stack pointer output
// rd_addr       data ram read addres
wire [7:0] wr_addr, ram_data, ram_out, sp, rd_addr;


//
// src_sel1_r, src_sel2_r       src select, registred
// cy_sel       carry select; from decoder to cy_selct1
// rom_addr_sel rom addres select; alu or pc
// ext_adddr_sel        external addres select; data pointer or Ri
// write_p      output from decoder; write to external ram, go to register;
wire [1:0] src_sel1_r, src_sel2_r, cy_sel, cy_sel_r;
wire src_sel3, src_sel3_r, rom_addr_sel, ext_addr_sel, write_p;

//
//alu_op        alu operation (from decoder)
//alu_op_r      alu operation (registerd)
//psw_set       write to psw or not; from decoder to psw (through register)
wire [3:0] alu_op, alu_op_r; wire [1:0] psw_set, psw_set_r;

//
// immediate, immediate_r        from imediate_sel1 to alu_src1_sel1
// src1. src2, src2     alu sources
// des2, des2           alu destinations
// des2_s               from rom_addr_sel1 to acc and dptr
// des1_r               destination 1 registerd (to comp1)
// psw                  output from psw
// desCy                carry out
// desAc
// desOv                overflow
// wr, wr_r             write to data ram
wire [7:0] immediate, src1, src2, src3, des1, des2, des2_s, des1_r, psw;
wire desCy, desAc, desOv, alu_cy, wr, wr_r;
wire [7:0] immediate_r;


//
// rd           read program rom
// pc_wr_sel    program counter write select (from decoder to pc)
wire rd;
wire [1:0] pc_wr_sel;

//
// op1_n                from op_select to decoder
// op2_n, op2_nr        output of op_select, to alu_src2_sel1, pc1, comp1
// op3_n, op3_nr        output of op_select, to immediate_sel1, ram_wr_sel1
// op2_dr, op2_dr_r     output of op_select, to immediate_sel1, ram_rd_sel1, ram_wr_sel1
wire [7:0] op1_n, op2_n, op2_dr, op2_dr_r, op3_n, op3_nr, op2_nr, pc_hi_r;

//
// comp_sel     select source1 and source2 to compare
// eq           result (from comp1 to decoder)
// rn_r         3'b000+rn_r= register address (registerd)
// wad2, wad2_r write to accumulator from destination 2
wire [2:0] comp_sel;
wire [4:0] rn_r;
wire eq, wad2, wad2_r;


//
// wr_bit_addr  write ram bit addresable
// bit_data     bit data from ram to ram_select
// bit_out      bit data from ram_select to alu and cy_select
wire wr_bit_addr, wr_bit_addr_r, bit_data, bit_out;

//
// p     parity from accumulator to psw
wire p;


//
//registers
reg8 reg8_pc_hi(.clk(clk), .in(pc[15:8]), .out(pc_hi_r));
reg1 reg1_write(.clk(clk), .in(write_p), .out(write));

reg2 reg2_src_sel1(.clk(clk), .in(src_sel1), .out(src_sel1_r));
reg2 reg2_src_sel2(.clk(clk), .in(src_sel2), .out(src_sel2_r));
reg1 reg1_sre_sel3(.clk(clk), .in(src_sel3), .out(src_sel3_r));

reg1 reg1_wr (.clk(clk), .in(wr), .out(wr_r));
reg3 reg3_wr_sel(.clk(clk), .in(ram_wr_sel), .out(ram_wr_sel_r));
reg8 reg8_ram_op(.clk(clk), .in(op2_n), .out(op2_nr));
reg8 reg8_ri(.clk(clk), .in(ri), .out(ri_r));
reg8 reg8_op3(.clk(clk), .in(op3_n), .out(op3_nr));
reg5 reg5_rn(.clk(clk), .in({psw[4:3], op1_n[2:0]}), .out(rn_r));

reg4 reg4_alu_op(.clk(clk), .in(alu_op), .out(alu_op_r));

reg8 reg8_imm(.clk(clk), .in(immediate), .out(immediate_r));
reg1 reg1_bit_addr(.clk(clk), .in(wr_bit_addr), .out(wr_bit_addr_r));

reg1 reg1_wad2(.clk(clk), .in(wad2), .out(wad2_r));
reg8 reg8_des1(.clk(clk), .in(des1), .out(des1_r));
reg2 reg2_cy(.clk(clk), .in(cy_sel), .out(cy_sel_r));
reg2 psw_reg (.clk(clk), .in(psw_set), .out(psw_set_r));
reg8 op2_dr_reg (.clk(clk), .in(op2_dr), .out(op2_dr_r));

//
//program counter
pc pc1(.rst(rst), .clk(clk), .pc_out(pc), .alu({des1,des2}), .pc_wr_sel(pc_wr_sel), .op1(op1_n), .op2(op2_n), .op3(op3_n), .wr(pc_wr),
       .rd(rd), .int(int));

//
// decoder
decoder decoder1(.clk(clk), .rst(rst), .op_in(op1_n), .ram_rd_sel(ram_rd_sel), .ram_wr_sel(ram_wr_sel), .wr_bit(wr_bit_addr),
                 .src_sel1(src_sel1), .src_sel2(src_sel2), .src_sel3(src_sel3), .alu_op(alu_op), .psw_set(psw_set), .imm_sel(imm_sel), .cy_sel(cy_sel),
                 .wr(wr), .pc_wr(pc_wr), .pc_sel(pc_wr_sel), .comp_sel(comp_sel), .eq(eq), .rom_addr_sel(rom_addr_sel), .ext_addr_sel(ext_addr_sel),
                 .wad2(wad2), .rd(rd), .write_x(write_p), .reti(reti));



//
// ram red and ram write select
ram_rd_sel ram_rd_sel1 (.sel(ram_rd_sel),  .sp(sp), .ri(ri), .rn({psw[4:3], op1_n[2:0]}), .imm(op2_dr), .out(rd_addr));
ram_wr_sel ram_wr_sel1 (.sel(ram_wr_sel_r),  .sp(sp), .rn(rn_r), .imm(op2_dr_r), .ri(ri_r), .imm2(op3_nr), .out(wr_addr));


//
//alu
alu alu1(.op_code(alu_op_r), .src1(src1), .src2(src2), .src3(src3), .srcCy(alu_cy), .srcAc(psw[6]), .des1(des1), .des2(des2), .desCy(desCy), .desAc(desAc),
         .desOv(desOv), .bit_in(bit_out));


//
//
immediate_sel immediate_sel1(.sel(imm_sel), .op2(op2_dr), .op3(op3_n), .pch(pc_hi_r), .pcl(pc[7:0]), .out(immediate));

//
//data ram
ram ram1(.rst(rst), .clk(clk), .rd_addr(rd_addr), .rd_data(ram_data), .wr_addr(wr_addr), .wr_bit(wr_bit_addr_r),
         .wr_data(des1), .wr(wr_r), .bit_data_in(desCy), .bit_data_out(bit_data));

//
//
acc acc1(.clk(clk), .rst(rst), .bit_in(desCy), .data_in(des1), .data2_in(des2_s), .wr(wr_r), .wr_bit(wr_bit_addr_r), .wad2(wad2_r), .wr_addr(wr_addr), .data_out(acc), .p(p));


//
//
alu_src1_sel alu_src1_sel1(.sel(src_sel1_r), .immediate(immediate_r), .acc(acc), .ram(ram_out), .ext(data_in), .des(src1));
alu_src2_sel alu_src2_sel1(.sel(src_sel2_r), .op2(op2_nr), .acc(acc), .ram(ram_out), .des(src2));
alu_src3_sel alu_src3_sel1(.sel(src_sel3_r), .pc(pc_hi_r), .dptr(dptr_hi), .out(src3));

//
//
comp comp1(.sel(comp_sel), .eq(eq), .b_in(bit_out), .cy(psw[7]), .acc(acc), .ram(ram_out), .op2(op2_nr), .des(des1_r));

//
//stack pointer
sp sp1(.clk(clk), .rst(rst), .ram_rd_sel(ram_rd_sel), .ram_wr_sel(ram_wr_sel), .wr_addr(wr_addr), .wr(wr_r), .wr_bit(wr_bit_addr_r), .data_in(des1), .data_out(sp));

//
//program rom
rom rom1(.rst(rst), .clk(clk), .addr(rom_addr), .data1(op1), .data2(op2), .data3(op3));

//
//data pointer
dptr dptr1(.clk(clk), .rst(rst), .addr(wr_addr), .data_in(des1), .data2_in(des2_s), .wr(wr_r), .wr_bit(wr_bit_addr_r), .wd2(ram_wr_sel_r), .data_hi(dptr_hi), .data_lo(dptr_lo));

//
//
cy_select cy_select1(.cy_sel(cy_sel_r), .cy_in(psw[7]), .data_in(bit_out), .data_out(alu_cy));

//
//program status word
psw psw1 (.clk(clk), .rst(rst), .addr(wr_addr), .bit_in(desCy), .data_in(des1), .wr(wr_r), .wr_bit(wr_bit_addr_r), .data_out(psw), .p(p), .cy_in(desCy), .ac_in(desAc), .ov_in(desOv), .set(psw_set_r));

//
//
IndiAddr IndiAddr1 (.clk(clk), .rst(rst), .addr(wr_addr), .data_in(des1), .wr(wr_r), .wr_bit(wr_bit_addr_r), .data_out(ri), .sel(op1_n[0]), .bank(psw[4:3]));

//
//
rom_addr_sel rom_addr_sel1(.rst(rst), .clk(clk), .select(rom_addr_sel), .des1(des1), .des2(des2), .pc(pc), .op1(op1), .out_data(des2_s), .out_addr(rom_addr));

//
//
ext_addr_sel ext_addr_sel1(.clk(clk), .select(ext_addr_sel), .write(write_p), .dptr_hi(dptr_hi), .dptr_lo(dptr_lo), .ri(ri), .addr_out(ext_addr));

//
//
ram_sel ram_sel1(.addr(rd_addr), .bit_in(bit_data), .in_ram(ram_data), .psw(psw), .acc(acc), .dptr_hi(dptr_hi), .port0(p0_in), .port1(p1_in), .port2(p2_in),
                .port3(p3_in), .bit_out(bit_out), .out_data(ram_out));

//
//
port_out port_out1(.clk(clk), .rst(rst), .bit_in(desCy), .data_in(des1), .wr(wr_r), .wr_bit(wr_bit_addr_r), .wr_addr(wr_addr), .p0(p0_out), .p1(p1_out),
                   .p2(p2_out), .p3(p3_out));

//
//
op_select op_select1(.clk(clk), .op1(op1), .op2(op2), .op3(op3), .op1_out(op1_n), .op2_out(op2_n), .op2_direct(op2_dr), .op3_out(op3_n), .int(int),
                     .int_v(int_v), .pc(pc[7:0]), .rd(rd));


endmodule
