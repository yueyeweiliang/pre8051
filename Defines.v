//////////////////////////////////////////////////////////////////////
////                                                              ////
////  8051 cores Definitions              		          ////
////                                                              ////
////  This file is part of the 8051 cores project                 ////
////  http://www.opencores.org/cores/8051/                        ////
////                                                              ////
////  Description                                                 ////
////  8051 definitions.                                           ////
////                                                              ////
////  To Do:                                                      ////
////   Nothing                                                    ////
////                                                              ////
////  Author(s):                                                  ////
////      - Simon Teran, simont@opencores.org                     ////
////      - Jaka Simsic, jakas@opencores.org                      ////
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

`timescale 1ns/10ps


//
// operation codes for alu
//


`define ALU_NOP 4'b0000
`define ALU_ADD 4'b0001
`define ALU_SUB 4'b0010
`define ALU_MUL 4'b0011
`define ALU_DIV 4'b0100
`define ALU_DA 4'b0101
`define ALU_NOT 4'b0110
`define ALU_AND 4'b0111
`define ALU_XOR 4'b1000
`define ALU_OR 4'b1001
`define ALU_RL 4'b1010
`define ALU_RLC 4'b1011
`define ALU_RR 4'b1100
`define ALU_RRC 4'b1101
`define ALU_PCS 4'b1110
`define ALU_XCH 4'b1111

//
// sfr addresses
//

`define SFR_ACC 8'he0 //accumulator
`define SFR_B 8'hf0 //b register
`define SFR_PSW 8'hd0 //program status word
`define SFR_P0 8'h80 //port 0
`define SFR_P1 8'h90 //port 1
`define SFR_P2 8'ha0 //port 2
`define SFR_P3 8'hb0 //port 3
`define SFR_DPTR_LO 8'h82 // data pointer high bits
`define SFR_DPTR_HI 8'h83 // data pointer low bits
`define SFR_IP 8'hb8 // interrupt priority control
`define SFR_IE 8'ha8 // interrupt enable control
`define SFR_TMOD 8'h89 // timer/counter mode
`define SFR_TCON 8'h88 // timer/counter control
`define SFR_TH0 8'h8c // timer/counter 0 high bits
`define SFR_TL0 8'h8a // timer/counter 0 low bits
`define SFR_TH1 8'h8d // timer/counter 1 high bits
`define SFR_TL1 8'h8b // timer/counter 1 low bits
`define SFR_SCON 8'h98 // serial control
`define SFR_SBUF 8'h98 // serial data buffer
`define SFR_SP 8'h81 // stack pointer

//
// sfr bit addresses
//
`define SFR_B_ACC 5'b11100 //accumulator
`define SFR_B_PSW 5'b11010 //program status word
`define SFR_B_P0 5'b10000 //port 0
`define SFR_B_P1 5'b10010 //port 1
`define SFR_B_P2 5'b10100 //port 2
`define SFR_B_P3 5'b10110 //port 3

//
// alu source select
//
`define ASS_RAM 2'b00 // RAM
`define ASS_ACC 2'b01 // accumulator
`define ASS_XRAM 2'b10 // external RAM -- source1
`define ASS_ZERO 2'b10 // 8'h00 -- source2
`define ASS_IMM 2'b11 // immediate data -- source1
`define ASS_OP2 2'b11 //  pc low -- source2
`define ASS_DC 2'bxx //

//
// alu source 3 select
//
`define AS3_PC 1'b1 // program clunter
`define AS3_DP 1'b0 // data pointer
`define AS3_DC 1'bx //

//
//carry input in alu
//
`define CY_0 2'b00 // 1'b0;
`define CY_PSW 2'b01 // carry from psw
`define CY_RAM 2'b10 // carry from ram
`define CY_1 2'b11 // 1'b1;
`define CY_DC 2'bxx // carry from psw

//
// instruction set
//

//op_code [4:0]
`define ACALL 5'b1_0001 // absolute call
`define AJMP 5'b0_0001 // absolute jump

//op_code [7:3]
`define ADD_R 8'b0010_1xxx // add A=A+Rx
`define ADDC_R 8'b0011_1xxx // add A=A+Rx+c
`define ANL_R 8'b0101_1xxx // and A=A^Rx
`define CJNE_R 8'b1011_1xxx // compare and jump if not equal; Rx<>constant
`define DEC_R 8'b0001_1xxx // decrement reg Rn=Rn-1
`define DJNZ_R 8'b1101_1xxx // decrement and jump if not zero
`define INC_R 8'b0000_1xxx // increment Rn
`define MOV_R 8'b1110_1xxx // move A=Rn
`define MOV_AR 8'b1111_1xxx // move Rn=A
`define MOV_DR 8'b1010_1xxx // move Rn=(direct)
`define MOV_CR 8'b0111_1xxx // move Rn=constant
`define MOV_RD 8'b1000_1xxx // move (direct)=Rn
`define ORL_R 8'b0100_1xxx // or A=A or Rn
`define SUBB_R 8'b1001_1xxx // substract with borrow  A=A-c-Rn
`define XCH_R 8'b1100_1xxx // exchange A<->Rn
`define XRL_R 8'b0110_1xxx // XOR A=A XOR Rn

//op_code [7:1]
`define ADD_I 8'b0010_011x // add A=A+@Ri
`define ADDC_I 8'b0011_011x // add A=A+@Ri+c
`define ANL_I 8'b0101_011x // and A=A^@Ri
`define CJNE_I 8'b1011_011x // compare and jump if not equal; @Ri<>constant
`define DEC_I 8'b0001_011x // decrement indirect @Ri=@Ri-1
`define INC_I 8'b0000_011x // increment @Ri
`define MOV_I 8'b1110_011x // move A=@Ri
`define MOV_ID 8'b1000_011x // move (direct)=@Ri
`define MOV_AI 8'b1111_011x // move @Ri=A
`define MOV_DI 8'b1010_011x // move @Ri=(direct)
`define MOV_CI 8'b0111_011x // move @Ri=constant
`define MOVX_IA 8'b1110_001x // move A=(@Ri)
`define MOVX_AI 8'b1111_001x // move (@Ri)=A
`define ORL_I 8'b0100_011x // or A=A or @Ri
`define SUBB_I 8'b1001_011x // substract with borrow  A=A-c-@Ri
`define XCH_I 8'b1100_011x // exchange A<->@Ri
`define XCHD 8'b1101_011x // exchange digit A<->Ri
`define XRL_I 8'b0110_011x // XOR A=A XOR @Ri

//op_code [7:0]
`define ADD_D 8'b0010_0101 // add A=A+(direct)
`define ADD_C 8'b0010_0100 // add A=A+constant
`define ADDC_D 8'b0011_0101 // add A=A+(direct)+c
`define ADDC_C 8'b0011_0100 // add A=A+constant+c
`define ANL_D 8'b0101_0101 // and A=A^(direct)
`define ANL_C 8'b0101_0100 // and A=A^constant
`define ANL_DD 8'b0101_0010 // and (direct)=(direct)^A
`define ANL_DC 8'b0101_0011 // and (direct)=(direct)^constant
`define ANL_B 8'b1000_0010 // and c=c^bit
`define ANL_NB 8'b1011_0000 // and c=c^!bit
`define CJNE_D 8'b1011_0101 // compare and jump if not equal; a<>(direct)
`define CJNE_C 8'b1011_0100 // compare and jump if not equal; a<>constant
`define CLR_A 8'b1110_0100 // clear accumulator
`define CLR_C 8'b1100_0011 // clear carry
`define CLR_B 8'b1100_0010 // clear bit
`define CPL_A 8'b1111_0100 // complement accumulator
`define CPL_C 8'b1011_0011 // complement carry
`define CPL_B 8'b1011_0010 // complement bit
`define DA 8'b1101_0100 // decimal adjust (A)
`define DEC_A 8'b0001_0100 // decrement accumulator a=a-1
`define DEC_D 8'b0001_0101 // decrement direct (direct)=(direct)-1
`define DIV 8'b1000_0100 // divide
`define DJNZ_D 8'b1101_0101 // decrement and jump if not zero (direct)
`define INC_A 8'b0000_0100 // increment accumulator
`define INC_D 8'b0000_0101 // increment (direct)
`define INC_DP 8'b1010_0011 // increment data pointer
`define JB 8'b0010_0000 // jump if bit set
`define JBC 8'b0001_0000 // jump if bit set and clear bit
`define JC 8'b0100_0000 // jump if carry is set 
`define JMP 8'b0111_0011 // jump indirect
`define JNB 8'b0011_0000 // jump if bit not set
`define JNC 8'b0101_0000 // jump if carry not set
`define JNZ 8'b0111_0000 // jump if accumulator not zero
`define JZ 8'b0110_0000 // jump if accumulator zero
`define LCALL 8'b0001_0010 // long call
`define LJMP 8'b0000_0010 // long jump
`define MOV_D 8'b1110_0101 // move A=(direct)
`define MOV_C 8'b0111_0100 // move A=constant
`define MOV_DA 8'b1111_0101 // move (direct)=A
`define MOV_DD 8'b1000_0101 // move (direct)=(direct)
`define MOV_CD 8'b0111_0101 // move (direct)=constant
`define MOV_BC 8'b1010_0010 // move c=bit
`define MOV_CB 8'b1001_0010 // move bit=c
`define MOV_DP 8'b1001_0000 // move dptr=constant(16 bit)
`define MOVC_DP 8'b1001_0011 // move A=dptr+A
`define MOVC_PC 8'b1000_0011 // move A=pc+A
`define MOVX_PA 8'b1110_0000 // move A=(dptr)
`define MOVX_AP 8'b1111_0000 // move (dptr)=A
`define MUL 8'b1010_0100 // multiply a*b
`define NOP 8'b0000_0000 // no operation
`define ORL_D 8'b0100_0101 // or A=A or (direct)
`define ORL_C 8'b0100_0100 // or A=A or constant
`define ORL_AD 8'b0100_0010 // or (direct)=(direct) or A
`define ORL_CD 8'b0100_0011 // or (direct)=(direct) or constant
`define ORL_B 8'b0111_0010 // or c = c or bit
`define ORL_NB 8'b1010_0000 // or c = c or !bit
`define POP 8'b1101_0000 // stack pop
`define PUSH 8'b1100_0000 // stack push
`define RET 8'b0010_0010 // return from subrutine
`define RETI 8'b0011_0010 // return from interrupt
`define RL 8'b0010_0011 // rotate left
`define RLC 8'b0011_0011 // rotate left thrugh carry
`define RR 8'b0000_0011 // rotate right
`define RRC 8'b0001_0011 // rotate right thrugh carry
`define SETB_C 8'b1101_0011 // set carry
`define SETB_B 8'b1101_0010 // set bit
`define SJMP 8'b1000_0000 // short jump
`define SUBB_D 8'b1001_0101 // substract with borrow  A=A-c-(direct)	
`define SUBB_C 8'b1001_0100 // substract with borrow  A=A-c-constant
`define SWAP 8'b1100_0100 // swap A(0-3) <-> A(4-7)
`define XCH_D 8'b1100_0101 // exchange A<->(direct)
`define XRL_D 8'b0110_0101 // XOR A=A XOR (direct)
`define XRL_C 8'b0110_0100 // XOR A=A XOR constant
`define XRL_AD 8'b0110_0010 // XOR (direct)=(direct) XOR A
`define XRL_CD 8'b0110_0011 // XOR (direct)=(direct) XOR constant


//
// default values (used after reset)
//
`define RST_PC 16'h0000 // program counter
`define RST_ACC 8'h00 // accumulator
`define RST_B 8'h00 // b register
`define RST_PSW 8'h00 // program status word
`define RST_SP 8'b0000_0111 // stack pointer
`define RST_DPH 8'h00 // data pointer (high)
`define RST_DPL 8'h00 // data pointer (low)
`define RST_P0 8'b1111_1111 // port 0
`define RST_P1 8'b1111_1111 // port 1
`define RST_P2 8'b1111_1111 // port 2
`define RST_P3 8'b1111_1111 // port 3
`define RST_IP 8'b0000_0000 // interrupt priority
`define RST_IE 8'b0000_0000 // interrupt enable
`define RST_TMOD 8'b0000_0000 // timer/counter mode control
`define RST_TCON 8'b0000_0000 // timer/counter control
`define RST_TH0 8'b0000_0000 // timer/counter 0 high bits
`define RST_TL0 8'b0000_0000 // timer/counter 0 low bits
`define RST_TH1 8'b0000_0000 // timer/counter 1 high bits
`define RST_TL1 8'b0000_0000 // timer/counter 1 low bits
`define RST_SCON 8'b0000_0000 // serial control
`define RST_SBUFF 8'bxxxx_xxxx // serial data buffer

//
// ram read select
//

`define RRS_RN 2'b00 // registers
`define RRS_I 2'b01 // indirect addressing
`define RRS_D 2'b10 // direct addressing
`define RRS_SP 2'b11 // stack pointer
`define RRS_DC 2'bxx // don't c

//
// ram write select
//

`define RWS_RN 3'b000 // registers
`define RWS_D 3'b001 // direct addressing
`define RWS_I 3'b010 // indirect addressing
`define RWS_SP 3'b011 // stack pointer
`define RWS_ACC 3'b100 // accumulator
`define RWS_D3 3'b101 // direct address (op3)
`define RWS_DPTR 3'b110 // data pointer (high + low)
`define RWS_B 3'b111 // b register
`define RWS_DC 3'bxxx //

//
// immediate data select
//

`define IDS_OP2 2'b00 // operand 2
`define IDS_OP3 2'b01 // operand 3
`define IDS_PCH 2'b10 // pc high
`define IDS_PCL 2'b11 // pc low
`define IDS_DC 2'bxx // pc low


//
// pc in select
//
`define PIS_DC 2'bxx // dont c
`define PIS_SP 2'b00 // stack ( des1 -- serial)
`define PIS_ALU 2'b01 // alu {des1, des2}
`define PIS_I11 2'b10 // 11 bit immediate
`define PIS_I16 2'b11 // 16 bit immediate

//
// compare source select
//
`define CSS_AZ 3'b000 // eq = accumulator == zero
`define CSS_AR 3'b001 // eq = accumulator == ram
`define CSS_AC 3'b010 // eq = accumulator == constant
`define CSS_CR 3'b011 // eq = constant == ram
`define CSS_DES 3'b100 // eq = destination == zero
`define CSS_CY 3'b101 // eq = cy
`define CSS_BIT 3'b110 // eq = b_in
`define CSS_DC 3'bxxx // don't care


//
// pc Write
//
`define PCW_N 1'b0 // not
`define PCW_Y 1'b1 // yes

//
//psw set
//
`define PS_NOT 2'b00 // DONT
`define PS_CY 2'b01 // only carry
`define PS_OV 2'b10 // carry and overflov
`define PS_AC 2'b11 // carry, overflov an ac...

//
// rom address select
//
`define RAS_PC 1'b0 // program counter
`define RAS_DES 1'b1 // alu destination

//
// write accumulator
//
`define WA_N 1'b0 // not
`define WA_Y 1'b1 // yes


//
//external ram address select
//
`define EAS_DPTR 1'b0 // data pointer
`define EAS_RI 1'b1 // register R0 or R1
`define EAS_DC 1'bx

//
//write ac from des2
//
`define WAD_N 1'b0 //
`define WAD_Y 1'b1 //



////////////////////////////////////////////////////

//
// Timer/Counter modes
//

`define MODE0 2'b00  // mode 0
`define MODE1 2'b01  // mode 0
`define MODE2 2'b10  // mode 0
`define MODE3 2'b11  // mode 0


//
// Interrupt numbers (vectors)
//

`define INT_T0 8'h0b  // T/C 0 owerflow interrupt
`define INT_T1 8'h1b  // T/C 1 owerflow interrupt
`define INT_X0 8'h03  // external interrupt 0
`define INT_X1 8'h13  // external interrupt 1


//
// miscellaneus
//

`define RW0 1'b0
`define RW1 1'b1
