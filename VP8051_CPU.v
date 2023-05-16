module VP_CPU (rst, clk, rom_addr,
                 int1,int2,int3,int4,int5,
                 int_v1,  int_v2,  int_v3,  int_v4,  int_v5, 
                 ext_input1,ext_input2,ext_input3,ext_input4,ext_input5,
                 reti, data_in, data_out, ext_addr, write, p0_in, p1_in, p2_in, p3_in, p0_out, p1_out, p2_out, p3_out);

input rst, clk, int1,int2,int3,int4,int5; 
input [7:0] int_v1,  int_v2,  int_v3,  int_v4,  int_v5,  data_in, p0_in, p1_in, p2_in, p3_in,ext_input1,ext_input2,ext_input3,ext_input4,ext_input5;

output rom_addr, reti, data_out, ext_addr, write, p0_out, p1_out, p2_out, p3_out;

wire [7:0] op1, op2, op3, dptr_hi, dptr_lo, ri, ri_r, data_out, acc, p0_out, p1_out, p2_out, p3_out;
wire [15:0] rom_addr, pc, ext_addr;

//
// data output is always from accumulator
// assign data_out = acc;

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

wire [15:0] pc_out1,pc_out2,pc_out3,pc_out4,pc_out5;
wire [7:0] psw1,psw2,psw3,psw4,psw5,
            op1_out_o1,op1_out_o2,op1_out_o3,op1_out_o4,op1_out_o5,
            op1_out_o1_wb,op1_out_o2_wb,op1_out_o3_wb,op1_out_o4_wb,op1_out_o5_wb;
wire [15:0] of_pc1,of_pc2,of_pc3,of_pc4,of_pc5;
//rd
 rd VP_rd(.clk(clk),.rst(rst),.rd1_r(rd1_r), .rd2_r(rd2_r),.rd3_r(rd3_r),.rd4_r(rd4_r),.rd5_r(rd5_r), .rd1(rd1),.rd2(rd2),.rd3(rd3),.rd4(rd4),.rd5(rd5),.ex_code(ex_code),.id_code(id_code));
 rd_reg VP_rd_reg(.clk(clk),.rst(rst),.rd1(rd1),.rd2(rd2),.rd3(rd3),.rd4(rd4),.rd5(rd5),.rd1_r(rd1_r),.rd2_r(rd2_r),.rd3_r(rd3_r),.rd4_r(rd4_r),.rd5_r(rd5_r));
 
//program counter
// pc pc1(.rst(rst), .clk(clk), .pc_out(pc), .alu({des1,des2}), .pc_wr_sel(pc_wr_sel), .op1(op1_n), .op2(op2_n), .op3(op3_n), .wr(pc_wr), .rd(rd), .int(int));
pc VP_pc1( .clk(clk),.rst(rst),.pc_out(pc_out1), .alu({des1_reg1,des2_reg1}), .pc_wr_sel(pc_sel1), .op1(op1_out1), .op2(op2_out1), .op3(op3_out1), .wr(pc_wr1), .rd (rd1), .int(int1));
pc VP_pc2( .clk(clk),.rst(rst),.pc_out(pc_out2), .alu({des1_reg2,des2_reg2}), .pc_wr_sel(pc_sel2), .op1(op1_out2), .op2(op2_out2), .op3(op3_out2), .wr(pc_wr2), .rd (rd2), .int(int2));
pc VP_pc3( .clk(clk),.rst(rst),.pc_out(pc_out3), .alu({des1_reg3,des2_reg3}), .pc_wr_sel(pc_sel3), .op1(op1_out3), .op2(op2_out3), .op3(op3_out3), .wr(pc_wr3), .rd (rd3), .int(int3));
pc VP_pc4( .clk(clk),.rst(rst),.pc_out(pc_out4), .alu({des1_reg4,des2_reg4}), .pc_wr_sel(pc_sel4), .op1(op1_out4), .op2(op2_out4), .op3(op3_out4), .wr(pc_wr4), .rd (rd4), .int(int4));
pc VP_pc5( .clk(clk),.rst(rst),.pc_out(pc_out5), .alu({des1_reg5,des2_reg5}), .pc_wr_sel(pc_sel5), .op1(op1_out5), .op2(op2_out5), .op3(op3_out5), .wr(pc_wr5), .rd (rd5), .int(int5));

//rom_addr_sel rom_addr_sel1(.rst(rst), .clk(clk), .select(rom_addr_sel), .des1(des1), .des2(des2), .pc(pc), .op1(op1), .out_data(des2_s), .out_addr(rom_addr));
rom_addr_sel  VP_rom_addr_sel1(.clk(clk), .rst(rst), .select(rom_addr_sel1), .des1(des1_reg1), .des2(des2_reg1), .pc(pc_out1), .op1(data1), .out_data(outdata1), .out_addr(out_addr1));
rom_addr_sel  VP_rom_addr_sel2(.clk(clk), .rst(rst), .select(rom_addr_sel2), .des1(des1_reg2), .des2(des2_reg2), .pc(pc_out2), .op1(data4), .out_data(outdata2), .out_addr(out_addr2));
rom_addr_sel  VP_rom_addr_sel3(.clk(clk), .rst(rst), .select(rom_addr_sel3), .des1(des1_reg3), .des2(des2_reg3), .pc(pc_out3), .op1(data7), .out_data(outdata3), .out_addr(out_addr3));
rom_addr_sel  VP_rom_addr_sel4(.clk(clk), .rst(rst), .select(rom_addr_sel4), .des1(des1_reg4), .des2(des2_reg4), .pc(pc_out4), .op1(data10), .out_data(outdata4), .out_addr(out_addr4));
rom_addr_sel  VP_rom_addr_sel5(.clk(clk), .rst(rst), .select(rom_addr_sel5), .des1(des1_reg5), .des2(des2_reg5), .pc(pc_out5), .op1(data13), .out_data(outdata5), .out_addr(out_addr5));

//program rom
//rom rom1(.rst(rst), .clk(clk), .addr(rom_addr), .data1(op1), .data2(op2), .data3(op3));
rom VP_rom1(.rst(rst),.clk(clk), .addr(out_addr1), .data1(data1),.data2(data2),.data3(data3));
rom VP_rom2(.rst(rst),.clk(clk), .addr(out_addr2), .data1(data4),.data2(data5),.data3(data6));
rom VP_rom3(.rst(rst),.clk(clk), .addr(out_addr3), .data1(data7),.data2(data8),.data3(data9));
rom VP_rom4(.rst(rst),.clk(clk), .addr(out_addr4), .data1(data10),.data2(data11),.data3(data12));
rom VP_rom5(.rst(rst),.clk(clk), .addr(out_addr5), .data1(data13),.data2(data14),.data3(data15));

// op_select op_select1(.clk(clk), .op1(op1), .op2(op2), .op3(op3), .op1_out(op1_n), .op2_out(op2_n), .op2_direct(op2_dr), .op3_out(op3_n), .int(int),.int_v(int_v), .pc(pc[7:0]), .rd(rd));
op_select VP_op_select1(.clk(clk), .rd(rd1),.int(int1), .pc(pc_out1[7:0]), .int_v(int_v1), .op1(data1), .op2(data2), .op3(data3), .op1_out(op1_out1), .op2_out(op2_out1),
                         .op2_direct(op2_direct1), .op3_out(op3_out1));                        
op_select VP_op_select2(.clk(clk), .rd(rd2),.int(int2), .pc(pc_out2[7:0]), .int_v(int_v2), .op1(data4), .op2(data5), .op3(data6), .op1_out(op1_out2), .op2_out(op2_out2),
                             .op2_direct(op2_direct2), .op3_out(op3_out2));
op_select VP_op_select3(.clk(clk), .rd(rd3),.int(int3), .pc(pc_out3[7:0]), .int_v(int_v3), .op1(data7), .op2(data8), .op3(data9), .op1_out(op1_out3), .op2_out(op2_out3),
                             .op2_direct(op2_direct3), .op3_out(op3_out3));
op_select VP_op_select4(.clk(clk), .rd(rd4),.int(int4), .pc(pc_out4[7:0]), .int_v(int_v4), .op1(data10), .op2(data11), .op3(data12), .op1_out(op1_out4), .op2_out(op2_out4),
                             .op2_direct(op2_direct4), .op3_out(op3_out4));
op_select VP_op_select5(.clk(clk), .rd(rd5),.int(int5), .pc(pc_out5[7:0]), .int_v(int_v5), .op1(data13), .op2(data14), .op3(data15), .op1_out(op1_out5), .op2_out(op2_out5),
                             .op2_direct(op2_direct5), .op3_out(op3_out5));

//reg_if_id
reg_if_id VP_reg_if_id(  .clk(clk), .rst(rst),.if_pc1(pc_out1),.if_pc2(pc_out2),.if_pc3(pc_out3),.if_pc4(pc_out),.if_pc5(pc_out5),
	        .if_out_data1(outdata1),.if_out_data2(outdata2),.if_out_data3(outdata3),.if_out_data4(outdata4),.if_out_data5(outdata5),
	        .if_op1_out1(op1_out1),.if_op1_out2(op1_out2),.if_op1_out3(op1_out3),.if_op1_out4(op1_out4),.if_op1_out5(op1_out5),
	        .if_op2_out1(op2_out1),.if_op2_out2(op2_out2),.if_op2_out3(op2_out2),.if_op2_out4(op2_out4),.if_op2_out5(op2_out5),
	        .if_op3_out1(op3_out1),.if_op3_out2(op3_out2),.if_op3_out3(op3_out3),.if_op3_out4(op3_out4),.if_op3_out5(op3_out5),
	        .if_op2_direct1(op2_direct1),.if_op2_direct2(op2_direct2),.if_op2_direct3(op2_direct3),.if_op2_direct4(op2_direct4),.if_op2_direct5(op2_direct5),
	        
	        .id_pc1(id_pc1),.id_pc2(id_pc2),.id_pc3(id_pc3),.id_pc4(id_pc4),.id_pc5(id_pc5),
	        .id_out_data1(id_out_data1),.id_out_data2(id_out_data2),.id_out_data3(id_out_data3),.id_out_data4(id_out_data4),.id_out_data5(id_out_data5),
	        .id_op1_out1(id_op1_out1),.id_op1_out2(id_op1_out2),.id_op1_out3(id_op1_out3),.id_op1_out4(id_op1_out4),.id_op1_out5(id_op1_out5),
	        .id_op2_out1(id_op2_out1),.id_op2_out2(id_op2_out2),.id_op2_out3(id_op2_out3),.id_op2_out4(id_op2_out4),.id_op2_out5(id_op2_out5),
	        .id_op3_out1(id_op3_out1),.id_op3_out2(id_op3_out3),.id_op3_out3(id_op3_out3),.id_op3_out4(id_op3_out4),.id_op3_out5(id_op3_out5),
	        .id_op2_direct1(id_op2_direct1), .id_op2_direct2(id_op2_direct2),.id_op2_direct3(id_op2_direct3),.id_op2_direct4(id_op2_direct4),.id_op2_direct5(id_op2_direct5)
);

//comp comp1(.sel(comp_sel), .eq(eq), .b_in(bit_out), .cy(psw[7]), .acc(acc), .ram(ram_out), .op2(op2_nr), .des(des1_r));
comp VP_comp1(.sel(comp_sel1),.eq(eq1), .b_in(bit_out1), .cy(psw1[7]), .acc(acc1), .ram(ram_out_data1), .op2(id_op2_out1), .des(des1_reg1));
comp VP_comp2(.sel(comp_sel2),.eq(eq2), .b_in(bit_out2), .cy(psw2[7]), .acc(acc2), .ram(ram_out_data2), .op2(id_op2_out2), .des(des1_reg2));
comp VP_comp3(.sel(comp_sel3),.eq(eq3), .b_in(bit_out3), .cy(psw3[7]), .acc(acc3), .ram(ram_out_data3), .op2(id_op2_out3), .des(des1_reg3));
comp VP_comp4(.sel(comp_sel4),.eq(eq4), .b_in(bit_out4), .cy(psw4[7]), .acc(acc4), .ram(ram_out_data4), .op2(id_op2_out4), .des(des1_reg4));
comp VP_comp5(.sel(comp_sel5),.eq(eq5), .b_in(bit_out5), .cy(psw5[7]), .acc(acc5), .ram(ram_out_data5), .op2(id_op2_out5), .des(des1_reg5));

// decoder
/* decoder decoder1(.clk(clk), .rst(rst), .op_in(op1_n), .ram_rd_sel(ram_rd_sel), .ram_wr_sel(ram_wr_sel), .wr_bit(wr_bit_addr),
                 .src_sel1(src_sel1), .src_sel2(src_sel2), .src_sel3(src_sel3), .alu_op(alu_op), .psw_set(psw_set), .imm_sel(imm_sel), .cy_sel(cy_sel),
                 .wr(wr), .pc_wr(pc_wr), .pc_sel(pc_wr_sel), .comp_sel(comp_sel), .eq(eq), .rom_addr_sel(rom_addr_sel), .ext_addr_sel(ext_addr_sel),
                 .wad2(wad2), .rd(rd), .write_x(write_p), .reti(reti)); */

decoder VP_decoder1(.clk(clk), .rst(rst), .op_in(id_op1_out1),
                     .ram_rd_sel(ram_rd_sel1), .ram_wr_sel(ram_wr_sel1), .wr_bit(wr_bit1),.wr(wr1),
                     .src_sel1(src_sel1_1), .src_sel2(src_sel2_1), .src_sel3(src_sel3_1),
                     .alu_op(alu_op1), .psw_set(psw_set1), .cy_sel(cy_sel1), .imm_sel(imm_sel1), .pc_wr(pc_wr1), .pc_sel(pc_sel1),
                     .comp_sel(comp_sel1), .eq(eq1), .rom_addr_sel(rom_addr_sel1), .ext_addr_sel(ext_addr_sel1), .wad2(wad2_1), .write_x(write_x1), .reti(reti1));

decoder VP_decoder2(.clk(clk), .rst(rst), .op_in(id_op1_out2),
                     .ram_rd_sel(ram_rd_sel2), .ram_wr_sel(ram_wr_sel2), .wr_bit(wr_bit2),.wr(wr2),
                     .src_sel1(src_sel1_2), .src_sel2(src_sel2_2), .src_sel3(src_sel3_2),
                     .alu_op(alu_op2), .psw_set(psw_set2), .cy_sel(cy_sel2), .imm_sel(imm_sel2), .pc_wr(pc_wr2), .pc_sel(pc_sel2),
                     .comp_sel(comp_sel2), .eq(eq2), .rom_addr_sel(rom_addr_sel2), .ext_addr_sel(ext_addr_sel2), .wad2(wad2_2), .write_x(write_x2), .reti(reti2));
decoder VP_decoder3(.clk(clk), .rst(rst), .op_in(id_op1_out3),
                     .ram_rd_sel(ram_rd_sel3), .ram_wr_sel(ram_wr_sel3), .wr_bit(wr_bit3),.wr(wr3),
                     .src_sel1(src_sel1_3), .src_sel2(src_sel2_3), .src_sel3(src_sel3_3),
                     .alu_op(alu_op3), .psw_set(psw_set3), .cy_sel(cy_sel3), .imm_sel(imm_sel3), .pc_wr(pc_wr3), .pc_sel(pc_sel3),
                     .comp_sel(comp_sel3), .eq(eq3), .rom_addr_sel(rom_addr_sel3), .ext_addr_sel(ext_addr_sel3), .wad2(wad2_3), .write_x(write_x3), .reti(reti3));              

decoder VP_decoder4(.clk(clk), .rst(rst), .op_in(id_op1_out4),
                     .ram_rd_sel(ram_rd_sel4), .ram_wr_sel(ram_wr_sel4), .wr_bit(wr_bit4),.wr(wr4),
                     .src_sel1(src_sel1_4), .src_sel2(src_sel2_4), .src_sel3(src_sel3_4),
                     .alu_op(alu_op4), .psw_set(psw_set4), .cy_sel(cy_sel4), .imm_sel(imm_sel4), .pc_wr(pc_wr4), .pc_sel(pc_sel4),
                     .comp_sel(comp_sel4), .eq(eq4), .rom_addr_sel(rom_addr_sel4), .ext_addr_sel(ext_addr_sel4), .wad2(wad2_4), .write_x(write_x4), .reti(reti4));

decoder VP_decoder5(.clk(clk), .rst(rst), .op_in(id_op1_out5),
                     .ram_rd_sel(ram_rd_sel5), .ram_wr_sel(ram_wr_sel5), .wr_bit(wr_bit5),.wr(wr5),
                     .src_sel1(src_sel1_5), .src_sel2(src_sel2_5), .src_sel3(src_sel3_5),
                     .alu_op(alu_op5), .psw_set(psw_set5), .cy_sel(cy_sel5), .imm_sel(imm_sel5), .pc_wr(pc_wr5), .pc_sel(pc_sel5),
                     .comp_sel(comp_sel5), .eq(eq5), .rom_addr_sel(rom_addr_sel5), .ext_addr_sel(ext_addr_sel5), .wad2(wad2_5),  .write_x(write_x5), .reti(reti5));

mux_opcode VP_mux_opcode(.opcode1(id_op1_out1),.opcode2(id_op1_out2),.opcode3(id_op1_out3),.opcode4(id_op1_out4),.opcode5(id_op1_out5),.id_code(id_code),.id_opcode(id_opcode));

VP_ctr_alu VP_ctr_alu1(.clk(clk),.rst(rst),.opcode(id_opcode),
 .alu_code(alu_code),.ex_time_4_reg(ex_time_4_reg),.ex_time_2_reg(ex_time_2_reg),
.ex_time_4_reg_r(ex_time_4_reg_r),
                        .ex_time_2_reg_r(ex_time_2_reg_r)
);

ctr_reg VP_ctr_reg1(
.clk(clk), .rst(rst), .ex_time_4_reg(ex_time_4_reg),.ex_time_2_reg(ex_time_2_reg),.ex_time_4_reg_r(ex_time_4_reg_r),.ex_time_2_reg_r(ex_time_2_reg_r));

//reg
reg_id_of VP_reg_id_of( 
             .clk(clk),.rst(rst),
              .op1_out_i1(id_op1_out1),.op1_out_i2(id_op1_out2),.op1_out_i3(id_op1_out3),.op1_out_i4(id_op1_out4),.op1_out_i5(id_op1_out5),
	         .op2_out_i1(id_op2_out1), .op2_out_i2(id_op2_out2), .op2_out_i3(id_op2_out3),.op2_out_i4(id_op2_out4),.op2_out_i5(id_op2_out5),
	         .op3_out_i1(id_op3_out1), .op3_out_i2(id_op3_out2), .op3_out_i3(id_op3_out3),.op3_out_i4(id_op3_out4),.op3_out_i5(id_op3_out5),
	         .op2_direct_i1(id_op2_direct1),.op2_direct_i2(id_op2_direct2),.op2_direct_i3(id_op2_direct3),.op2_direct_i4(id_op2_direct4),.op2_direct_i5(id_op2_direct5),
	         .ram_rd_sel_i1(ram_rd_sel1),.ram_rd_sel_i2(ram_rd_sel2),.ram_rd_sel_i3(ram_rd_sel3),.ram_rd_sel_i4(ram_rd_sel4),.ram_rd_sel_i5(ram_rd_sel5),
             .ram_wr_sel_i1(ram_wr_sel1),.ram_wr_sel_i2(ram_wr_sel2),.ram_wr_sel_i3(ram_wr_sel3),.ram_wr_sel_i4(ram_wr_sel4),.ram_wr_sel_i5(ram_wr_sel5),
	         .src_sel1_i1(src_sel1_1),.src_sel1_i2(src_sel1_2),.src_sel1_i3(src_sel1_3),.src_sel1_i4(src_sel1_4),.src_sel1_i5(src_sel1_5),
	         .src_sel2_i1(src_sel2_1), .src_sel2_i2(src_sel2_2), .src_sel2_i3(src_sel2_3), .src_sel2_i4(src_sel2_4), .src_sel2_i5(src_sel2_5),
	         .src_sel3_i1(src_sel3_1),.src_sel3_i2(src_sel3_2),.src_sel3_i3(src_sel3_3),.src_sel3_i4(src_sel3_4),.src_sel3_i5(src_sel3_5),
	         .psw_set_i1(psw_set1),.psw_set_i2(psw_set2),.psw_set_i3(psw_set3),.psw_set_i4(psw_set4),.psw_set_i5(psw_set5),
	         .alu_op_i1(alu_op1),.alu_op_i2(alu_op2),.alu_op_i3(alu_op3),.alu_op_i4(alu_op4),.alu_op_i5(alu_op5),
	         .cy_sel_i1(cy_sel1),.cy_sel_i2(cy_sel2),.cy_sel_i3(cy_sel3),.cy_sel_i4(cy_sel4),.cy_sel_i5(cy_sel5),
	         .imm_sel_i1(imm_sel1),.imm_sel_i2(imm_sel2),.imm_sel_i3(imm_sel3),.imm_sel_i4(imm_sel4),.imm_sel_i5(imm_sel5),
              .wr_i1(wr1),.wr_i2(wr2),.wr_i3(wr3),.wr_i4(wr4),.wr_i5(wr5),
             //  .wr_bit_o1(wr_bit_o1),.wr_bit_o2(wr_bit_o2),.wr_bit_o3(wr_bit_o3),.wr_bit_o4(wr_bit_o4),.wr_bit_o5(wr_bit_o5),
              //  .pc_wr_i1, pc_wr_i2, pc_wr_i3, pc_wr_i4, pc_wr_i5,
	          //  pc_sel_i1, pc_sel_i2, pc_sel_i3, pc_sel_i4, pc_sel_i5,
              //  comp_sel_i1,comp_sel_i2,comp_sel_i3,comp_sel_i4,comp_sel_i5,
	           .wr_bit_i1(wr_bit1),.wr_bit_i2(wr_bit2),.wr_bit_i3(wr_bit3),.wr_bit_i4(wr_bit4),.wr_bit_i5(wr_bit5),
	          //  rom_addr_sel_i1,rom_addr_sel_i2,rom_addr_sel_i3,rom_addr_sel_i4,rom_addr_sel_i5,
	          .ext_addr_sel_i1(ext_addr_sel1),.ext_addr_sel_i2(ext_addr_sel2),.ext_addr_sel_i3(ext_addr_sel3),.ext_addr_sel_i4(ext_addr_sel4),.ext_addr_sel_i5(ext_addr_sel5),
	          .wad2_i1(wad2_1), .wad2_i2(wad2_2),.wad2_i3(wad2_3), .wad2_i4(wad2_4), .wad2_i5(wad2_5),
	          .reti_i1(reti1),.reti_i2(reti2),.reti_i3(reti3),.reti_i4(reti4),.reti_i5(reti5),
	          .write_x_i1(write_x1),.write_x_i2(write_x2),.write_x_i3(write_x3),.write_x_i4(write_x4),.write_x_i5(write_x5),
	           .id_pc1(id_pc1),.id_pc2(id_pc2),.id_pc3(id_pc3),.id_pc4(id_pc4),.id_pc5(id_pc5),
	           .alu_code(alu_code),
	            .id_out_data1(id_out_data1),.id_out_data2(id_out_data2),.id_out_data3(id_out_data3),.id_out_data4(id_out_data4),.id_out_data5(id_out_data5),
	
	          .op1_out_o1(op1_out_o1),.op1_out_o2(op1_out_o2),.op1_out_o3(op1_out_o3),.op1_out_o4(op1_out_o4),.op1_out_o5(op1_out_o5),
	          .op2_out_o1(op2_out_o1),.op2_out_o2(op2_out_o2),.op2_out_o3(op2_out_o3),.op2_out_o4(op2_out_o4),.op2_out_o5(op2_out_o5),
	          .op3_out_o1(op3_out_o1),.op3_out_o2(op3_out_o2),.op3_out_o3(op3_out_o3),.op3_out_o4(op3_out_o4),.op3_out_o5(op3_out_o5),
	          .op2_direct_o1(op2_direct_o1),.op2_direct_o2(op2_direct_o2),.op2_direct_o3(op2_direct_o3),.op2_direct_o4(op2_direct_o4),.op2_direct_o5(op2_direct_o5),
	          .ram_rd_sel_o1(ram_rd_sel_o1), .ram_rd_sel_o2(ram_rd_sel_o2), .ram_rd_sel_o3(ram_rd_sel_o3), .ram_rd_sel_o4(ram_rd_sel_o4), .ram_rd_sel_o5(ram_rd_sel_o5),
	          .ram_wr_sel_o1(ram_wr_sel_o1), .ram_wr_sel_o2(ram_wr_sel_o2), .ram_wr_sel_o3(ram_wr_sel_o3), .ram_wr_sel_o4(ram_wr_sel_o4), .ram_wr_sel_o5(ram_wr_sel_o5),
	          .src_sel1_o1(src_sel1_o1), .src_sel1_o2(src_sel1_o2), .src_sel1_o3(src_sel1_o3), .src_sel1_o4(src_sel1_o4), .src_sel1_o5(src_sel1_o5),
	          .src_sel2_o1(src_sel2_o1),.src_sel2_o2(src_sel2_o2),.src_sel2_o3(src_sel2_o3),.src_sel2_o4(src_sel2_o4),.src_sel2_o5(src_sel2_o5),
	          .src_sel3_o1(src_sel3_o1),.src_sel3_o2(src_sel3_o2),.src_sel3_o3(src_sel3_o3),.src_sel3_o4(src_sel3_o4),.src_sel3_o5(src_sel3_o5),
	          .psw_set_o1(psw_set_o1),.psw_set_o2(psw_set_o2),.psw_set_o3(psw_set_o3),.psw_set_o4(psw_set_o1),.psw_set_o5(psw_set_o1),
	          .alu_op_o1(alu_op_o1),.alu_op_o2(alu_op_o2),.alu_op_o3(alu_op_o3),.alu_op_o4(alu_op_o4),.alu_op_o5(alu_op_o5),
	          .cy_sel_o1(cy_sel_o1),.cy_sel_o2(cy_sel_o2),.cy_sel_o3(cy_sel_o3),.cy_sel_o4(cy_sel_o4),.cy_sel_o5(cy_sel_o5),
	          .imm_sel_o1(imm_sel_o1),.imm_sel_o2(imm_sel_o2),.imm_sel_o3(imm_sel_o3),.imm_sel_o4(imm_sel_o4),.imm_sel_o5(imm_sel_o5),
               .wr_o1(wr_o1), .wr_o2(wr_o2), .wr_o3(wr_o3), .wr_o4(wr_o4), .wr_o5(wr_o5),
	           //   pc_wr_o1,pc_wr_o2,pc_wr_o3,pc_wr_o4,pc_wr_o5,
	           //   pc_sel_o1,pc_sel_o2,pc_sel_o3,pc_sel_o4,pc_sel_o5,
	           //    comp_sel_o1,comp_sel_o2,comp_sel_o3,comp_sel_o4,comp_sel_o5,
              .wr_bit_o1(wr_bit_o1),.wr_bit_o2(wr_bit_o2),.wr_bit_o3(wr_bit_o3),.wr_bit_o4(wr_bit_o4),.wr_bit_o5(wr_bit_o5),
	           //   rom_addr_sel_o1, rom_addr_sel_o2, rom_addr_sel_o3, rom_addr_sel_o4, rom_addr_sel_o5,
               .ext_addr_sel_o1(ext_addr_sel_o1),.ext_addr_sel_o2(ext_addr_sel_o2),.ext_addr_sel_o3(ext_addr_sel_o3),.ext_addr_sel_o4(ext_addr_sel_o4),.ext_addr_sel_o5(ext_addr_sel_o5),
              .wad2_o1(wad2_o1),  .wad2_o2(wad2_o2),  .wad2_o3(wad2_o3),  .wad2_o4(wad2_o4),  .wad2_o5(wad2_o5),
	           //        rd_o1,rd_o2,rd_o3,rd_o4,rd_o5,
	          .reti_o1(reti_o1),.reti_o2(reti_o2),.reti_o3(reti_o3),.reti_o4(reti_o4),.reti_o5(reti_o5),
              .write_x_o1(write_x_o1),.write_x_o2(write_x_o2),.write_x_o3(write_x_o3),	.write_x_o4(write_x_o4),.write_x_o5(write_x_o5),
               .of_pc1(id_pc1),.of_pc2(id_pc2),.of_pc3(id_pc3),.of_pc4(id_pc4),.of_pc5(id_pc5),
               .id_alu_code(id_alu_code),
               .of_out_data1(of_out_data1),.of_out_data2(of_out_data2),.of_out_data3(of_out_data3),.of_out_data4(of_out_data4),.of_out_data5(of_out_data5)
               );

// alu_src1_sel alu_src1_sel1(.sel(src_sel1_r), .immediate(immediate_r), .acc(acc), .ram(ram_out), .ext(data_in), .des(src1));
alu_src1_sel VP_alu_src1_sel1 (.sel(src_sel1_o1), .immediate(immediate_out1), .acc(acc1), .ram(ram_out_data1), .ext(ext_input1), .des(src1_1));
alu_src1_sel VP_alu_src1_sel2 (.sel(src_sel1_o2), .immediate(immediate_out2), .acc(acc2), .ram(ram_out_data2), .ext(ext_input2), .des(src1_2));
alu_src1_sel VP_alu_src1_sel3 (.sel(src_sel1_o3), .immediate(immediate_out3), .acc(acc3), .ram(ram_out_data3), .ext(ext_input3), .des(src1_3));
alu_src1_sel VP_alu_src1_sel4 (.sel(src_sel1_o4), .immediate(immediate_out4), .acc(acc4), .ram(ram_out_data4), .ext(ext_input4), .des(src1_4));
alu_src1_sel VP_alu_src1_sel5 (.sel(src_sel1_o5), .immediate(immediate_out5), .acc(acc5), .ram(ram_out_data5), .ext(ext_input5), .des(src1_5));


//alu_src2_sel alu_src2_sel1(.sel(src_sel2_r), .op2(op2_nr), .acc(acc), .ram(ram_out), .des(src2));
alu_src2_sel VP_alu_src2_sel1(.sel(src_sel2_o1), .op2(op2_out_o1), .acc(acc1), .ram(ram_out_data1), .des(src2_1));
alu_src2_sel VP_alu_src2_sel2(.sel(src_sel2_o2), .op2(op2_out_o2), .acc(acc2), .ram(ram_out_data2), .des(src2_2));
alu_src2_sel VP_alu_src2_sel3(.sel(src_sel2_o3), .op2(op2_out_o3), .acc(acc3), .ram(ram_out_data3), .des(src2_3));
alu_src2_sel VP_alu_src2_sel4(.sel(src_sel2_o4), .op2(op2_out_o4), .acc(acc4), .ram(ram_out_data4), .des(src2_4));
alu_src2_sel VP_alu_src2_sel5(.sel(src_sel2_o5), .op2(op2_out_o5), .acc(acc5), .ram(ram_out_data5), .des(src2_5));

//alu_src3_sel alu_src3_sel1(.sel(src_sel3_r), .pc(pc_hi_r), .dptr(dptr_hi), .out(src3));
alu_src3_sel VP_alu_sel3_sel1(.sel(src_sel3_o1), .pc(of_pc1[15:8]), .dptr(dptr_hi1), .out(src3_1));
alu_src3_sel VP_alu_sel3_sel2(.sel(src_sel3_o2), .pc(of_pc2[15:8]), .dptr(dptr_hi2), .out(src3_2));
alu_src3_sel VP_alu_sel3_sel3(.sel(src_sel3_o3), .pc(of_pc3[15:8]), .dptr(dptr_hi3), .out(src3_3));
alu_src3_sel VP_alu_sel3_sel4(.sel(src_sel3_o4), .pc(of_pc4[15:8]), .dptr(dptr_hi4), .out(src3_4));
alu_src3_sel VP_alu_sel3_sel5(.sel(src_sel3_o5), .pc(of_pc5[15:8]), .dptr(dptr_hi5), .out(src3_5));

//cy_select cy_select1(.cy_sel(cy_sel_r), .cy_in(psw[7]), .data_in(bit_out), .data_out(alu_cy));
cy_select VP_cy_select1 (.cy_sel(cy_sel_o1), .cy_in(psw1[7]), .data_in(bit_out1), .data_out(alu_cy1));
cy_select VP_cy_select2 (.cy_sel(cy_sel_o2), .cy_in(psw2[7]), .data_in(bit_out2), .data_out(alu_cy2));
cy_select VP_cy_select3 (.cy_sel(cy_sel_o3), .cy_in(psw3[7]), .data_in(bit_out3), .data_out(alu_cy3));
cy_select VP_cy_select4 (.cy_sel(cy_sel_o4), .cy_in(psw4[7]), .data_in(bit_out4), .data_out(alu_cy4));
cy_select VP_cy_select5 (.cy_sel(cy_sel_o5), .cy_in(psw5[7]), .data_in(bit_out5), .data_out(alu_cy5));

// immediate_sel immediate_sel1(.sel(imm_sel), .op2(op2_dr), .op3(op3_n), .pch(pc_hi_r), .pcl(pc[7:0]), .out(immediate));
immediate_sel VP_immediate1(.sel(imm_sel_o1), .op2(op2_direct_o1), .op3(op3_out_o1), .pch(of_pc1[15:8]), .pcl(of_pc1[7:0]), .out(immediate_out1));
immediate_sel VP_immediate2(.sel(imm_sel_o2), .op2(op2_direct_o2), .op3(op3_out_o2), .pch(of_pc2[15:8]), .pcl(of_pc1[7:0]), .out(immediate_out2));
immediate_sel VP_immediate3(.sel(imm_sel_o3), .op2(op2_direct_o3), .op3(op3_out_o3), .pch(of_pc3[15:8]), .pcl(of_pc1[7:0]), .out(immediate_out3));
immediate_sel VP_immediate4(.sel(imm_sel_o4), .op2(op2_direct_o4), .op3(op3_out_o4), .pch(of_pc4[15:8]), .pcl(of_pc1[7:0]), .out(immediate_out4));
immediate_sel VP_immediate5(.sel(imm_sel_o5), .op2(op2_direct_o5), .op3(op3_out_o5), .pch(of_pc5[15:8]), .pcl(of_pc1[7:0]), .out(immediate_out5));

//ext_addr_sel ext_addr_sel1(.clk(clk), .select(ext_addr_sel), .write(write_p), .dptr_hi(dptr_hi), .dptr_lo(dptr_lo), .ri(ri), .addr_out(ext_addr));
ext_addr_sel VP_ext_addr_sel1(.clk(clk), .select(ext_addr_sel_o1), .write(write_x_o1), .dptr_hi(dptr_hi1), .dptr_lo(dptr_lo1), .ri(Indi_data_out1), .addr_out(ext_addr_out1));
ext_addr_sel VP_ext_addr_sel2(.clk(clk), .select(ext_addr_sel_o2), .write(write_x_o2), .dptr_hi(dptr_hi2), .dptr_lo(dptr_lo2), .ri(Indi_data_out2), .addr_out(ext_addr_out2));
ext_addr_sel VP_ext_addr_sel3(.clk(clk), .select(ext_addr_sel_o3), .write(write_x_o3), .dptr_hi(dptr_hi3), .dptr_lo(dptr_lo3), .ri(Indi_data_out3), .addr_out(ext_addr_out3));
ext_addr_sel VP_ext_addr_sel4(.clk(clk), .select(ext_addr_sel_o4), .write(write_x_o4), .dptr_hi(dptr_hi4), .dptr_lo(dptr_lo4), .ri(Indi_data_out4), .addr_out(ext_addr_out4));
ext_addr_sel VP_ext_addr_sel5(.clk(clk), .select(ext_addr_sel_o5), .write(write_x_o5), .dptr_hi(dptr_hi5), .dptr_lo(dptr_lo5), .ri(Indi_data_out5), .addr_out(ext_addr_out5));

//IndiAddr IndiAddr1 (.clk(clk), .rst(rst), .addr(wr_addr), .data_in(des1), .wr(wr_r), .wr_bit(wr_bit_addr_r), .data_out(ri), .sel(op1_n[0]), .bank(psw[4:3]));
IndiAddr VP_IndiAddr1(.clk(clk), .rst(rst), .addr(wr_addr_out1), .data_in(des1_reg1), .wr(wr_o1), .wr_bit(wr_bit_o1), .data_out(Indi_data_out1), .sel(op1_out_o1[0]), .bank(psw1[4:3]));
IndiAddr VP_IndiAddr2(.clk(clk), .rst(rst), .addr(wr_addr_out2), .data_in(des1_reg2), .wr(wr_o2), .wr_bit(wr_bit_o2), .data_out(Indi_data_out2), .sel(op1_out_o2[0]), .bank(psw2[4:3]));
IndiAddr VP_IndiAddr3(.clk(clk), .rst(rst), .addr(wr_addr_out3), .data_in(des1_reg3), .wr(wr_o3), .wr_bit(wr_bit_o3), .data_out(Indi_data_out3), .sel(op1_out_o3[0]), .bank(psw3[4:3]));
IndiAddr VP_IndiAddr4(.clk(clk), .rst(rst), .addr(wr_addr_out4), .data_in(des1_reg4), .wr(wr_o4), .wr_bit(wr_bit_o4), .data_out(Indi_data_out4), .sel(op1_out_o4[0]), .bank(psw4[4:3]));
IndiAddr VP_IndiAddr5(.clk(clk), .rst(rst), .addr(wr_addr_out5), .data_in(des1_reg5), .wr(wr_o5), .wr_bit(wr_bit_o5), .data_out(Indi_data_out5), .sel(op1_out_o5[0]), .bank(psw5[4:3]));

// ram red and ram write select
//ram_rd_sel ram_rd_sel1 (.sel(ram_rd_sel),  .sp(sp), .ri(ri), .rn({psw[4:3], op1_n[2:0]}), .imm(op2_dr), .out(rd_addr));
ram_rd_sel  VP_ram_rd_sel1(.sel(ram_rd_sel_o1), .sp(sp1), .ri(Indi_data_out1), .rn({psw1[4:3], op1_out_o1[2:0]}), .imm(op2_direct_o1), .out(rd_addr_out1));
ram_rd_sel  VP_ram_rd_sel2(.sel(ram_rd_sel_o2), .sp(sp2), .ri(Indi_data_out2), .rn({psw2[4:3], op1_out_o2[2:0]}), .imm(op2_direct_o2), .out(rd_addr_out2));
ram_rd_sel  VP_ram_rd_sel3(.sel(ram_rd_sel_o3), .sp(sp3), .ri(Indi_data_out3), .rn({psw3[4:3], op1_out_o3[2:0]}), .imm(op2_direct_o3), .out(rd_addr_out3));
ram_rd_sel  VP_ram_rd_sel4(.sel(ram_rd_sel_o4), .sp(sp4), .ri(Indi_data_out4), .rn({psw4[4:3], op1_out_o4[2:0]}), .imm(op2_direct_o4), .out(rd_addr_out4));
ram_rd_sel  VP_ram_rd_sel5(.sel(ram_rd_sel_o5), .sp(sp5), .ri(Indi_data_out5), .rn({psw5[4:3], op1_out_o5[2:0]}), .imm(op2_direct_o5), .out(rd_addr_out5));

//data ram
//ram ram1(.rst(rst), .clk(clk), .rd_addr(rd_addr), .rd_data(ram_data), .wr_addr(wr_addr), .wr_bit(wr_bit_addr_r), .wr_data(des1), .wr(wr_r), .bit_data_in(desCy), .bit_data_out(bit_data));
ram ram1(.rst(rst), .clk(clk), .rd_addr(rd_addr_out1), .rd_data(rd_data1), .wr_addr(wr_addr_out1), .wr_bit(wr_bit1), .wr_data(wr_data1), .wr(wr1), .bit_data_in(bit_data_in1),
             .bit_data_out(bit_data_out1));
ram ram2(.rst(rst), .clk(clk), .rd_addr(rd_addr_out2), .rd_data(rd_data2), .wr_addr(wr_addr_out2), .wr_bit(wr_bit2), .wr_data(wr_data2), .wr(wr2), .bit_data_in(bit_data_in2),
             .bit_data_out(bit_data_out2));
ram ram3(.rst(rst), .clk(clk), .rd_addr(rd_addr_out3), .rd_data(rd_data3), .wr_addr(wr_addr_out3), .wr_bit(wr_bit3), .wr_data(wr_data3), .wr(wr3), .bit_data_in(bit_data_in3),
             .bit_data_out(bit_data_out3));
ram ram4(.rst(rst), .clk(clk), .rd_addr(rd_addr_out4), .rd_data(rd_data4), .wr_addr(wr_addr_out4), .wr_bit(wr_bit4), .wr_data(wr_data4), .wr(wr4), .bit_data_in(bit_data_in4),
             .bit_data_out(bit_data_out4));
ram ram5(.rst(rst), .clk(clk), .rd_addr(rd_addr_out5), .rd_data(rd_data5), .wr_addr(wr_addr_out5), .wr_bit(wr_bit5), .wr_data(wr_data5), .wr(wr5), .bit_data_in(bit_data_in5),
             .bit_data_out(bit_data_out5));

//ram_sel ram_sel1(.addr(rd_addr), .bit_in(bit_data), .in_ram(ram_data), .psw(psw), .acc(acc), .dptr_hi(dptr_hi), .port0(p0_in), .port1(p1_in), .port2(p2_in), .port3(p3_in), 
                    // .bit_out(bit_out), .out_data(ram_out));
ram_sel VP_ram_sel1 (.addr(rd_addr_out1), .bit_in(bit_data_out1), .in_ram(rd_data1), .psw(psw1), .acc(acc1), .dptr_hi(dptr_hi1), .port0(port0), .port1(port1), .port2(port2), .port3(port3),
                    .bit_out(bit_out1), .out_data(ram_out_data1));                   
ram_sel VP_ram_sel2 (.addr(rd_addr_out2), .bit_in(bit_data_out2), .in_ram(rd_data2), .psw(psw2), .acc(acc2), .dptr_hi(dptr_hi2), .port0(port4), .port1(port5), .port2(port6), .port3(port7),
                    .bit_out(bit_out2), .out_data(ram_out_data2));                   
ram_sel VP_ram_sel3 (.addr(rd_addr_out3), .bit_in(bit_data_out3), .in_ram(rd_data3), .psw(psw3), .acc(acc3), .dptr_hi(dptr_hi3), .port0(port8), .port1(port9), .port2(port10), .port3(port11),
                    .bit_out(bit_out3), .out_data(ram_out_data3));                   
ram_sel VP_ram_sel4 (.addr(rd_addr_out4), .bit_in(bit_data_out4), .in_ram(rd_data4), .psw(psw4), .acc(acc4), .dptr_hi(dptr_hi4), .port0(port12), .port1(port13), .port2(port14), .port3(port15),
                    .bit_out(bit_out4), .out_data(ram_out_data4));                
ram_sel VP_ram_sel5 (.addr(rd_addr_out5), .bit_in(bit_data_out5), .in_ram(rd_data5), .psw(psw5), .acc(acc5), .dptr_hi(dptr_hi5), .port0(port16), .port1(port17), .port2(port18), .port3(port19),
                    .bit_out(bit_out5), .out_data(ram_out_data5));

reg_of_ex VP_reg_of_ex(              
            .clk(clk),.rst(rst),
            .op_code_i1(alu_op_o1),.op_code_i2(alu_op_o2),.op_code_i3(alu_op_o3),.op_code_i4(alu_op_o4),.op_code_i5(alu_op_o5),
	        .src1_i1(src1_1), .src1_i2(src1_2), .src1_i3(src1_3), .src1_i4(src1_4), .src1_i5(src1_5),
	        .src2_i1(src2_1), .src2_i2(src2_2), .src2_i3(src2_3), .src2_i4(src2_4), .src2_i5(src2_5),
            .src3_i1(src3_1), .src3_i2(src3_2), .src3_i3(src3_3), .src3_i4(src3_4), .src3_i5(src3_5),
	        .srcCy_i1(alu_cy1),.srcCy_i2(alu_cy2),.srcCy_i3(alu_cy3),.srcCy_i4(alu_cy4),.srcCy_i5(alu_cy5),
            .srcAc_i1(desAc1), .srcAc_i2(desAc2), .srcAc_i3(desAc3), .srcAc_i4(desAc4), .srcAc_i5(desAc5),
            .bit_in_i1(bit_out1),.bit_in_i2(bit_out2),.bit_in_i3(bit_out3),.bit_in_i4(bit_out4),.bit_in_i5(bit_out5),
	        .id_alu_code(id_alu_code), 
	        .ram_wr_sel_o1(ram_wr_sel_o1), .ram_wr_sel_o2(ram_wr_sel_o2), .ram_wr_sel_o3(ram_wr_sel_o3), .ram_wr_sel_o4(ram_wr_sel_o4), .ram_wr_sel_o5(ram_wr_sel_o5),
	         .op1_out_o1(op1_out_o1),.op1_out_o2(op1_out_o2),.op1_out_o3(op1_out_o3),.op1_out_o4(op1_out_o4),.op1_out_o5(op1_out_o5),
	         .op2_out_o1(op2_out_o1),.op2_out_o2(op2_out_o2),.op2_out_o3(op2_out_o3),.op2_out_o4(op2_out_o4),.op2_out_o5(op2_out_o5),
	         .op3_out_o1(op3_out_o1),.op3_out_o2(op3_out_o2),.op3_out_o3(op3_out_o3),.op3_out_o4(op3_out_o4),.op3_out_o5(op3_out_o5),
	         .op2_direct_o1(op2_direct_o1),.op2_direct_o2(op2_direct_o2),.op2_direct_o3(op2_direct_o3),.op2_direct_o4(op2_direct_o4),.op2_direct_o5(op2_direct_o5),
	         .Indi_data_out1(Indi_data_out1),.Indi_data_out2(Indi_data_out2),.Indi_data_out3(Indi_data_out3),.Indi_data_out4(Indi_data_out4),.Indi_data_out5(Indi_data_out5),
	          .of_out_data1(of_out_data1),.of_out_data2(of_out_data2),.of_out_data3(of_out_data3),.of_out_data4(of_out_data4),.of_out_data5(of_out_data5),
	          .psw_set_o1(psw_set_o1),.psw_set_o2(psw_set_o2),.psw_set_o3(psw_set_o3),.psw_set_o4(psw_set_o1),.psw_set_o5(psw_set_o1),
	          .wr_bit_o1(wr_bit_o1),.wr_bit_o2(wr_bit_o2),.wr_bit_o3(wr_bit_o3),.wr_bit_o4(wr_bit_o4),.wr_bit_o5(wr_bit_o5),
	          .wr_i1(wr1),.wr_i2(wr2),.wr_i3(wr3),.wr_i4(wr4),.wr_i5(wr5),
	          .wad2_o1(wad2_o1),  .wad2_o2(wad2_o2),  .wad2_o3(wad2_o3),  .wad2_o4(wad2_o4),  .wad2_o5(wad2_o5),
	         
	         
	        .op_code_o1(op_code_o1),.op_code_o2(op_code_o2),.op_code_o3(op_code_o3),.op_code_o4(op_code_o4),.op_code_o5(op_code_o5),
	        .src1_o1(src1_o1),.src1_o2(src1_o2),.src1_o3(src1_o3),.src1_o4(src1_o4),.src1_o5(src1_o5),
	        .src2_o1(src2_o1), .src2_o2(src2_o2), .src2_o3(src2_o3), .src2_o4(src2_o4), .src2_o5(src2_o5),
	        .src3_o1(src3_o1), .src3_o2(src3_o2), .src3_o3(src3_o3), .src3_o4(src3_o4), .src3_o5(src3_o5),
	        .srcCy_o1(srcCy_o1),.srcCy_o2(srcCy_o2),.srcCy_o3(srcCy_o3),.srcCy_o4(srcCy_o4),.srcCy_o5(srcCy_o5),
	        .srcAc_o1(srcAc_o1),  .srcAc_o2(srcAc_o2), .srcAc_o3(srcAc_o3), .srcAc_o4(srcAc_o4), .srcAc_o5(srcAc_o5),
	        .bit_in_o1(bit_in_o1),.bit_in_o2(bit_in_o2),.bit_in_o3(bit_in_o3),.bit_in_o4(bit_in_o4),.bit_in_o5(bit_in_o5),
	        .ex_alu_code(ex_alu_code),
	        .ex_ram_wr_sel(ex_ram_wr_sel1),.ex_ram_wr_sel(ex_ram_wr_sel2),.ex_ram_wr_sel(ex_ram_wr_sel3),.ex_ram_wr_sel(ex_ram_wr_sel4),.ex_ram_wr_sel(ex_ram_wr_sel5),
	         .op1_out_o1_ex(op1_out_o1_ex),.op1_out_o2_ex(op1_out_o2_ex),.op1_out_o3_ex(op1_out_o3_ex),.op1_out_o4_ex(op1_out_o4_ex),.op1_out_o5_ex(op1_out_o5_ex),
	         .op2_out_o1_ex(op2_out_o1_ex),.op2_out_o2_ex(op2_out_o2_ex),.op2_out_o3_ex(op2_out_o3_ex),.op2_out_o4_ex(op2_out_o4_ex),.op2_out_o5_ex(op2_out_o5_ex),
	         .op3_out_o1_ex(op3_out_o1_ex),.op3_out_o2_ex(op3_out_o2_ex),.op3_out_o3_ex(op3_out_o3_ex),.op3_out_o4_ex(op3_out_o4_ex),.op3_out_o5_ex(op3_out_o5_ex),
	         .op2_direct_o1_ex(op2_direct_o1_ex),.op2_direct_o2_ex(op2_direct_o2_ex),.op2_direct_o3_ex(op2_direct_o3_ex),.op2_direct_o4_ex(op2_direct_o4_ex),.op2_direct_o5_ex(op2_direct_o5_ex),
	         .Indi_data_out1_ex(Indi_data_out1_ex),.Indi_data_out2_ex(Indi_data_out2_ex),.Indi_data_out3_ex(Indi_data_out3_ex),.Indi_data_out4_ex(Indi_data_out4_ex),.Indi_data_out5_ex(Indi_data_out5_ex),
             .ex_out_data1(ex_out_data1),.ex_out_data2(ex_out_data2),.ex_out_data3(ex_out_data3),.ex_out_data4(ex_out_data4),.ex_out_data5(ex_out_data5),
              .psw_set_o1_ex(psw_set_o1_ex),.psw_set_o2_ex(psw_set_o2_ex),.psw_set_o3_ex(psw_set_o3_ex),.psw_set_o4_ex(psw_set_o1_ex),.psw_set_o5_ex(psw_set_o1_ex),
	          .wr_bit_o1_ex(wr_bit_o1_ex),.wr_bit_o2_ex(wr_bit_o2_ex),.wr_bit_o3_ex(wr_bit_o3_ex),.wr_bit_o4_ex(wr_bit_o4_ex),.wr_bit_o5_ex(wr_bit_o5_ex),
	          .wr_i1_ex(wr1_ex),.wr_i2_ex(wr2_ex),.wr_i3_ex(wr3_ex),.wr_i4_ex(wr4_ex),.wr_i5_ex(wr5_ex),
	          .wad2_o1_ex(wad2_o1_ex),  .wad2_o2_ex(wad2_o2_ex),  .wad2_o3_ex(wad2_o3_ex),  .wad2_o4_ex(wad2_o4_ex),  .wad2_o5_ex(wad2_o5_ex)
    );

//mux 1 and 2
mux_to_alu1 VP_mux_to_alu1(
            .op_code_o1(op_code_o1),.op_code_o2(op_code_o2),.op_code_o3(op_code_o3),.op_code_o4(op_code_o4),.op_code_o5(op_code_o5),
	        .src1_o1(src1_o1),.src1_o2(src1_o2),.src1_o3(src1_o3),.src1_o4(src1_o4),.src1_o5(src1_o5),
	        .src2_o1(src2_o1), .src2_o2(src2_o2), .src2_o3(src2_o3), .src2_o4(src2_o4), .src2_o5(src2_o5),
	        .src3_o1(src3_o1), .src3_o2(src3_o2), .src3_o3(src3_o3), .src3_o4(src3_o4), .src3_o5(src3_o5),
	        .srcCy_o1(srcCy_o1),.srcCy_o2(srcCy_o2),.srcCy_o3(srcCy_o3),.srcCy_o4(srcCy_o4),.srcCy_o5(srcCy_o5),
	        .srcAc_o1(srcAc_o1),  .srcAc_o2(srcAc_o2), .srcAc_o3(srcAc_o3), .srcAc_o4(srcAc_o4), .srcAc_o5(srcAc_o5),
	        .bit_in_o1(bit_in_o1),.bit_in_o2(bit_in_o2),.bit_in_o3(bit_in_o3),.bit_in_o4(bit_in_o4),.bit_in_o5(bit_in_o5),
	        .src_code(ex_code),
	
	        .op_code1(ex_op_code1),
	        .src1_1(ex_src1_1), .src2_1(ex_src2_1), .src3_1(ex_src3_1),  
	        .srcCy1(ex_srcCy1), .srcAc1(ex_srcAc1),.bit_in1(ex_bit_in1) );

mux_to_alu2 VP_mux_to_alu2(
         .src_code(ex_code),.alu_code(ex_alu_code),	
	     .op_code1(ex_op_code1), .src1_1(ex_src1_1), .src2_1(ex_src2_1), .src3_1(ex_src3_1),.srcCy1(ex_srcCy1), .srcAc1(ex_srcAc1),.bit_in1(ex_bit_in1),
	
	      .op_code(ex_alu_op_code), .op_code2(ex_alu_op_code2),.op_code3(ex_alu_op_code3),.op_code4(ex_alu_op_code4),.op_code5(ex_alu_op_code5),.op_code6(ex_alu_op_code6),.op_code7(ex_alu_op_code7),
	      .src1(ex_alu_src1), .src2(ex_alu_src2), .src3(ex_alu_src3),
	      .src1_2(ex_alu_src1_2), .src2_2(ex_alu_src2_2), .src3_2(ex_alu_src3_2),
	      .src1_3(ex_alu_src1_3), .src2_3(ex_alu_src2_3), .src3_3(ex_alu_src3_3),
	      .src1_4(ex_alu_src1_4), .src2_4(ex_alu_src2_4), .src3_4(ex_alu_src3_4),
	      .src1_5(ex_alu_src1_5), .src2_5(ex_alu_src2_5), .src3_5(ex_alu_src3_5),
	      .src1_6(ex_alu_src1_6), .src2_6(ex_alu_src2_6), .src3_6(ex_alu_src3_6),
	      .src1_7(ex_alu_src1_7), .src2_7(ex_alu_src2_7), .src3_7(ex_alu_src3_7), 
	      .srcCy(ex_alu_srcCy), .srcAc(ex_alu_srcAc),.bit_in(ex_alu_bit_in),
	      .srcCy2(ex_alu_srcCy2), .srcAc2(ex_alu_srcAc2),.bit_in2(ex_alu_bit_in1),
	      .srcCy3(ex_alu_srcCy3), .srcAc3(ex_alu_srcAc3),.bit_in3(ex_alu_bit_in3),
	      .srcCy4(ex_alu_srcCy4),  .srcAc4(ex_alu_srcAc3),.bit_in4(ex_alu_bit_in4),
	      .srcCy5(ex_alu_srcCy5), .srcAc5(ex_alu_srcAc3),.bit_in5(ex_alu_bit_in5),
	      .srcCy6(ex_alu_srcCy6), .srcAc6(ex_alu_srcAc6),.bit_in6(ex_alu_bit_in6),
	      .srcCy7(ex_alu_srcCy7), .srcAc7(ex_alu_srcAc7),.bit_in7(ex_alu_bit_in7)
	     );	                
	                                
//alu  alu alu1(.op_code(alu_op_r), .src1(src1), .src2(src2), .src3(src3), .srcCy(alu_cy), .srcAc(psw[6]), .des1(des1), .des2(des2), .desCy(desCy), .desAc(desAc), .desOv(desOv), .bit_in(bit_out));
alu VP_alu1 (.op_code(ex_alu_op_code), .src1(ex_alu_src1), .src2(ex_alu_src2), .src3(ex_alu_src3), .srcCy(ex_alu_srcCy), .srcAc(ex_alu_srcAc), .des1(alu_des1_1), .des2(alu_des2_1), .desCy(alu_desCy),
             .desAc(alu_desAc), .desOv(alu_desOv), .bit_in(ex_alu_bit_in));
alu VP_alu2_1 (.op_code(ex_alu_op_code2), .src1(ex_alu_src1_2), .src2(ex_alu_src2_2), .src3(ex_alu_src3_2), .srcCy(ex_alu_srcCy2), .srcAc(ex_alu_srcAc2), .des1(alu_des1_2), .des2(alu_des2_2), 
              .desCy(alu_desCy2), .desAc(alu_desAc2), .desOv(alu_desOv2), .bit_in(ex_alu_bit_in2));
alu VP_alu2_2 (.op_code(ex_alu_op_code3), .src1(ex_alu_src1_3), .src2(ex_alu_src2_3), .src3(ex_alu_src3_3), .srcCy(ex_alu_srcCy3), .srcAc(ex_alu_srcAc3), .des1(alu_des1_3), .des2(alu_des2_3),
             .desCy(alu_desCy3), .desAc(alu_desAc3), .desOv(alu_desOv3), .bit_in(ex_alu_bit_in3));
alu VP_alu4_1 (.op_code(ex_alu_op_code4), .src1(ex_alu_src1_4), .src2(ex_alu_src2_4), .src3(ex_alu_src3_4), .srcCy(ex_alu_srcCy4), .srcAc(ex_alu_srcAc4), .des1(alu_des1_4), .des2(alu_des2_4),
             .desCy(alu_desCy4), .desAc(alu_desAc4), .desOv(alu_desOv4), .bit_in(ex_alu_bit_in4));
alu VP_alu4_2 (.op_code(ex_alu_op_code5), .src1(ex_alu_src1_5), .src2(ex_alu_src2_5), .src3(ex_alu_src3_5), .srcCy(ex_alu_srcCy5), .srcAc(ex_alu_srcAc5), .des1(alu_des1_5), .des2(alu_des2_5),
             .desCy(alu_desCy5), .desAc(alu_desAc5), .desOv(alu_desOv5), .bit_in(ex_alu_bit_in5));
alu VP_alu4_3 (.op_code(ex_alu_op_code6), .src1(ex_alu_src1_6), .src2(ex_alu_src2_6), .src3(ex_alu_src3_6), .srcCy(ex_alu_srcCy6), .srcAc(ex_alu_srcAc6), .des1(alu_des1_6), .des2(alu_des2_6),
             .desCy(alu_desCy6), .desAc(alu_desAc6), .desOv(alu_desOv6), .bit_in(ex_alu_bit_in6));
alu VP_alu4_4 (.op_code(ex_alu_op_code7), .src1(ex_alu_src1_7), .src2(ex_alu_src2_7), .src3(ex_alu_src3_7), .srcCy(ex_alu_srcCy7), .srcAc(ex_alu_srcAc7), .des1(alu_des1_7), .des2(alu_des2_7),
             .desCy(alu_desCy7), .desAc(alu_desAc7), .desOv(alu_desOv7), .bit_in(ex_alu_bit_in7));

reg_ex_wb VP_reg_ex_wb(
                                .clk(clk),.rst(rst),
           .des1_1(alu_des1_1),.des2_1(alu_des2_1),.des1_2(alu_des1_2),.des2_2(alu_des2_2),.des1_3(alu_des1_3),.des2_3(alu_des2_3),.des1_4(alu_des1_4),.des2_4(alu_des2_4),
           .des1_5(alu_des1_5),.des2_5(alu_des2_5),.des1_6(alu_des1_6),.des2_6(alu_des2_6),.des1_7(alu_des1_7),.des2_7(alu_des2_7),
           .desCy(alu_desCy),.desAc(alu_desAc),.desOv(alu_desOv),.desCy2(alu_desCy2),.desAc2(alu_desAc2),.desOv2(alu_desOv2),.desCy3(alu_desCy3),.desAc3(alu_desAc3),.desOv3(alu_desOv3),
           .desCy4(alu_desCy4),.desAc4(alu_desAc4),.desOv4(alu_desOv4),
           .desCy5(alu_desCy5),.desAc5(alu_desAc5),.desOv5(alu_desOv5),.desCy6(alu_desCy6),.desAc6(alu_desAc6),.desOv6(alu_desOv6),.desCy7(alu_desCy7),.desAc7(alu_desAc7),.desOv7(alu_desOv7) ,
           .ex_alu_code(ex_alu_code),
           .ex_ram_wr_sel(ex_ram_wr_sel1),.ex_ram_wr_sel(ex_ram_wr_sel2),.ex_ram_wr_sel(ex_ram_wr_sel3),.ex_ram_wr_sel(ex_ram_wr_sel4),.ex_ram_wr_sel(ex_ram_wr_sel5),
           .op1_out_o1_ex(op1_out_o1_ex),.op1_out_o2_ex(op1_out_o2_ex),.op1_out_o3_ex(op1_out_o3_ex),.op1_out_o4_ex(op1_out_o4_ex),.op1_out_o5_ex(op1_out_o5_ex),
	       .op2_out_o1_ex(op2_out_o1_ex),.op2_out_o2_ex(op2_out_o2_ex),.op2_out_o3_ex(op2_out_o3_ex),.op2_out_o4_ex(op2_out_o4_ex),.op2_out_o5_ex(op2_out_o5_ex),
	       .op3_out_o1_ex(op3_out_o1_ex),.op3_out_o2_ex(op3_out_o2_ex),.op3_out_o3_ex(op3_out_o3_ex),.op3_out_o4_ex(op3_out_o4_ex),.op3_out_o5_ex(op3_out_o5_ex),
	       .op2_direct_o1_ex(op2_direct_o1_ex),.op2_direct_o2_ex(op2_direct_o2_ex),.op2_direct_o3_ex(op2_direct_o3_ex),.op2_direct_o4_ex(op2_direct_o4_ex),.op2_direct_o5_ex(op2_direct_o5_ex),
	       .Indi_data_out1_ex(Indi_data_out1_ex),.Indi_data_out2_ex(Indi_data_out2_ex),.Indi_data_out3_ex(Indi_data_out3_ex),.Indi_data_out4_ex(Indi_data_out4_ex),.Indi_data_out5_ex(Indi_data_out5_ex),
	        .ex_out_data1(ex_out_data1),.ex_out_data2(ex_out_data2),.ex_out_data3(ex_out_data3),.ex_out_data4(ex_out_data4),.ex_out_data5(ex_out_data5),
           	 .psw_set_o1_ex(psw_set_o1_ex),.psw_set_o2_ex(psw_set_o2_ex),.psw_set_o3_ex(psw_set_o3_ex),.psw_set_o4_ex(psw_set_o1_ex),.psw_set_o5_ex(psw_set_o1_ex),
	          .wr_bit_o1_ex(wr_bit_o1_ex),.wr_bit_o2_ex(wr_bit_o2_ex),.wr_bit_o3_ex(wr_bit_o3_ex),.wr_bit_o4_ex(wr_bit_o4_ex),.wr_bit_o5_ex(wr_bit_o5_ex),
	          .wr_i1_ex(wr1_ex),.wr_i2_ex(wr2_ex),.wr_i3_ex(wr3_ex),.wr_i4_ex(wr4_ex),.wr_i5_ex(wr5_ex),
	          .wad2_o1_ex(wad2_o1_ex),  .wad2_o2_ex(wad2_o2_ex),  .wad2_o3_ex(wad2_o3_ex),  .wad2_o4_ex(wad2_o4_ex),  .wad2_o5_ex(wad2_o5_ex),
           	
           .des1_1_o(wb_alu_des1_1),.des2_1_o(wb_alu_des2_1),.des1_2_o(wb_alu_des1_2),.des2_2_o(wb_alu_des2_2),.des1_3_o(wb_alu_des1_3),.des2_3_o(wb_alu_des2_3),
           .des1_4_o(wb_alu_des1_4),.des2_4_o(wb_alu_des2_4),.des1_5_o(wb_alu_des1_5),.des2_5_o(wb_alu_des2_5),.des1_6_o(wb_alu_des1_6),.des2_6_o(wb_alu_des2_6),.des1_7_o(wb_alu_des1_7),.des2_7_o(wb_alu_des2_7),
           .desCy_o(wb_alu_desCy),.desAc_o(wb_alu_desAc),.desOv_o(wb_alu_desOv),
           .desCy2_o(wb_alu_desCy2),.desAc2_o(wb_alu_desAc2),.desOv2_o(wb_alu_desOv2),
           .desCy3_o(wb_alu_desCy3),.desAc3_o(wb_alu_desAc3),.desOv3_o(wb_alu_desOv3),
           .desCy4_o(wb_alu_desCy4),.desAc4_o(wb_alu_desAc4),.desOv4_o(wb_alu_desOv4),
           .desCy5_o(wb_alu_desCy5),.desAc5_o(wb_alu_desAc5),.desOv5_o(wb_alu_desOv5),
           .desCy6_o(wb_alu_desCy6),.desAc6_o(wb_alu_desAc6),.desOv6_o(wb_alu_desOv6),
           .desCy7_o(wb_alu_desCy7),.desAc7_o(wb_alu_desAc7),.desOv7_o(wb_alu_desOv7),
           .wb_alu_code(wb_alu_code),
           .wb_ram_wr_sel(wb_ram_wr_sel_o1), .wb_ram_wr_sel(wb_ram_wr_sel_o2), .wb_ram_wr_sel(wb_ram_wr_sel_o3), .wb_ram_wr_sel(wb_ram_wr_sel_o4), .wb_ram_wr_sel(wb_ram_wr_sel_o5),
           .op1_out_o1_wb(op1_out_o1_wb),.op1_out_o2_wb(op1_out_o2_wb),.op1_out_o3_wb(op1_out_o3_wb),.op1_out_o4_wb(op1_out_o4_wb),.op1_out_o5_wb(op1_out_o5_wb),
	       .op2_out_o1_wb(op2_out_o1_wb),.op2_out_o2_wb(op2_out_o2_wb),.op2_out_o3_wb(op2_out_o3_wb),.op2_out_o4_wb(op2_out_o4_wb),.op2_out_o5_wb(op2_out_o5_wb),
	       .op3_out_o1_wb(op3_out_o1_wb),.op3_out_o2_wb(op3_out_o2_wb),.op3_out_o3_wb(op3_out_o3_wb),.op3_out_o4_wb(op3_out_o4_wb),.op3_out_o5_wb(op3_out_o5_wb),
	       .op2_direct_o1_wb(op2_direct_o1_wb),.op2_direct_o2_wb(op2_direct_o2_wb),.op2_direct_o3_wb(op2_direct_o3_wb),.op2_direct_o4_wb(op2_direct_o4_wb),.op2_direct_o5_wb(op2_direct_o5_wb),
	       .Indi_data_out1_wb(Indi_data_out1_wb),.Indi_data_out2_wb(Indi_data_out2_wb),.Indi_data_out3_wb(Indi_data_out3_wb),.Indi_data_out4_ex(Indi_data_out4_wb),.Indi_data_out5_ex(Indi_data_out5_wb),
            .wb_out_data1(wb_out_data1),.wb_out_data2(wb_out_data2),.wb_out_data3(wb_out_data3),.wb_out_data4(wb_out_data4),.wb_out_data5(wb_out_data5),
            .psw_set_o1_wb(psw_set_o1_wb),.psw_set_o2_wb(psw_set_o2_wb),.psw_set_o3_wb(psw_set_o3_wb),.psw_set_o4_wb(psw_set_o4_wb),.psw_set_o5_wb(psw_set_o5_wb),
	        .wr_bit_o1_wb(wr_bit_o1_wb),.wr_bit_o2_wb(wr_bit_o2_wb),.wr_bit_o3_wb(wr_bit_o3_wb),.wr_bit_o4_wb(wr_bit_o4_wb),.wr_bit_o5_wb(wr_bit_o5_wb),
	        .wr_i1_wb(wr1_wb),.wr_i2_ex(wr2_wb),.wr_i3_ex(wr3_wb),.wr_i4_ex(wr4_wb),.wr_i5_ex(wr5_wb),
            .wad2_o1_wb(wad2_o1_wb),  .wad2_o2_wb(wad2_o2_wb),  .wad2_o3_wb(wad2_o3_wb),  .wad2_o4_ex(wad2_o4_wb),  .wad2_o5_ex(wad2_o5_wb)
    );

//sfr
sfr VP_sfr1(
       .rst(rst), .clk(clk),
       .desCy(desCy_r1), .des1(des1_r1), .des2_s(wb_out_data1), .wr_r(wr1_wb), .wr_bit_r(wr_bit_o1_wb), .wad2_r(wad2_o1_wb), .wr_addr(wr_addr_out1), .acc(acc1), .p(p1),
        .b_reg(b_reg1),
        .ram_rd_sel(ram_rd_sel_o1),.sp(sp1), .ram_wr_sel(ram_wr_sel1),
        .ram_wr_sel_r(ram_wr_sel_r1), .dptr_hi(dptr_hi1), .dptr_lo(dptr_lo1),
        .psw(psw1), .desAc(desAc_r1), .desOv(desOv_r1), .psw_set_r(psw_set_o1_wb), 
        .p0_out(p0_out1),.p1_out(p1_out1), .p2_out(p2_out1),.p3_out(p3_out1)
        );

sfr VP_sfr2(
       .rst(rst), .clk(clk),
       .desCy(desCy_r2), .des1(des1_r2), .des2_s(wb_out_data2), .wr_r(wr2_wb), .wr_bit_r(wr_bit_o2_wb), .wad2_r(wad2_o2_wb), .wr_addr(wr_addr_out2), .acc(acc2), .p(p2),
        .b_reg(b_reg2),
        .ram_rd_sel(ram_rd_sel_o2),.sp(sp2), .ram_wr_sel(ram_wr_sel2),
        .ram_wr_sel_r(ram_wr_sel_r2), .dptr_hi(dptr_hi2), .dptr_lo(dptr_lo2),
        .psw(psw2), .desAc(desAc_r2), .desOv(desOv_r2), .psw_set_r(psw_set_o2_wb), 
        .p0_out(p0_out2),.p1_out(p1_out2), .p2_out(p2_out2),.p3_out(p3_out2)
        );
sfr VP_sfr3(
       .rst(rst), .clk(clk),
       .desCy(desCy_r3), .des1(des1_r3), .des2_s(wb_out_data3), .wr_r(wr3_wb), .wr_bit_r(wr_bit_o3_wb), .wad2_r(wad2_o3_wb), .wr_addr(wr_addr_out3), .acc(acc3), .p(p3),
        .b_reg(b_reg3),
        .ram_rd_sel(ram_rd_sel_o3),.sp(sp3), .ram_wr_sel(ram_wr_sel3),
        .ram_wr_sel_r(ram_wr_sel_r3), .dptr_hi(dptr_hi3), .dptr_lo(dptr_lo3),
        .psw(psw3), .desAc(desAc_r3), .desOv(desOv_r3), .psw_set_r(psw_set_o3_wb), 
        .p0_out(p0_out3),.p1_out(p1_out3), .p2_out(p2_out3),.p3_out(p3_out3)
        );
sfr VP_sfr4(
       .rst(rst), .clk(clk),
       .desCy(desCy_r4), .des1(des1_r4), .des2_s(wb_out_data4), .wr_r(wr4_wb), .wr_bit_r(wr_bit_o4_wb), .wad2_r(wad2_o4_wb), .wr_addr(wr_addr_out4), .acc(acc4), .p(p4),
        .b_reg(b_reg4),
        .ram_rd_sel(ram_rd_sel_o4),.sp(sp4), .ram_wr_sel(ram_wr_sel4),
        .ram_wr_sel_r(ram_wr_sel_r4), .dptr_hi(dptr_hi4), .dptr_lo(dptr_lo4),
        .psw(psw4), .desAc(desAc_r4), .desOv(desOv_r4), .psw_set_r(psw_set_o4_wb), 
        .p0_out(p0_out4),.p1_out(p1_out4), .p2_out(p2_out4),.p3_out(p3_out4)
        );
sfr VP_sfr5(
       .rst(rst), .clk(clk),
       .desCy(desCy_r5), .des1(des1_r5), .des2_s(wb_out_data5), .wr_r(wr5_wb), .wr_bit_r(wr_bit_o5_wb), .wad2_r(wad2_o5_wb), .wr_addr(wr_addr_out5), .acc(acc5), .p(p5),
        .b_reg(b_reg5),
        .ram_rd_sel(ram_rd_sel_o5),.sp(sp5), .ram_wr_sel(ram_wr_sel5),
        .ram_wr_sel_r(ram_wr_sel_r5), .dptr_hi(dptr_hi5), .dptr_lo(dptr_lo5),
        .psw(psw5), .desAc(desAc_r5), .desOv(desOv_r5), .psw_set_r(psw_set_o5_wb), 
        .p0_out(p0_out5),.p1_out(p1_out5), .p2_out(p2_out5),.p3_out(p3_out5)
        );

//mux
rd_to_alu_code_wb VP_rd_to_alu_code_wb(.alu_code_wb(wb_alu_code),.rd1(rd1),.rd2(rd2),.rd3(rd3),.rd4(rd4),.rd5(rd5),
                                        .alu_code_wb1(wb_alu_code1),.alu_code_wb2(wb_alu_code2),.alu_code_wb3(wb_alu_code3),.alu_code_wb4(wb_alu_code4),.alu_code_wb5(wb_alu_code5));

mux_wb VP_mux_wb1(
           .des1_1_o(wb_alu_des1_1),.des2_1_o(wb_alu_des2_1),.des1_2_o(wb_alu_des1_2),.des2_2_o(wb_alu_des2_2),.des1_3_o(wb_alu_des1_3),.des2_3_o(wb_alu_des2_3),
           .des1_4_o(wb_alu_des1_4),.des2_4_o(wb_alu_des2_4),.des1_5_o(wb_alu_des1_5),.des2_5_o(wb_alu_des2_5),.des1_6_o(wb_alu_des1_6),.des2_6_o(wb_alu_des2_6),
           .des1_7_o(wb_alu_des1_7),.des2_7_o(wb_alu_des2_7),
           .desCy_o(wb_alu_desCy),.desAc_o(wb_alu_desAc),.desOv_o(wb_alu_desOv),
           .desCy2_o(wb_alu_desCy2),.desAc2_o(wb_alu_desAc2),.desOv2_o(wb_alu_desOv2),
           .desCy3_o(wb_alu_desCy3),.desAc3_o(wb_alu_desAc3),.desOv3_o(wb_alu_desOv3),
           .desCy4_o(wb_alu_desCy4),.desAc4_o(wb_alu_desAc4),.desOv4_o(wb_alu_desOv4),
           .desCy5_o(wb_alu_desCy5),.desAc5_o(wb_alu_desAc5),.desOv5_o(wb_alu_desOv5),
           .desCy6_o(wb_alu_desCy6),.desAc6_o(wb_alu_desAc6),.desOv6_o(wb_alu_desOv6),
           .desCy7_o(wb_alu_desCy7),.desAc7_o(wb_alu_desAc7),.desOv7_o(wb_alu_desOv7),
                
                 .alu_code_wb(wb_alu_code1),
                 .des1_r(des1_r1),.des2_r(des2_r1),
                 .desCy_r1(desCy_r1),.desAc_r(desAc_r1),.desOv_r(desOv_r1)
 );

mux_wb VP_mux_wb2(
            .des1_1_o(wb_alu_des1_1),.des2_1_o(wb_alu_des2_1),.des1_2_o(wb_alu_des1_2),.des2_2_o(wb_alu_des2_2),.des1_3_o(wb_alu_des1_3),.des2_3_o(wb_alu_des2_3),
           .des1_4_o(wb_alu_des1_4),.des2_4_o(wb_alu_des2_4),.des1_5_o(wb_alu_des1_5),.des2_5_o(wb_alu_des2_5),.des1_6_o(wb_alu_des1_6),.des2_6_o(wb_alu_des2_6),.des1_7_o(wb_alu_des1_7),.des2_7_o(wb_alu_des2_7),
           .desCy_o(wb_alu_desCy),.desAc_o(wb_alu_desAc),.desOv_o(wb_alu_desOv),
           .desCy2_o(wb_alu_desCy2),.desAc2_o(wb_alu_desAc2),.desOv2_o(wb_alu_desOv2),
           .desCy3_o(wb_alu_desCy3),.desAc3_o(wb_alu_desAc3),.desOv3_o(wb_alu_desOv3),
           .desCy4_o(wb_alu_desCy4),.desAc4_o(wb_alu_desAc4),.desOv4_o(wb_alu_desOv4),
           .desCy5_o(wb_alu_desCy5),.desAc5_o(wb_alu_desAc5),.desOv5_o(wb_alu_desOv5),
           .desCy6_o(wb_alu_desCy6),.desAc6_o(wb_alu_desAc6),.desOv6_o(wb_alu_desOv6),
           .desCy7_o(wb_alu_desCy7),.desAc7_o(wb_alu_desAc7),.desOv7_o(wb_alu_desOv7),
           .alu_code_wb(wb_alu_code2),
           .des1_r(des1_r2),.des2_r(des2_r2),
           .desCy_r1(desCy_r2),.desAc_r(desAc_r2),.desOv_r(desOv_r2)
 );
 
 mux_wb VP_mux_wb3(
               .des1_1_o(wb_alu_des1_1),.des2_1_o(wb_alu_des2_1),.des1_2_o(wb_alu_des1_2),.des2_2_o(wb_alu_des2_2),.des1_3_o(wb_alu_des1_3),.des2_3_o(wb_alu_des2_3),
           .des1_4_o(wb_alu_des1_4),.des2_4_o(wb_alu_des2_4),.des1_5_o(wb_alu_des1_5),.des2_5_o(wb_alu_des2_5),.des1_6_o(wb_alu_des1_6),.des2_6_o(wb_alu_des2_6),.des1_7_o(wb_alu_des1_7),.des2_7_o(wb_alu_des2_7),
           .desCy_o(wb_alu_desCy),.desAc_o(wb_alu_desAc),.desOv_o(wb_alu_desOv),
           .desCy2_o(wb_alu_desCy2),.desAc2_o(wb_alu_desAc2),.desOv2_o(wb_alu_desOv2),
           .desCy3_o(wb_alu_desCy3),.desAc3_o(wb_alu_desAc3),.desOv3_o(wb_alu_desOv3),
           .desCy4_o(wb_alu_desCy4),.desAc4_o(wb_alu_desAc4),.desOv4_o(wb_alu_desOv4),
           .desCy5_o(wb_alu_desCy5),.desAc5_o(wb_alu_desAc5),.desOv5_o(wb_alu_desOv5),
           .desCy6_o(wb_alu_desCy6),.desAc6_o(wb_alu_desAc6),.desOv6_o(wb_alu_desOv6),
           .desCy7_o(wb_alu_desCy7),.desAc7_o(wb_alu_desAc7),.desOv7_o(wb_alu_desOv7),
           .alu_code_wb(wb_alu_code3),
           .des1_r(des1_r3),.des2_r(des2_r3),
           .desCy_r1(desCy_r3),.desAc_r(desAc_r3),.desOv_r(desOv_r3)
 );
 
 mux_wb VP_mux_wb4(
            .des1_1_o(wb_alu_des1_1),.des2_1_o(wb_alu_des2_1),.des1_2_o(wb_alu_des1_2),.des2_2_o(wb_alu_des2_2),.des1_3_o(wb_alu_des1_3),.des2_3_o(wb_alu_des2_3),
           .des1_4_o(wb_alu_des1_4),.des2_4_o(wb_alu_des2_4),.des1_5_o(wb_alu_des1_5),.des2_5_o(wb_alu_des2_5),.des1_6_o(wb_alu_des1_6),.des2_6_o(wb_alu_des2_6),.des1_7_o(wb_alu_des1_7),.des2_7_o(wb_alu_des2_7),
           .desCy_o(wb_alu_desCy),.desAc_o(wb_alu_desAc),.desOv_o(wb_alu_desOv),
           .desCy2_o(wb_alu_desCy2),.desAc2_o(wb_alu_desAc2),.desOv2_o(wb_alu_desOv2),
           .desCy3_o(wb_alu_desCy3),.desAc3_o(wb_alu_desAc3),.desOv3_o(wb_alu_desOv3),
           .desCy4_o(wb_alu_desCy4),.desAc4_o(wb_alu_desAc4),.desOv4_o(wb_alu_desOv4),
           .desCy5_o(wb_alu_desCy5),.desAc5_o(wb_alu_desAc5),.desOv5_o(wb_alu_desOv5),
           .desCy6_o(wb_alu_desCy6),.desAc6_o(wb_alu_desAc6),.desOv6_o(wb_alu_desOv6),
           .desCy7_o(wb_alu_desCy7),.desAc7_o(wb_alu_desAc7),.desOv7_o(wb_alu_desOv7),
           .alu_code_wb(wb_alu_code4),
           .des1_r(des1_r4),.des2_r(des2_r4),
           .desCy_r1(desCy_r4),.desAc_r(desAc_r4),.desOv_r(desOv_r4)
 );
 
 mux_wb VP_mux_wb5(
           .des1_1_o(wb_alu_des1_1),.des2_1_o(wb_alu_des2_1),.des1_2_o(wb_alu_des1_2),.des2_2_o(wb_alu_des2_2),.des1_3_o(wb_alu_des1_3),.des2_3_o(wb_alu_des2_3),
           .des1_4_o(wb_alu_des1_4),.des2_4_o(wb_alu_des2_4),.des1_5_o(wb_alu_des1_5),.des2_5_o(wb_alu_des2_5),.des1_6_o(wb_alu_des1_6),.des2_6_o(wb_alu_des2_6),.des1_7_o(wb_alu_des1_7),.des2_7_o(wb_alu_des2_7),
           .desCy_o(wb_alu_desCy),.desAc_o(wb_alu_desAc),.desOv_o(wb_alu_desOv),
           .desCy2_o(wb_alu_desCy2),.desAc2_o(wb_alu_desAc2),.desOv2_o(wb_alu_desOv2),
           .desCy3_o(wb_alu_desCy3),.desAc3_o(wb_alu_desAc3),.desOv3_o(wb_alu_desOv3),
           .desCy4_o(wb_alu_desCy4),.desAc4_o(wb_alu_desAc4),.desOv4_o(wb_alu_desOv4),
           .desCy5_o(wb_alu_desCy5),.desAc5_o(wb_alu_desAc5),.desOv5_o(wb_alu_desOv5),
           .desCy6_o(wb_alu_desCy6),.desAc6_o(wb_alu_desAc6),.desOv6_o(wb_alu_desOv6),
           .desCy7_o(wb_alu_desCy7),.desAc7_o(wb_alu_desAc7),.desOv7_o(wb_alu_desOv7),
           .alu_code_wb(wb_alu_code5),
           .des1_r(des1_r5),.des2_r(des2_r5),
           .desCy_r1(desCy_r5),.desAc_r(desAc_r5),.desOv_r(desOv_r5));

//reg
alu_to_reg VP_alu_to_reg1 (.clk(clk),.rst(rst),.des1(des1_r1),.des2(des2_r1), .desCy(desCy_r1), .desAc(desAc_r1), .desOv(desOv_r1), .alu(alu1),
                        .des1_reg(des1_reg1),.des2_reg(des2_reg1),.desCy_reg(desCy_reg1), .desAc_reg(desAc_reg1), .desOv_reg(desOv_reg1));   
                                        
alu_to_reg VP_alu_to_reg2 (.clk(clk),.rst(rst),.des1(des1_r2),.des2(des2_r2), .desCy(desCy_r2), .desAc(desAc_r2), .desOv(desOv_r2), .alu(alu2),
                        .des1_reg(des1_reg2),.des2_reg(des2_reg2),.desCy_reg(desCy_reg2), .desAc_reg(desAc_reg2), .desOv_reg(desOv_reg2));   
                              
alu_to_reg VP_alu_to_reg3 (.clk(clk),.rst(rst),.des1(des1_r3),.des2(des2_r3), .desCy(desCy_r3), .desAc(desAc_r3), .desOv(desOv_r3), .alu(alu3),
                        .des1_reg(des1_reg3),.des2_reg(des2_reg3),.desCy_reg(desCy_reg3), .desAc_reg(desAc_reg3), .desOv_reg(desOv_reg3));    
                             
alu_to_reg VP_alu_to_reg4 (.clk(clk),.rst(rst),.des1(des1_r4),.des2(des2_r4), .desCy(desCy_r4), .desAc(desAc_r4), .desOv(desOv_r4), .alu(alu4),
                        .des1_reg(des1_reg4),.des2_reg(des2_reg4),.desCy_reg(desCy_reg4), .desAc_reg(desAc_reg4), .desOv_reg(desOv_reg4));    
                             
alu_to_reg VP_alu_to_reg5 (.clk(clk),.rst(rst),.des1(des1_r5),.des2(des2_r5), .desCy(desCy_r5), .desAc(desAc_r5), .desOv(desOv_r5), .alu(alu5),
                        .des1_reg(des1_reg5),.des2_reg(des2_reg5),.desCy_reg(desCy_reg5), .desAc_reg(desAc_reg5), .desOv_reg(desOv_reg5));     
                                   
//ram_wr_sel ram_wr_sel1 (.sel(ram_wr_sel_r),  .sp(sp), .rn(rn_r), .imm(op2_dr_r), .ri(ri_r), .imm2(op3_nr), .out(wr_addr));
ram_wr_sel VP_ram_wr_sel1 (.sel(wb_ram_wr_sel_o1), .sp(sp1), .rn({psw1[4:3], op1_out_o1_wb[2:0]}), .imm(op2_direct_o1_wb), .ri(Indi_data_out1_wb), .imm2(op3_out_o1_wb), .out(wr_addr_out1));
ram_wr_sel VP_ram_wr_sel2 (.sel(wb_ram_wr_sel_o2), .sp(sp2), .rn({psw2[4:3], op1_out_o2_wb[2:0]}), .imm(op2_direct_o2_wb), .ri(Indi_data_out2_wb), .imm2(op3_out_o2_wb), .out(wr_addr_out2));
ram_wr_sel VP_ram_wr_sel3 (.sel(wb_ram_wr_sel_o3), .sp(sp3), .rn({psw3[4:3], op1_out_o3_wb[2:0]}), .imm(op2_direct_o3_wb), .ri(Indi_data_out3_wb), .imm2(op3_out_o3_wb), .out(wr_addr_out3));
ram_wr_sel VP_ram_wr_sel4 (.sel(wb_ram_wr_sel_o4), .sp(sp4), .rn({psw4[4:3], op1_out_o4_wb[2:0]}), .imm(op2_direct_o4_wb), .ri(Indi_data_out4_wb), .imm2(op3_out_o4_wb), .out(wr_addr_out4));
ram_wr_sel VP_ram_wr_sel5 (.sel(wb_ram_wr_sel_o5), .sp(sp5), .rn({psw5[4:3], op1_out_o5_wb[2:0]}), .imm(op2_direct_o5_wb), .ri(Indi_data_out5_wb), .imm2(op3_out_o5_wb), .out(wr_addr_out5));


endmodule
