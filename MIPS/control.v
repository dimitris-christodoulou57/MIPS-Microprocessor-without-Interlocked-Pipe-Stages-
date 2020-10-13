`include "constants.h"

/************** Main control in ID pipe stage  *************/
module control_main(output reg RegDst,
                output reg Branch,  
                output reg MemRead,
                output reg MemWrite,  
                output reg MemToReg,  
                output reg ALUSrc,  
                output reg RegWrite,  
                output reg [1:0] ALUcntrl,  
                input [5:0] opcode);

  always @(*) 
   begin
     case (opcode)
      `R_FORMAT: 
          begin 
            RegDst = 1'b1;
            MemRead = 1'b0;
            MemWrite = 1'b0;
            MemToReg = 1'b0;
            ALUSrc = 1'b0;
            RegWrite = 1'b1;
            Branch = 1'b0;         
            ALUcntrl  = 2'b10; // R             
          end
       `LW :   
           begin 
            RegDst = 1'b0;
            MemRead = 1'b1;
            MemWrite = 1'b0;
            MemToReg = 1'b1;
            ALUSrc = 1'b1;
            RegWrite = 1'b1;
            Branch = 1'b0;
            ALUcntrl  = 2'b00; // add
           end
        `SW :   
           begin 
            RegDst = 1'b0;
            MemRead = 1'b0;
            MemWrite = 1'b1;
            MemToReg = 1'b0;
            ALUSrc = 1'b1;
            RegWrite = 1'b0;
            Branch = 1'b0;
            ALUcntrl  = 2'b00; // add
           end
        `ADDI :
          begin 
            RegDst = 1'b0;
            MemRead = 1'b0;
            MemWrite = 1'b0;
            MemToReg = 1'b0;
            ALUSrc = 1'b1;
            RegWrite = 1'b1;
            Branch = 1'b0;         
            ALUcntrl  = 2'b00; // add             
          end
       `BEQ:  
           begin 
            RegDst = 1'b0;
            MemRead = 1'b0;
            MemWrite = 1'b0;
            MemToReg = 1'b0;
            ALUSrc = 1'b0;
            RegWrite = 1'b0;
            Branch = 1'b1;
            ALUcntrl = 2'b01; // sub
           end
       default:
           begin
            RegDst = 1'b0;
            MemRead = 1'b0;
            MemWrite = 1'b0;
            MemToReg = 1'b0;
            ALUSrc = 1'b0;
            RegWrite = 1'b0;
            ALUcntrl = 2'b00; 
         end
      endcase
    end // always
endmodule


/**************** Module for Bypass Detection in EX pipe stage goes here  *********/
 module  control_bypass_ex(output reg [1:0] bypassA,
                       output reg [1:0] bypassB,
                       input [4:0] idex_rs,
                       input [4:0] idex_rt,
                       input [4:0] exmem_rd,
                       input [4:0] memwb_rd,
                       input       exmem_regwrite,
                       input       memwb_regwrite);
    always @(*)
      begin
      
        if((exmem_regwrite==1'b1)&&(exmem_rd!=5'b0)&&(exmem_rd==idex_rs))
          bypassA <= 2'b10;
        
        else if ((memwb_regwrite== 1'b1) && (memwb_rd != 5'b0) && (memwb_rd==idex_rs) && ((exmem_rd != idex_rs) || (exmem_regwrite==0)))
          bypassA <= 2'b01;
        
	else 
          bypassA <= 2'b00;
           
        if((exmem_regwrite==1'b1)&&(exmem_rd!=5'b0)&&(exmem_rd==idex_rt))
          bypassB <= 2'b10;

        else if ((memwb_regwrite== 1'b1) && (memwb_rd != 5'b0) && (memwb_rd==idex_rt) && ((exmem_rd != idex_rt) || (exmem_regwrite==0)))
          bypassB <= 2'b01;

	else 
	  bypassB <= 2'b00; 

      end
      /* Fill in module details */
endmodule          
                       

/**************** Module for Stall Detection in ID pipe stage goes here  *********/
 

module control_stall_ex(input [4:0] IFID_Rs, 
                        input [4:0] IFID_Rt,
                        input [4:0] IDEX_registerRt,
                        input       IDEX_MemRead, 
                        output reg  PCWrite,
                        output reg  IFIDWrite,
                        output reg  StallControl); 

  always @(*)
    begin
      if ( IDEX_MemRead == 1'b1 && ( IDEX_registerRt == IFID_Rs || IDEX_registerRt== IFID_Rt))
        begin
         PCWrite<=1'b0;
         IFIDWrite<=1'b0;
         StallControl<=1'b0;
        end
      else 
        begin 
         PCWrite<=1'b1;
         IFIDWrite<=1'b1;
         StallControl<=1'b1;
        end
     end

endmodule
                       
/************** control for ALU control in EX pipe stage  *************/
module control_alu(output reg [3:0] ALUOp,                  
               input [1:0] ALUcntrl,
               input [5:0] func);

  always @(ALUcntrl or func)  
    begin
      case (ALUcntrl)
        2'b10: 
           begin
             case (func)
              6'b100000: ALUOp  = 4'b0010; // add
              6'b100010: ALUOp = 4'b0110; // sub
              6'b100100: ALUOp = 4'b0000; // and
              6'b100101: ALUOp = 4'b0001; // or
              6'b100111: ALUOp = 4'b1100; // nor
              6'b101010: ALUOp = 4'b0111; // slt
              6'b000000: ALUOp = 4'b1000; //sll
              6'b000100: ALUOp = 4'b1001;//sllv
              default: ALUOp = 4'b0000;       
             endcase 
          end   
        2'b00: 
              ALUOp  = 4'b0010; // add
        2'b01: 
              ALUOp = 4'b0110; // sub
        default:
              ALUOp = 4'b0000;
     endcase
    end
endmodule
