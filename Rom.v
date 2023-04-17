//////////////////////////////////////////////////////////////////////
////                                                              ////
////  8051 program rom                                            ////
////                                                              ////
////  This file is part of the 8051 cores project                 ////
////  http://www.opencores.org/cores/8051/                        ////
////                                                              ////
////  Description                                                 ////
////   program rom                                                ////
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

module rom (rst, clk, addr, data1, data2, data3);
// clk          clock
// rst          reset
// addr         addres
// data1        1 byte of instruction
// data2        2 byte of instruction
// data3        3 byte of instruction


input rst, clk;
input [15:0] addr;
output data1, data2, data3;

reg [7:0] data1, data2, data3;

reg [7:0] buff [65535:0];

always @(rst)
begin
//
//set the program whe rset is active
  if (rst)
  begin
    buff [16'h00_00] <= #1 `NOP;

    buff [16'h00_01] <= #1 `MOV_C; // mov a=imm -- a=h02
    buff [16'h00_02] <= #1 8'h02;

    buff [16'h00_03] <= #1 `MOV_CD; // mov @op2 = imm -- @(h05)= h22;
    buff [16'h00_04] <= #1 8'h05;
    buff [16'h00_05] <= #1 8'h22;

    buff [16'h00_06] <= #1 `ADD_C; // add a=a+imm -- a=h02+h04
    buff [16'h00_07] <= #1 8'h04;

    buff [16'h00_08] <= #1 `SJMP; // sjmp pc = pc+op2
    buff [16'h00_09] <= #1 8'h20;

    buff [16'h00_0a] <= #1 `MOV_C; // mov a=imm
    buff [16'h00_0b] <= #1 8'h11;

    buff [16'h00_0c] <= #1 `ADD_D;
    buff [16'h00_0d] <= #1 8'h05;

    buff [16'h00_2a] <= #1 `ADD_C; // add a=a+imm --
    buff [16'h00_2b] <= #1 8'h03;

    buff [16'h00_2c] <= #1 {3'b000, `AJMP};  // ajmp  (pc= op1,op2)
    buff [16'h00_2d] <= #1 8'h44;

    buff [16'h00_2e] <= #1 `MOV_C; // mov a=imm
    buff [16'h00_2f] <= #1 8'hff;


//interrupt
    buff [16'h00_39] <= #1 `ADD_C; // add a:=a+1
    buff [16'h00_3a] <= #1 8'h01;

    buff [16'h00_3b] <= #1 `RETI;



    buff [16'h00_44] <= #1 `XCH_D; // exchange a<=> @(op2) --
    buff [16'h00_45] <= #1 8'h05;

    buff [16'h00_46] <= #1 `MOV_D; // move a=@(op2)
    buff [16'h00_47] <= #1 8'h05;

    buff [16'h00_48] <= #1 `NOP; // no operation

    buff [16'h00_49] <= #1 `MOV_C; // mov a=imm -- a=h06
    buff [16'h00_4a] <= #1 8'h06;

    buff [16'h00_4b] <= #1 `LCALL; // long call -- pc = {op2 op3}
    buff [16'h00_4c] <= #1 8'h01;
    buff [16'h00_4d] <= #1 8'h84;

    buff [16'h00_4e] <= #1 `JZ; // jump if acc=0
    buff [16'h00_4f] <= #1 8'h03;

    buff [16'h00_50] <= #1 `MOV_C; // mov a=imm -- a=h02
    buff [16'h00_51] <= #1 8'h02;

    buff [16'h00_52] <= #1 `NOP; // no operation

    buff [16'h00_53] <= #1 `MOV_CD; // mov @op2 = imm -- @(h50)= h01;
    buff [16'h00_54] <= #1 8'h50;
    buff [16'h00_55] <= #1 8'h01;

    buff [16'h00_56] <= #1 `MOV_C; // a= h77
    buff [16'h00_57] <= #1 8'h77;


    buff [16'h00_58] <= #1 `DJNZ_D; // IF (@(OP2)-1 == 0) PC=PC+OP3;
    buff [16'h00_59] <= #1 8'h50;
    buff [16'h00_5a] <= #1 8'h10;


/*    buff [16'h00_58] <= #1 `DJNZ_R; // IF (@(OP2)-1 == 0) PC=PC+OP3;
    buff [16'h00_59] <= #1 8'h11;*/

    buff [16'h00_5b] <= #1 `MOV_C; // a= h88
    buff [16'h00_5c] <= #1 8'h88;

    buff [16'h00_5d] <= #1 `NOP; // no operation
    buff [16'h00_5e] <= #1 `NOP; // no operation
    buff [16'h00_5f] <= #1 `NOP; // no operation

    buff [16'h00_6b] <= #1 `MOV_C; // a= h99
    buff [16'h00_6c] <= #1 8'h99;


    buff [16'h00_6d] <= #1 `MOV_CD; // mov @op2 = imm -- R3= h01;
    buff [16'h00_6e] <= #1 8'h03;
    buff [16'h00_6f] <= #1 8'h01;

    buff [16'h00_70] <= #1 8'h2b; // add acc = acc+ R3 -- acc= h9a;


    buff [16'h00_71] <= #1 `MOV_CD; // mov @op2 = imm -- psw= h01;
    buff [16'h00_72] <= #1 `SFR_PSW;
    buff [16'h00_73] <= #1 8'b1000_0000;

    buff [16'h00_74] <= #1 8'h3b; // addc acc = acc+r3+c

    buff [16'h00_75] <= #1 8'h5b; // anl acc = acc & r3 =h00

    buff [16'h00_76] <= #1 `MOV_CD; // mov @op2 = imm -- r0= h03;
    buff [16'h00_77] <= #1 8'h00;
    buff [16'h00_78] <= #1 8'h03;

    buff [16'h00_79] <= #1 8'h26;  // add a= a+ @(r0) -- a=h01

    buff [16'h00_7a] <= #1 8'h36;  // addc a= a+ @(r0) -- a=h03

    buff [16'h00_7b] <= #1 `ADD_D;  // add a= a + @(op2) -- a=h0b
    buff [16'h00_7c] <= #1 8'h05;

    buff [16'h00_7d] <= #1 8'h56;  // anl a= a & @(r0) -- a=h01

    buff [16'h00_7e] <= #1 `ANL_D;  // anl a= a & @(op2) -- a=h01
    buff [16'h00_7f] <= #1 8'h05;

    buff [16'h00_80] <= #1 `ANL_C;  // anl a= a & op2 -- a=h00
    buff [16'h00_81] <= #1 8'hf4;

    buff [16'h00_82] <= #1 `MOV_C; // a= h7f
    buff [16'h00_83] <= #1 8'h7f;

    buff [16'h00_84] <= #1 `ANL_DD; // anl @(op2)= @(op2) & acc -- @(op2)=h09
    buff [16'h00_85] <= #1 8'h05;

    buff [16'h00_86] <= #1 `ANL_DC; // anl @(op2)= @(op2) & op3 -- @(op2)=h01
    buff [16'h00_87] <= #1 8'h05;
    buff [16'h00_88] <= #1 8'h07;

    buff [16'h00_89] <= #1 8'hbb; // cjne -- jump if op2<>r3
    buff [16'h00_8a] <= #1 8'h01;
    buff [16'h00_8b] <= #1 8'h10;

    buff [16'h00_8c] <= #1 8'hb6; // cjne -- jump if op2<>@(r0)
    buff [16'h00_8d] <= #1 8'h00;
    buff [16'h00_8e] <= #1 8'h10;

    buff [16'h00_9f] <= #1 `MOV_C; // a= h01
    buff [16'h00_a0] <= #1 8'h01;

    buff [16'h00_a1] <= #1 `MOV_DP; // dptr= {op2, op3} -- dptr = h0110
    buff [16'h00_a2] <= #1 8'h01;
    buff [16'h00_a3] <= #1 8'h10;

    buff [16'h00_a4] <= #1 `INC_DP; // increment dptr -- dptr = h0111

    buff [16'h00_a5] <= #1 8'h79; // mov R1= op2 =hc8
    buff [16'h00_a6] <= #1 8'hc8;

    buff [16'h00_a7] <= #1 8'h77; // mov @R1= op2 =ha6
    buff [16'h00_a8] <= #1 8'ha6;

    buff [16'h00_a9] <= #1 8'he7; // mov a= @R1 = ha6

    buff [16'h00_aa] <= #1 8'he9; // mov a= R1 = hc8

    buff [16'h00_ab] <= #1 8'hfd; // mov R5= a = hc8

    buff [16'h00_ac] <= #1 8'h8d; // mov @op2= R5 = hc8
    buff [16'h00_ad] <= #1 8'he8;


    buff [16'h00_ae] <= #1 `MOV_DD; // mov @op3= @op2 = hc8
    buff [16'h00_af] <= #1 8'he8;
    buff [16'h00_b0] <= #1 8'hf8;


    buff [16'h00_b1] <= #1 `MOV_C; // mov acc = op2 = h00
    buff [16'h00_b2] <= #1 8'h00;

    buff [16'h00_b3] <= #1 `MOV_D; // mov acc = @op2 = hc8
    buff [16'h00_b4] <= #1 8'hf8;

    buff [16'h00_b5] <= #1 `MOV_DA; // mov  @op2 = acc = hc8
    buff [16'h00_b6] <= #1 8'hf9;


    buff [16'h00_b7] <= #1 8'hac; // mov R4 = @op2 = hc8
    buff [16'h00_b8] <= #1 8'hf9;

    buff [16'h00_b9] <= #1 8'h78; // mov R1= op2 =hfa
    buff [16'h00_ba] <= #1 8'hfa;

    buff [16'h00_bb] <= #1 8'ha6; // mov R1= op2 =hfa
    buff [16'h00_bc] <= #1 8'hf9;

    buff [16'h00_bd] <= #1 `MOV_C; // mov acc = op2 = h01
    buff [16'h00_be] <= #1 8'h01;

    buff [16'h00_bf] <= #1 8'hec; // mov a= R4 = hc8

    buff [16'h00_c0] <= #1 `MOV_C; // mov acc = op2 = h02
    buff [16'h00_c1] <= #1 8'h02;

    buff [16'h00_c2] <= #1 8'he6; // mov a= @R0 = hc8

    buff [16'h00_c3] <= #1 `MOV_C; // mov acc = op2 = h50
    buff [16'h00_c4] <= #1 8'h50;

    buff [16'h00_c5] <= #1 8'hf6; // mov @r0 = acc = h50


    buff [16'h00_c6] <= #1 8'h16; // dec @r0 =  h4f

    buff [16'h00_c7] <= #1 8'h86; // mov @op2 = @r0 = h4f
    buff [16'h00_c8] <= #1 8'he9;

    buff [16'h00_c9] <= #1 `MOV_C; // mov acc = op2 = h03
    buff [16'h00_ca] <= #1 8'h03;

    buff [16'h00_cb] <= #1 `MOV_D; // mov acc = @op2 = h4f
    buff [16'h00_cc] <= #1 8'he9;

    buff [16'h00_cd] <= #1 `DEC_A; // dec acc =  h4e

    buff [16'h00_ce] <= #1 `DEC_D; // dec @op2 =  hc7
    buff [16'h00_cf] <= #1 8'hf8;

    buff [16'h00_d0] <= #1 `MOV_D; // mov acc = @op2 =  hc7
    buff [16'h00_d1] <= #1 8'hf8;

    buff [16'h00_d2] <= #1 `INC_A; // inc acc =  hc8

    buff [16'h00_d3] <= #1 8'h06; // inc @r0 =  h50

    buff [16'h00_d4] <= #1 8'h86; // mov @op2 = @r0 = h50
    buff [16'h00_d5] <= #1 8'hc7;

    buff [16'h00_d6] <= #1 `INC_D; // inc @op2 = h51
    buff [16'h00_d7] <= #1 8'hc7;

    buff [16'h00_d8] <= #1 `MOV_D; // mov acc = @op2 = h51
    buff [16'h00_d9] <= #1 8'hc7;

    buff [16'h00_da] <= #1 8'h08; // inc R0 = hfb

    buff [16'h00_db] <= #1 8'he8; // inc acc = R0 = hfb


    buff [16'h00_dc] <= #1 `MOV_C; // mov acc = h00
    buff [16'h00_dd] <= #1 8'h00; // mov acc = h00

    buff [16'h00_de] <= #1 8'he2; // mov external acc = (@R0) =  hfb

    buff [16'h00_df] <= #1 `MOVX_AP; // mov external  (@dptr) = acc = hfb


    buff [16'h00_e0] <= #1 `MOVX_PA; // mov external acc = (@dptr) =  h11

    buff [16'h00_e1] <= #1 8'hf2; // mov external (@R0) = acc =  h11

    buff [16'h00_e2] <= #1 `MOV_C; // mov external  (@dptr) = acc = hee
    buff [16'h00_e3] <= #1 8'h88;

    buff [16'h00_e4] <= #1 `MOV_CB; // MOV (BIT) = cy = 1
    buff [16'h00_e5] <= #1 8'h35;

    buff [16'h00_e6] <= #1 `CPL_B; // complement (BIT) = 0
    buff [16'h00_e7] <= #1 8'h35;

    buff [16'h00_e8] <= #1 `CPL_C; // complement cy = 0

    buff [16'h00_e9] <= #1 `SETB_C; // set carry = 1

    buff [16'h00_ea] <= #1 `MOV_BC; // mov carry = (bit) 0
    buff [16'h00_eb] <= #1 8'h35;

    buff [16'h00_ec] <= #1 `SETB_B; // set (bit) = 1
    buff [16'h00_ed] <= #1 8'h35;

    buff [16'h00_ee] <= #1 `ORL_B; // OR CY=cy or (bit) = 1
    buff [16'h00_ef] <= #1 8'h35;

    buff [16'h00_ee] <= #1 `ORL_B; // OR CY=cy or (bit) = 1
    buff [16'h00_ef] <= #1 8'h35;

    buff [16'h00_f0] <= #1 `CLR_B; // (bit) = 0
    buff [16'h00_f1] <= #1 8'h35;

    buff [16'h00_f2] <= #1 `ANL_B; // AND CY=cy AND (bit) = 0
    buff [16'h00_f3] <= #1 8'h35;

    buff [16'h00_f4] <= #1 `ANL_NB; // AND CY=cy AND not (bit) = 0
    buff [16'h00_f5] <= #1 8'h35;

    buff [16'h00_f6] <= #1 `ORL_NB; // or CY=cy or not (bit) = 1
    buff [16'h00_f7] <= #1 8'h35;

    buff [16'h00_f8] <= #1 `CLR_C; // clear CY=0

/////*******
//    buff [16'h00_f8] <= #1 `NOP;


    buff [16'h00_f9] <= #1 `JC;  //pc=cy? : h016c
    buff [16'h00_fa] <= #1 8'h71;




    buff [16'h00_fb] <= #1 `MOV_CD;
    buff [16'h00_fc] <= #1 8'h71;
    buff [16'h00_fd] <= #1 8'h82;

    buff [16'h00_fe] <= #1 `PUSH;
    buff [16'h00_ff] <= #1 8'h71;

    buff [16'h01_00] <= #1 8'h7c; //MOV R4 =h03
    buff [16'h01_01] <= #1 8'h03;

    buff [16'h01_02] <= #1 8'hcc; //`XCH r4<=>acc;

    buff [16'h01_03] <= #1 `POP;
    buff [16'h01_04] <= #1 8'h72;

    buff [16'h01_05] <= #1 `SETB_C; // set carry = 1

    buff [16'h01_06] <= #1 `ADDC_D;
    buff [16'h01_07] <= #1 8'h72;

    buff [16'h01_08] <= #1 `RLC; //acc=h0C; cy=1;

//    buff [16'h01_08] <= #1 `RL; //acc=h0d; cy=0;

    buff [16'h01_09] <= #1 `JNC; // jumf in carry not set;
    buff [16'h01_0a] <= #1 8'h61;

    buff [16'h01_0b] <= #1 `MOV_C; // mov acc=h11
    buff [16'h01_0c] <= #1 8'h11;

    buff [16'h01_0d] <= #1 `MOVC_DP;   // mov code acc=18


    buff [16'h01_0e] <= #1 `MOVC_PC;   // mov code acc=34


    buff [16'h01_0f] <= #1 `NOP;




    buff [16'h01_22] <= #1 8'h18;
    buff [16'h01_27] <= #1 8'h34;


    buff [16'h01_6c] <= #1 `MOV_C;   /////****
    buff [16'h01_6d] <= #1 8'h00;

/////*******


    buff [16'h01_84] <= #1 `ADD_C; // add a=a+imm
    buff [16'h01_85] <= #1 8'h08;

    buff [16'h01_86] <= #1 `MOV_D; // move a=@(op2)
    buff [16'h01_87] <= #1 8'h09;

    buff [16'h01_88] <= #1 `RET; // return from subrutine pc = @sp

    buff [16'h01_89] <= #1 `MOV_C; // mov a=imm -- a=h02
    buff [16'h01_8a] <= #1 8'h55;

  end
end

//
// always read tree bits in row
always @(posedge clk)
begin
  data1 <= #1 buff [addr];
  data2 <= #1 buff [addr+1];
  data3 <= #1 buff [addr+2];
end


endmodule
