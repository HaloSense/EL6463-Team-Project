`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 12/12/2022 11:54:19 AM
// Design Name: 
// Module Name: Data_ext
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module Data_ext(clk, rst, w_mode, r_mode, addr_in, din, opc_in, dout);
   input         clk;
   input         rst;
   input [2:0]   w_mode;
   input [2:0]   r_mode;
   input [31:0]  addr_in;
   input [31:0]  din;
   input [9:0]   opc_in;
   output [31:0] dout;
   
   reg [7:0]     dmem1[0:1023] ;
   reg [7:0]     dmem2[0:1023] ;
   reg [7:0]     dmem3[0:1023];
   reg [7:0]     dmem4[0:1023];
	integer  i;
	initial
	begin
		for(i=0;i<1024;i=i+1) begin
			dmem1[i] = 0;
			dmem2[i] = 0;
			dmem3[i] = 0;
			dmem4[i] = 0;
		end 
	end
   wire [31:0]   row;
   wire [31:0]   addr_dmem;
   wire [31:0]   index_dmem;
   wire [31:0]   index;
   reg [31:0]    dO;
   reg [31:0]    d_t;
   wire          dout_se;
   wire [9:0]    opcode;
   wire [6:0]    func7;
   wire [2:0]    func3;
   
   assign addr_dmem = (addr_in & ((~32'h80000000)));
   assign row[31:0] = {2'b0,addr_dmem[31:2]};
   assign index_dmem = (addr_in & 32'h00000003);
   assign index = index_dmem;
   
   assign opcode = opc_in;
   assign dout_se = (opcode == 10'b0000000011 || opcode == 10'b0010000011) ? 1'b1 : 
                    1'b0;
   
   assign func7 = opc_in[6:0];
   assign func3 = opc_in[9:7];
   
   
   always @(negedge rst or posedge clk)
      if (rst == 1'b0)
         dO <= 0;
      else 
      begin
         if (addr_dmem < 4096)
         begin
            if (r_mode == 3'b001)
               case (index)
                  0 :
                     dO <= {24'h000000, dmem1[row]};
                  1 :
                     dO <= {24'h000000, dmem2[row]};
                  2 :
                     dO <= {24'h000000, dmem3[row]};
                  3 :
                     dO <= {24'h000000, dmem4[row]};
                  default :
                     ;
               endcase
            
            else if (r_mode == 3'b011)
               case (index)
                  0 :
                     dO <= {16'h0000, dmem2[row], dmem1[row]};
                  1 :
                     dO <= {16'h0000, dmem3[row], dmem2[row]};
                  2 :
                     dO <= {16'h0000, dmem4[row], dmem3[row]};
                  3 :
                     dO <= {16'h0000, dmem1[row + 1], dmem4[row]};
                  default :
                     ;
               endcase
            
            else if (r_mode == 3'b111)
               case (index)
                  0 :
                     dO <= {dmem4[row], dmem3[row], dmem2[row], dmem1[row]};
                  1 :
                     dO <= {dmem1[row + 1], dmem4[row], dmem3[row], dmem2[row]};
                  2 :
                     dO <= {dmem2[row + 1], dmem1[row + 1], dmem4[row], dmem3[row]};
                  3 :
                     dO <= {dmem3[row + 1], dmem2[row + 1], dmem1[row + 1], dmem4[row]};
                  default :
                     ;
               endcase
            else
               
               dO <= {32{1'b0}};
         end
         else
            dO <= {32{1'b0}};
      end
   
   
   always @(opc_in or dout_se or dO)
      if (dout_se == 1'b1)
         case (func3)
            3'b000 :
               d_t <={{24{dO[7]}},dO[7:0]} ;
            3'b001 :
               d_t <= {{24{dO[15]}},dO[15:0]};
            default :
               d_t <= dO;
         endcase
      else
         case (func3)
            3'b100 :
               d_t <= {{24{dO[7]}},dO[7:0]};
            3'b101 :
               d_t <= {{24{dO[15]}},dO[15:0]};
            default :
               d_t <= dO;
         endcase
   
   assign dout = d_t;
   
   always @(posedge clk)
      
      begin
         if (addr_dmem < 4096)
         begin
            if (w_mode == 3'b001)
            begin
               if (index == 0)
                  dmem1[row] <= din[7:0];
            end
            
            else if (w_mode == 3'b011)
               case (index)
                  0 :
                     dmem1[row] <= din[7:0];
                  3 :
                     dmem1[row + 1] <= din[15:8];
                  default :
                     ;
               endcase
            
            else if (w_mode == 3'b111)
               case (index)
                  0 :
                     dmem1[row] <= din[7:0];
                  1 :
                     dmem1[row + 1] <= din[31:24];
                  2 :
                     dmem1[row + 1] <= din[23:16];
                  3 :
                     dmem1[row + 1] <= din[15:8];
                  default :
                     ;
               endcase
         end
      end
   
   
   always @(posedge clk)
      
      begin
         if (addr_dmem < 4096)
         begin
            if (w_mode == 3'b001)
            begin
               if (index == 1)
                  dmem2[row] <= din[7:0];
            end
            
            else if (w_mode == 3'b011)
               case (index)
                  1 :
                     dmem2[row] <= din[7:0];
                  0 :
                     dmem2[row] <= din[15:8];
                  default :
                     ;
               endcase
            
            else if (w_mode == 3'b111)
               case (index)
                  1 :
                     dmem2[row] <= din[7:0];
                  2 :
                     dmem2[row + 1] <= din[31:24];
                  3 :
                     dmem2[row + 1] <= din[23:16];
                  0 :
                     dmem2[row] <= din[15:8];
                  default :
                     ;
               endcase
         end
      end
   
   
   always @(posedge clk)
      
      begin
         if (addr_dmem < 4096)
         begin
            if (w_mode == 3'b001)
            begin
               if (index == 2)
                  dmem3[row] <= din[7:0];
            end
            
            else if (w_mode == 3'b011)
               case (index)
                  2 :
                     dmem3[row] <= din[7:0];
                  1 :
                     dmem3[row] <= din[15:8];
                  default :
                     ;
               endcase
            
            else if (w_mode == 3'b111)
               case (index)
                  2 :
                     dmem3[row] <= din[7:0];
                  3 :
                     dmem3[row + 1] <= din[31:24];
                  0 :
                     dmem3[row] <= din[23:16];
                  1 :
                     dmem3[row] <= din[15:8];
                  default :
                     ;
               endcase
         end
      end
   
   
   always @(posedge clk)
      
      begin
         if (addr_dmem < 4096)
         begin
            if (w_mode == 3'b001)
            begin
               if (index == 3)
                  dmem4[row] <= din[7:0];
            end
            
            else if (w_mode == 3'b011)
               case (index)
                  3 :
                     dmem4[row] <= din[7:0];
                  2 :
                     dmem4[row] <= din[15:8];
                  default :
                     ;
               endcase
            
            else if (w_mode == 3'b111)
               case (index)
                  3 :
                     dmem4[row] <= din[7:0];
                  0 :
                     dmem4[row] <= din[31:24];
                  1 :
                     dmem4[row] <= din[23:16];
                  2 :
                     dmem4[row] <= din[15:8];
                  default :
                     ;
               endcase
         end
      end

endmodule
